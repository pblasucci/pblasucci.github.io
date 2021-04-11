How the Sausage Gets Made
===

A few folks on the internet have inquired about my new, fully bespoke blog
engine -- although "blogging system" might be a more accurate description. So,
for those curious (and so future me can regain lost context), what follows is a
tour of "[How the sausage gets made][1]" (to paraphrase Mr. John Godfrey Saxe).

### Background

Why a new blog? Why now?

Why not?!

I don't blog very often -- but hope to improve the status quo by using tooling
more conducive to how I like to work. So, I did a bunch of soul-searching and
developed the following list of requirements (in descending order of priority):

1. Fully own my content
1. Full control over semantics, layout, styling
1. Embrace HTML as a writers medium
1. No comments
1. No trackers
1. Minimal Markdown
1. No YAML -- HTML is perfectly capable of storing metadata
1. No Node.js (or anything from that ecosystem)
1. Minimal JavaScript
1. Embrace git as versioning, auditing, workflow tool
1. No backend
1. Import old content
1. Single repository
1. Free hosting

The combination of these, especially the first three requirements, pointed _very_
strongly toward a self-manged solution (as opposed to: WordPress, Medium, et
cetera). Further, after doing a bunch of research into popular tooling, the
latter half of my requirements meant I need to code up something "from scratch".

So, in the end, I developed a workflow which uses [PowerShell Core][2], and some
very basic _Git-fu_, to stitch together a mix of HTML and CSS (and, yes, I
_did_ sneak in a bit of Markdown and JavaScript... but in a minimal and _focused_
manner).

Before I wax poetic on the merits of PowerShell, let me spell out my workflow.
This will, hopefully, help shine of light on the benefits of the system I've
put in place.

### My Workflow

+ Draft -> Ready -> Publish -> Deploy
+ All transitions manually initiated
+ Versioning, checkpoints (via git) at every stage
    + Can pause work for days/weeks/months/years and still pick up where I left off
+ Only automates the minimum
    + Allows lots of inflection points for change
+ Each post is functionally independent
    + Consistent behavior with the ability to have "one off" tweaks
+ Draft
    + Markdown
    + Raw ideas, outlines, rough content, et cetera
+ Ready
    + HTML (with rendered preview... dotnet serve, WebStorm, etc.)
    + CSS tweaks (as needed)
    + Full grammatical, stylistic editing
    + Enrichments (tags, graphics, et cetera)
+ Publish
    + Add in pertinent metadata
    + Double-check everything
+ Deploy
    + Make it live on the internet

### Why PowerShell

+ Simple -- one 300-line script to drive the workflow
    + Very easy to debug and make changes as needed
+ Robust -- all the functionality I need is in-the-box
    + Parameterized inputs
    + File manipulation
    + Open-ended templating
    + Markdown conversion (via Markdig)
    + Collections, Collection processing
    + String interpolation
    + Regular expression
    + Conditionals
    + Full access to OS
+ Cross-platform

### Final Solution

+ Worked example:
    + `weblog> new-item ./draft/blog-recipe.md && start-process code './draft/blog-recipe.md'`
    + _do a bunch of writing_
    + `weblog> ./move-content.ps1 -Stage Render -Include blog-recipe.md && code ./ready/blog-recipe.html`
    + _do a bunch of editing_
    + `weblog> ./move-content.ps1 -Stage Publish -Include blog-recipe.html`
    + `weblog> dotnet serve -d ./docs/ -o`
    + _pretend we're happy with everything_
    + `weblog> git add . && git commit -m "publish blog recipe" && git push`
    + `weblog> start-process https://paul.blasuc.ci`

---

For posterity's sake, what follows is the complete PowerShell script I use to
"drive" my blogging workflow:

```powershell
#!/usr/bin/env pwsh

<#
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('Render', 'Publish')]
    [string] $Stage,

    [Parameter(Mandatory=$False)]
    [string[]] $Include,

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
    # loop over all "published" articles; for each:
    #   + emit metadata (to be used by the listings)
    $postMetaOld = Get-ChildItem ./docs/posts -Filter *.html | ForEach-Object {
        $fullPath = $_.FullName
        $baseName = $_.BaseName

        # load published layout
        $postContent = Get-Content $fullPath -Raw | Out-String

        Invoke-Template {
            # extract post title
            if ($postContent -match '(?<=id="post_title">)[^<]+') {
                $postName = $Matches[0].Trim()
            } else {
                throw "Could not determine post title! (file: $fullPath)"
            }

            # extract publication metadata
            if ($postContent -match '(?<=name="published"\s*content=")(?<PUB>[^"\n]*)') {
                $publishedAt = [DateTimeOffset]::Parse($Matches.PUB.Trim()).ToLocalTime()
                $pubISO_8601 = $publishedAt.ToString("o")
                $pubFriendly = $publishedAt.ToString("dddd, dd MMMM yyyy, 'at' HH:mm 'UTC' K")
            } else {
                throw "Could not determine publication date! (file: $fullPath)"
            }

            # process tag metadata
            if ($postContent -match '(?<=name="tags"\s*content=")[^"\n]*') {
                $tagList = $Matches[0].Split(';').Trim()
                $postTags = ($tagList | ForEach-Object {
                    "<li><a href=`"../lists/$([uri]::EscapeDataString($_)).html`">$_</a></li>"
                }) -join [Environment]::NewLine
            } else {
                $tagList = @()
                $postTags = [string]::Empty
            }

            # pass metadata downstream
            $meta = @{
                PostFile = "../posts/$($baseName).html"
                PostName = $postName
                PostTags = $postTags
                TagList = $tagList
                PublishedAt = $publishedAt
                PubISO_8601 = $pubISO_8601
                PubFriendly = $pubFriendly
            }

            Write-Output $meta
        }
    }

    #
    # loop over all "ready" articles (optionally including/excluding some); for each:
    #   + update publication
    #   + synchronize tag metadata between HEAD and BODY
    #   + render updated HTML
    #   + emit metadata (to be used by the listings)
    #   + (optionally) remove "ready" artifact
    $postMetaNew = Get-ChildItem ./ready/posts -Recurse -Filter *.html -Include $Include -Exclude $Exclude | ForEach-Object {
        $fullPath = $_.FullName
        $baseName = $_.BaseName

        # load ready layout
        $postTemplate = Get-Content $fullPath -Raw | Out-String

        Invoke-Template {
            # update publication metadata
            $publishedAt = switch -regex ( $postTemplate ) {
                # extract existing publication date (for imported posts)
                '(?<=name="published"\s*content=")(?<PUB>[^"\n]*)'
                {
                    try {
                        [DateTimeOffset]::Parse($Matches.PUB.Trim()).ToLocalTime()
                    } catch {
                        # default to generating a new timestamp (for fresh posts)
                        [DateTimeOffset]::Now
                    }
                }
                # default to generating a new timestamp (for fresh posts)
                default { [DateTimeOffset]::Now }
            }

            $pubISO_8601 = $publishedAt.ToString("o")
            $pubFriendly = $publishedAt.ToString("dddd, dd MMMM yyyy, 'at' HH:mm 'UTC' K")

            # Normalize publication information
            $postTemplate = $postTemplate -replace '(?<=name="published"\s*content=")[^"\n]*', $pubISO_8601

            # extract post title
            if ($postTemplate -match '(?<=id="post_title">)[^<]+') {
                $postName = $Matches[0].Trim()
            } else {
                throw "Could not determine post title! (file: $fullPath)"
            }

            # process tag metadata
            $postTags =
                if ($postTemplate -match '(?<=name="tags"\s*content=")[^"\n]*') {
                    $tagList = $Matches[0].Split(';').Trim()
                    ($tagList | ForEach-Object {
                        "<li><a href=`"../lists/$([uri]::EscapeDataString($_)).html`">$_</a></li>"
                    }) -join [Environment]::NewLine
                } else {
                    [string]::Empty
                }

            # emit final content
            $postFile = Join-Path -Path $postsFolder -ChildPath "$($baseName).html"
            Write-Debug "Generating file: $postFile"
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
                PublishedAt = $publishedAt
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
    $itemTemplate = '
        <li class="entry">
            <a href="$postFile">$postName</a>
            <span>
            Published:
            <time datetime="$pubISO_8601">$pubFriendly</time>
            </span>
            <ul class="tags">
                $postTags
            </ul>
        </li>
    '

    # load listing layout
    $listTemplate = Get-Content ./look/list.html -Raw | Out-String

    # project article metadata into a mapping from tag to a collectin of article metadata
    $tagLists = @{}
    $postMeta = @($postMetaOld) + @($postMetaNew)
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
            $listItems = ($tagLists[$listName] | Sort-Object -Descending -Property PublishedAt | ForEach-Object {
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
        $listItems = ($postMeta | Sort-Object -Descending -Property PublishedAt | ForEach-Object {
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
    Get-ChildItem ./draft -Recurse -Filter *.md -Include $Include -Exclude $Exclude | ForEach-Object {
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
```

[1]: https://en.wikipedia.org/wiki/John_Godfrey_Saxe#Legacy "John Godfrey Saxe"
[2]: https://github.com/PowerShell/PowerShell#-powershell "pwsh Everywhere!"
