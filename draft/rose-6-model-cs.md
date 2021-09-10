Growing a Gilded Rose, Bonus 2: Meh... C# Can Do That, Too
===

This is part six of six in the series, _Growing a Gilded Rose_. Over the
course of these six blog posts, I hope to demonstrate incrementally
introducing many new concepts while extending a legacy code base which has
thorny requirements. The full series is as follows:

0. [Growing a Gilded Rose][0]
1. [Make it Testable][1]
1. [Next Year's Model][2]
1. [When Worlds Collide][3]
1. [A New Requirement Appears][4]
1. [Bonus: F# All the Things!][5]
1. **Bonus: Meh... C# Can Do That, Too** (this post)

```
+ overview of this post
    + ??solution screenshots??
+ re-thinking an F# model as a C# one
    + C# 9: records
    + C# 9: pattern matching
    + retain mapping between model and boundary type (observe original constraint)
    + major differences with F# model
        + cater to common primitives (int v. uint8)
        + value objects require more boiler-plate
        + hierarchy is not "closed"
        + extra layer in inventory model ("ordinary")
            + helps keep matching logic cleaner... because no active patterns
+ house-keeping
    + back down to two projects
    + a few less tests
+ C# test suite is left as an exercise to the reader ;-)
```


[0]: https://paul.blasuc.ci/grow-a-rose.html
[1]: https://paul.blasuc.ci/rose-1-testable.html
[2]: https://paul.blasuc.ci/rose-2-model-fs.html
[3]: https://paul.blasuc.ci/rose-3-coalesce.html
[4]: https://paul.blasuc.ci/rose-4-extended.html
[5]: https://paul.blasuc.ci/rose-5-fs-alone.html
[6]: https://paul.blasuc.ci/rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
