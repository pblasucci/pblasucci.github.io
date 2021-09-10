Growing a Gilded Rose, Part 3: When Worlds Collide
===

This is part three of six in the series, _Growing a Gilded Rose_. Over the
course of these six blog posts, I hope to demonstrate incrementally
introducing many new concepts while extending a legacy code base which has
thorny requirements. The full series is as follows:

0. [Growing a Gilded Rose][0]
1. [Make it Testable][1]
1. [Next Year's Model][2]
1. **When Worlds Collide** (this post)
1. [A New Requirement Appears][4]
1. [Bonus: F# All the Things!][5]
1. [Bonus: Meh... C# Can Do That, Too][6]

---

```
+ overview of this post
    + ??solution screenshots??
+ extending model to smooth consumption
    + coding fro C# 9 in F# 5
+ updating main program
    + bring over "known items" from test suite
    + re-locate -- but don't change -- legacy code
    + leverage new model
        + Map from/into old Item class
        + C# 9: pattern matching
        + C# 9: switch expressions
+ more testing
    + oracular tests are da' bomb!!
        + (aren't we glad we kept the old code around)
```


[0]: https://paul.blasuc.ci/posts/grow-a-rose.html
[1]: https://paul.blasuc.ci/posts/rose-1-testable.html
[2]: https://paul.blasuc.ci/posts/rose-2-model-fs.html
[3]: https://paul.blasuc.ci/posts/rose-3-coalesce.html
[4]: https://paul.blasuc.ci/posts/rose-4-extended.html
[5]: https://paul.blasuc.ci/posts/rose-5-fs-alone.html
[6]: https://paul.blasuc.ci/posts/rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
