Growing a Gilded Rose, Bonus 2: Meh... C# Can Do That, Too
===

This is a bonus supplement in the series, [_Growing a Gilded Rose_][0]. Over the
course of these six blog posts, I hope to demonstrate incrementally improving
a legacy code base which has thorny requirements, while also presenting a few
different software development tools or concepts. The full series is as follows:

1. [Make it Testable][1]
1. [Next Year's Model][2]
1. [When Worlds Collide][3]
1. [A New Requirement Appears][4]
+ [Bonus: F# All the Things!][5]
+ **Bonus: Meh... C# Can Do That, Too** (this post)

![Solution Evolution][sln]

---

+ overview of this post

+ re-thinking an F# model as a C# one
    + C# 9: records
        + records vs. interfaces
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

+ recap post
+ recap series


[0]: ./grow-a-rose.html
[1]: ./rose-1-testable.html
[2]: ./rose-2-model-fs.html
[3]: ./rose-3-coalesce.html
[4]: ./rose-4-extended.html
[5]: ./rose-5-fs-alone.html
[6]: ./rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose

[sln]: ../media/rose-6-sln.jpg
