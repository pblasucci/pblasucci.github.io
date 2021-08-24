Growing a Gilded Rose, Bonus 2: Meh... C# Can Do That, Too
===

```
+ overview of series
    + TOC/links to other posts
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
