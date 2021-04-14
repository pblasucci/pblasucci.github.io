How the Sausage Gets Made
===

A few folks on the internet have inquired about my new, fully bespoke blog
engine -- although "blogging system" might be a more accurate description. So,
for those curious (and so future me can regain lost context), what follows is a
tour of "[How the sausage gets made][1]" (to paraphrase Mr. John Godfrey Saxe).

> **TL; DR**
>
> It's all just HTML, CSS, and PowerShell.
>
> ```
> (•_•)
> ( •_•)>⌐■-■
> (⌐■_■)
> ```
>

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

I find that blogging, much like the essays I used to write in school, works
better if I follow a process. Specifically, each post goes through the
following stages:

![Lifecycle of a blog post][A]
Draft -> Ready -> Publish -> Deploy

It's worth noting that I can perform versioning (via git) at any and every
stage of the post's lifecycle. This means I can pause work for hours/days/weeks
and still pick up right where I left off. Additionally, I only automate the bare
minimum, allowing plenty of human oversight and intervention -- and any
transition is manually initiated. This, combined with the stand-alone nature of
the individual posts (relative to the templating system), means I retain full
stylistic control, while trivially permitting "one off" tweaks. What's more: I
can have a single post exist in multiple stages at the same time. I do this
very very rarely. But it has been useful for fine-tuning the overall process.

#### Stage 1: Draft

```shell
weblog> new-item ./draft/blog-recipe.md && start-process code './draft/blog-recipe.md'
```

This is the stage of raw ideas, where posts tend to linger the longest. It's
just a folder full of [Markdown][3] files. Some are barely outlines. Some are
novellas. But the goal in this phase is simply letting the concepts flow out of
my brain and into the text.

#### Stage 2: Ready

```shell
weblog> ./move-content.ps1 -Stage Render -Include blog-recipe.md && code ./ready/blog-recipe.html
```

This is where posts go when I'm satisfied with the raw content. It's also where
I do the most mundane drudgery. At this point, I transition from Markdown files
to proper HTML. Then I get to work: adjusting the layout of the content;
tweaking the associated CSS; layering in images and other media; and enriching
the post with metadata (topical tags, mostly). It's also during this phase that
I bring in a hosting tool (usually [`dotnet serve`][4] or
[JetBrains WebStorm][5]), which allows me to preview everything exactly how the
finished product will appear. Finally, I'll give the post a full round of
editorial scrunity (i.e. grammar, spelling, _and_ literary style). Only then is
it ready for publication.

#### Stage 3: Publish

```shell
weblog> ./move-content.ps1 -Stage Publish -Include blog-recipe.html
weblog> dotnet serve -d ./docs/ -o
```

This is, arguably, the most automation-heavy phase of the lifecycle. Once a
post arrives here, it receives another thorough review of everything (again,
via a high-fidelity live preview). However, as part of being moved into this
stage, the metadata from the previous step has been extended with a timestamp
and -- most importantly -- used to generate one, or more. listing pages. In
other words, the weblog's "home page" (listing all posts in reverse
chronological order) gets updated. But also, similar listing pages are
generated corresponding to the tags collected from across all the published
_and_ deployed blog posts. All that's left now is to "go live".

#### Stage 4: Deploy

```shell
weblog> git add . && git commit -m "publish blog recipe" && git push
weblog> start-process https://paul.blasuc.ci
```

'Deploy' is the final, and simplest, phase. I commit the published posts, and
generated listings, to _Git_. And I push the commit to GitHub.com, which handles
the hosting of the static HTML/CSS/JS/et cetera files automatically, via
[GitHub Pages][6].

### C'mon, really?! PowerShell?!

I know a lot of folks like to dump on PowerShell.

> "It's got a weird syntax. Just use Perl."

> "The world doesn't need yet another shell."

> "Learn a real shell like bash or zsh."

> "Ewwww... Micro$oft $ukz!"

And so on, ad nauseam.

So, while I don't think it's the best tool for _everything_, I do think it's
a great fit for this project. Here's why:

+ It's simple... a single script handles everything (and really, it's just 3 functions).
+ It's robust... everything I need is "in-the-box" (no messing about with dependencies).

Let's unpack this second point. What do I actually _need_ to make things "go"?

Well, first, I need a simple parameterized command-line interface. PowerShell
has extensive, first-class support for all manner of CLI arguments... Flags?
Lists? Defaults? You name it, it's supported. And with built-in validation to
boot!

But I also need pathing and file management (move, copy, drop, read, et cetera).
Yup! That's covered, too. But even more so, I need _template_ file management.
And this is where PowerShell really shines. Just one little function means that
_any text file can be used as a template with full data substitution_ (credit
to [Pim Brouwers][7] for clueing me into this one...thanks!). Yes, that's right.
It does HTML templates. It does JSON templates. Hell! I have a failed project
which used this technique with F# templates. And it's _tiny_.
It looks like this:

```powershell
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
```

Oh! But also, I need to convert Markdown to HTML. PowerShell ships with support
for CommonMark as a one-liner (where `$fullPath` is just the location of a
`*.md` file on disk):

```powershell
$markdown = Get-Content $fullPath -Raw | ConvertFrom-Markdown
```

Hmm... this is cool. But I also need to work with collections of data (in order
to build the listing pages). No worries. Powershell works with _objects_ where
most other shells work with file descriptors or text. So, naturally, I have
arrays and hashmaps at the ready.

Finally, rounding it out are all the little things one expects from a shell:

+ Regular expressions... to extract values from text files.
+ Conditionals... with which to make decisions.
+ Full access to the underlying OS... for launching processes and such.

> #### Sidebar: Not Just for Windows
>
> My day-to-day machine is a [System76][8] Galago Pro running a snazzy Linux
> distro: [Pop!_OS][9]. PowerShell core runs like a champ here (as well as
> Windows and macOS) -- thanks to the cross-platform goodness of [.NET Core][10].

### Final Solution

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

[ 1]: https://en.wikipedia.org/wiki/John_Godfrey_Saxe#Legacy "John Godfrey Saxe"
[ 2]: https://github.com/PowerShell/PowerShell#-powershell "pwsh Everywhere!"
[ 3]: https://commonmark.org/ "CommonMark: A strongly defined, highly compatible specification of Markdown"
[ 4]: https://github.com/natemcmaster/dotnet-serve "natemcmaster/dotnet-serve"
[ 5]: https://www.jetbrains.com/webstorm/ "The smartest JavaScript IDE"
[ 6]: https://pages.github.com/ "Websites for you and your projects."
[ 7]: https://www.pimbrouwers.com/ "Pim is AWESOME!!!"
[ 8]: https://system76.com/ "System76"
[ 9]: https://pop.system76.com/ "Pop!_OS y System76"
[10]: https://dotnet.microsoft.com/ "Free. Cross-platform. Open source."

[A]: ??? "Draft -> Ready -> Publish -> Deploy"
