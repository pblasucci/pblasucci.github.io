Growing a Gilded Rose, Part 2: Next Year's Model
===

This is part two of six in the series, _Growing a Gilded Rose_. Over the
course of these six blog posts, I hope to demonstrate incrementally
introducing many new concepts while extending a legacy code base which has
thorny requirements. The full series is as follows:

0. [Growing a Gilded Rose][0]
1. [Make it Testable][1]
1. **This Year's Model** (this post)
1. [When Worlds Collide][3]
1. [A New Requirement Appears][4]
1. [Bonus: F# All the Things!][5]
1. [Bonus: Meh... C# Can Do That, Too][6]

---

```
+ overview of this post
    + ??solution screenshots??
+ add model
    + separate project
        + benefits of modeling in F#
        + links to other resources (esp: ScottW book)
    + highlights of model
        + "kinds" of inventory -- encoded as union
            + source
        + "behavior" -- encoded as function
            + source
            + active patterns to encode temporal shifting
        + Quality -- a classic DDD-style 'value object'
            + source
            + links to other posts
+ extend test project
    + more data generation
        + constraining union cases
    + more property tests
        + test value object invariants
        + rephrasing existing properties for new model
```


[0]: https://paul.blasuc.ci/posts/grow-a-rose.html
[1]: https://paul.blasuc.ci/posts/rose-1-testable.html
[2]: https://paul.blasuc.ci/posts/rose-2-model-fs.html
[3]: https://paul.blasuc.ci/posts/rose-3-coalesce.html
[4]: https://paul.blasuc.ci/posts/rose-4-extended.html
[5]: https://paul.blasuc.ci/posts/rose-5-fs-alone.html
[6]: https://paul.blasuc.ci/posts/rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
