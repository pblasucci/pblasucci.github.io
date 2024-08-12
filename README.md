paul.blasuc.ci (née pblasucci.github.io)
===

This repository contains the content and support files for my personal weblog. I follow a simple three-stage writing
workflow (described here, _mostly_, so I don't forget the details). The three stages are as follows:

1.  _Draft_... Heavy on creative flow; light on structure/editing/proofing/presentation/etc.
1.  _Ready_... Thoughts crystallized; focus is on editing, proofing, and presentation.
1.  _Final_... Content is published; no changes (barring editorial corrections).

Each stage of the workflow has an associated folder in the repository. These folders will contain artifacts as follows:

Stage   | Folder    | Content
--------|-----------|--------------------------
Draft   | `./draft` | Markdown files
Ready   | `./ready` | A mix of HTML files and media (JPG, PNG, SVG, etc.)
Final   | `./docs`  | A mix of HTML files, media (JPG, PNG, SVG, etc.), and styling (CSS)

Finally, a small Powershell script, `Move-Content.ps1`, is provided to facilitate moving between stages. Sample usage
is as follows:

_Get a draft ready for publication:_
```powershell
PS ~> .\Move-Content.ps1 -Stage Render -Include some-cool-thing.md
```

_Finalize content for release:_
```powershell
PS ~> .\Move-Content.ps1 -Stage Publish
```

_By default, target files are selected by folder and extension. The `-Include` and `-Exclude`_ parameters help modify that:_
```powershell
PS ~> .\Move-Content.ps1 -Stage Render -Exclude really-raw-idea.md
```

_By default, target files are moved between stage folders. The `-Preserve` switch turns promotion into a "copy" operation._
```powershell
PS ~> .\Move-Content.ps1 -Stage Publish -Preserve
```
