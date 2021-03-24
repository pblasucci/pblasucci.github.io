#!/usr/bin/env pwsh

<#
    .SYNOPSIS
        Facilitates content development workflow for {{BLOG_TITLE}}.

    .DESCRIPTION
        Prepares draft content for publication
        Published finalized content
        (N.B. does NOT perform git-level operations)

    .PARAMETER Stage
        Specifies which step of the workflow should be executed; valid values are:
        1. Render -- this will convert drafts into a form suitable for final review/tweaks
        2. Publish -- updates timestamps and the final listings (index, tag sets)

    .EXAMPLE
        PS ~> .\Move-Content.ps1 -Stage Render

    .Example
        PS ~> .\Move-Content.ps1 -Stage Publish
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('Render', 'Publish')]
    [string] $Stage,

    [Parameter(Mandatory=$False)]
    [string[]] $Exclude,

    [Parameter(Mandatory=$False)]
    [Switch] $Preserve
)

#
# Utility which helps bind key-value data into textual content
function Invoke-Template {
    param([ScriptBlock] $scriptBlock)

    function Render-Template {
        param([string] $template)

        Invoke-Expression "@`"`r`n$template`r`n`"@"
    }

    & $scriptBlock
}


#
# Transitions production-ready content into a final stage
function Publish {
    # output location for individual articles
    $postsFolder = './docs/posts'
    if (-Not (Test-Path -Path $postsFolder)) {
        New-Item -ItemType Directory $postsFolder | Write-Verbose
    }

    # output location for article listings
    $listsFolder = './docs/lists'
    if (-Not (Test-Path -Path $listsFolder)) {
        New-Item -ItemType Directory $listsFolder | Write-Verbose
    }

    #
    # loop over all "ready" articles (optionally including/excluding some); for each:
    #   + update publication
    #   + synchronize tag metadata between HEAD and BODY
    #   + render updated HTML
    #   + emit metadata (to be used by the listings)
    #   + (optionally) remove "ready" artifact
    $postMeta = Get-ChildItem ./ready/posts -Filter *.html -Exclude $Exclude | ForEach-Object {
        $fullPath = $_.FullName
        $baseName = $_.BaseName

        # load ready layout
        $postTemplate = Get-Content $fullPath -Raw | Out-String

        Invoke-Template {
            # update publication metadata
            $publishedAt = [DateTimeOffset]::Now
            $pubISO_8601 = $publishedAt.ToString("o")
            $pubFriendly = $publishedAt.ToString("dddd, dd MMMM yyyy, 'at' HH:mm 'GMT' K")

            # extract post title
            if ($postTemplate -match '(?<=id="post_title">)[^<]+') {
                $postName = $Matches[0].Trim()
            } else {
                throw "Could not determine post title! (file: $fullPath)"
            }

            # process tag metadata
            if ($postTemplate -match '(?<=name="tags"\s*content=")[^"\n]*') {
                $tagList = $Matches[0].Split(';').Trim()
                $postTags = ($tagList | ForEach-Object {
                    "<li><a href=`"../lists/$([uri]::EscapeDataString($_)).html`">$_</a></li>"
                }) -join [Environment]::NewLine
            } else {
                $postTags = [string]::Empty
            }

            # emit final content
            $postFile = Join-Path -Path $postsFolder -ChildPath "$($baseName).html"
            if (Test-Path -Path $postFile) {
                Remove-Item $postFile
            }
            Render-Template $postTemplate | Out-File -Path $postFile

            # pass metadata downstream
            $meta = @{
                PostFile = "../posts/$($baseName).html"
                PostName = $postName
                PostTags = $postTags
                TagList = $tagList
                PubISO_8601 = $pubISO_8601
                PubFriendly = $pubFriendly
            }

            Write-Output $meta
        }

        # clean up
        if (-Not $Preserve) { Remove-Item $fullPath -Force }
    }

    #
    # LISTINGS
    # ======================================================================

    # template for an individual article in a listing
    $itemTemplate = '<li class="entry">
        <a href="$postFile">$postName</a>
        <span>
        Published:
        <time datetime="$pubISO_8601">$pubFriendly</time>
        </span>
        <ul class="tags">
            $postTags
        </ul>
    </li>'

    # load listing layout
    $listTemplate = Get-Content ./look/list.html -Raw | Out-String

    # project article metadata into a mapping from tag to a collectin of article metadata
    $tagLists = @{}
    $postMeta | ForEach-Object {
        $original = $_
        $_.TagList | ForEach-Object {
            $tagLists[$_] += @($original)
        }
    }

    #
    # loop over all metadata tags; for each:
    #   + generate a listing of all articles with current tag
    #   + render listing into layout
    $tagLists.Keys | ForEach-Object {
        $listName = $_
        $listFile = Join-Path -Path $listsFolder -ChildPath "$($listName).html"

        # render tag index page
        Invoke-Template {

            # build fragment of list entries for associated articles
            $listItems = ($tagLists[$listName] | ForEach-Object {
                $postFile = $_.PostFile
                $postName = $_.PostName
                $postTags = $_.PostTags
                $pubISO_8601 = $_.PubISO_8601
                $pubFriendly = $_.PubFriendly

                Render-Template $itemTemplate
            }) -join [Environment]::NewLine

            # emit final content
            if (Test-Path -Path $listFile) {
                Remove-Item $listFile -Force
            }
            Render-Template $listTemplate | Out-File -Path $listFile
        }
    }

    $indexFile = './docs/index.html'
    $indexTemplate = Get-Content ./look/root.html -Raw | Out-String

    # render root index page
    Invoke-Template {

        # build fragment of list entries for associated articles, adjusting metadata (pathing) as needed
        $listItems = ($postMeta | ForEach-Object {
            $postFile = ($_.PostFile -replace '\.\./', './')
            $postName = $_.PostName
            $postTags = ($_.PostTags -replace '\.\./', './')
            $pubISO_8601 = $_.PubISO_8601
            $pubFriendly = $_.PubFriendly

            Render-Template $itemTemplate
        }) -join [Environment]::NewLine

        # emit final content
        if (Test-Path -Path $indexFile) {
            Remove-Item $indexFile -Force
        }
        Render-Template $indexTemplate | Out-File -Path $indexFile
    }
}


#
# Transitions draft content into a production review stage
function Render {
    # setup symlinks to help with previewing rendered content
    @('logic', 'media', 'style') | ForEach-Object {
        $symb = Join-Path -Path './ready' -ChildPath "$($_)"
        $real = Join-Path -Path "$($PSScriptRoot)/docs" -ChildPath "$($_)"

        if (-Not (Test-Path -Path $symb)) {
            New-Item -Path $symb -ItemType SymbolicLink -Value $real | Write-Verbose
        }
    }

    # output location for "ready" articles
    $postsFolder = './ready/posts'
    if (-Not (Test-Path -Path $postsFolder)) {
        New-Item -ItemType Directory $postsFolder | Write-Verbose
    }

    # load article layout
    $template = Get-Content ./look/post.html -Raw | Out-String

    #
    # loop over all drafts (optionally including/excluding some); for each:
    #   + render (most) HTML
    #   + seed template tokens for next stage
    #   + (optionally) remove draft
    Get-ChildItem ./draft -Filter *.md -Exclude $Exclude | ForEach-Object {
        $fullPath = $_.FullName
        $baseName = $_.BaseName

        Invoke-Template {
            # preserve variables needed for next stage
            $pubISO_8601 = '$pubISO_8601'
            $pubFriendly = '$pubFriendly'
            $postTags = '$postTags'

            # process content
            $markdown = Get-Content $fullPath -Raw | ConvertFrom-Markdown
            $postFile = Join-Path -Path $postsFolder -ChildPath "$($baseName).html"
            $postHtml = $markdown | Select-Object -ExpandProperty Html

            # render output
            Render-Template $template | Out-File -Path $postFile
        }

        # clean up
        if (-Not $Preserve) { Remove-Item $fullPath -Force }
    }
}


#
# ENTRY POINT
# ======================================================================
switch ($Stage) {
    'Render'  { Render  }
    'Publish' { Publish }
    #
    # NOTE we should never get this far because of input validation!
    default {
        Write-Error "ERROR! Unknown stage: '$Stage'"
    }
}
