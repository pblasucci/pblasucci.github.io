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
        2. Publish -- updates timestamps and the final listing (index)

    .EXAMPLE
        PS C:\> .\Move-Content.ps1 -Stage Render

    .Example
        PS C:\> .\Move-Content.ps1 -Stage Publish
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('Render', 'Publish')]
    [string] $Stage
)

function Publish {
    #   build list from contents of docs/index.html
    #   for each .html in ready/
    #       update publication timestamp in body
    #       generate index entry
    #       append index entry to list from step 1
    #       copy updated file to docs/
    Write-Debug 'Publish'
}

function Render {
    #   for each .md in draft/
    #       generate HTML content from markdown
    #       generate new file from template + previous step
    #       wrote previous step to ready/
    Write-Debug 'Render'
}

switch ($Stage) {
    'Render'  { Render  }
    'Publish' { Publish }
    #
    # NOTE we should never get this far because of input validation!
    default {
        Write-Error "ERROR! Unknown stage: '$Stage'"
    }
}
