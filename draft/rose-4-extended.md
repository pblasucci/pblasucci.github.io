Growing a Gilded Rose, Part 4: A New Requirement Appears
===

This is part four-of-four in the series, [_Growing a Gilded Rose_][0]. Over the
course of these four blog posts, I hope to demonstrate incrementally improving
a legacy code base which has thorny requirements, while also presenting a few
different software development tools or concepts. The full series is as follows:

1. [Make it Testable][1]
1. [Next Year's Model][2]
1. [When Worlds Collide][3]
1. **A New Requirement Appears** (this post)

_Bonus Content_

1. [F# All the Things!][5]
1. [Meh... C# Can Do That, Too][6]

![Solution Evolution][sln]

---

[The time has come! The time is now!][11] We're _finally_ going to address the
most important part (ostensibly) of the [Gilded Rose Kata][10]! Specifically,
we will add a new kind of item -- "conjured" items -- to our inventory. Further,
since the quality of a conjured item depreciates two times the rate of a
normal item, we will have to modify some of the core business logic.

You may recall, [last time][3] we integrated a new model into the legacy program.
One of the major motivations for introducing said model is to facilitate safer
and simpler maintenance. So now we can really put that to the test. Should you
wish to revisit the previous work, it is available in the
[companion repository][7], in a branch called [`3_coalesce`][8].

### A Bit of Housekeeping

+ house-keeping: lean into the new model
    + drop the old code
    + drop some of the old tests

### A Feature Conjured

+ new feature
    + add new code to model
    + add new properties to spec

### Conclusion

+ recap post
+ recap series
+ teaser for appendix 1
+ teaser for appendix 2


[0]: ./grow-a-rose.html
[1]: ./rose-1-testable.html
[2]: ./rose-2-model-fs.html
[3]: ./rose-3-coalesce.html
[4]: ./rose-4-extended.html
[5]: ./rose-5-fs-alone.html
[6]: ./rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
[8]: https://github.com/pblasucci/GrowningGildedRose/tree/3_coalesce
[9]: https://github.com/pblasucci/GrowningGildedRose/tree/4_extended
[10]: https://github.com/NotMyself/GildedRose
[11]: https://en.wikipedia.org/wiki/Marvin_K._Mooney_Will_You_Please_Go_Now!

[sln]: ../media/rose-4-sln.jpg
