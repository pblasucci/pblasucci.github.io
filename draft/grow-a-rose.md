Growing a Gilded Rose
===

Time heals all wounds.

Except in software development, where it generally just makes everything a
confused, trembling mass of insecurities.

Nowhere is this more evident than when a new developer inherits a legacy
program. You know the sort. Undocumented. No tests. Inscrutably obtuse in some
places. Maddeningly sparse in others. And anyone with any 'insight' has long
since retired.

But dealing with these challenges is part of being a software developer. So,
over the next several blog posts, I'd like to take you through a bit of a
worked example, which tackles this _timeless_ (pun intended) battle. To make
things a little simpler, I'll take an existing, and somewhat well-known,
'code kata' (or, programming practice exercise) as a starting point.
Specifically, we'll try to master the [Gilded Rose Kata][9], originally
conceived by [Terry Hughes][8]. But we won't just "do the kata". Instead, we'll
take a step-wise approach as follows:

1. Create a short, but comprehensive, set of tests.
1. Based on what we learn, codify the desired behavior in a new model.
1. Integrate our new model into the legacy code.
1. Extend things with a new feature (this is the actual activity of the origin kata).

What's more, we'll also use this exercise as an excuse to address one of the
most common questions I encounter when interacting with other developers:

> How can I begin introducing F# into a brown-field C# code base?

There's quite a lot to get into, so I've split this into a separate blog post
for each stage. This will (hopefully) make it easier to incrementally introduce
new concepts. I've also include two 'bonus' posts, each of which explores
taking the problem further, albeit in slightly different directions.

---

> #### F#? Yuck!
>
> If you're one of those folks who fervently believes that ".NET == C#", or if
> you just aren't part of the target audience, or you -- like Terry Hughes --
> feel that changing the programming language is well past the bounds of the
> original kata, then you may want to [jump straight to the final bonus post][6],
> as it presents the final solution... but done using C#.

---

All in all, I hope to expose readers to the following:

+ Gaining mastery over a foreign codebase
+ [Approval tests][10] (or a poor approximation of them, at least)
+ [Property-based testing][11] and random data generation
+ Combining languages in a single .NET solution
+ Domain modeling in F#
+ Some of the new features in the latest version of C#

![Growing a Gilded Rose][sln]

### Steps for Growing a Gilded Rose

Over the course of six blog posts, I hope to demonstrate incrementally improving
a legacy code base which has thorny requirements, while also introducing several
new software development tools or concepts. The full series is as follows:

1. Overview (this post!)
1. [Make It Testable][1] ... wherein we introduce approval and property-based tests.
1. [Next Year's Model][2] ... wherein we use F# to realize a concise domain model.
1. [When Worlds Collide][3] ... wherein we plug an F# model into a C# program.
1. [A New Requirement Appears][4] ... wherein we extend the functionality slightly.

_Bonus Content_

1. [F# All the Things!][5] ... wherein we replace the C# program outright.
1. [Meh... C# Can Do That, Too][6] ... wherein we translate the model to C#.

### Source for Growing a Gilded Rose

Finally, I want make mention of the git repository which contains all of the
code we'll cover over the next several blog posts (plus all the bits we'll be
forced to skip).

> ###### Repository
>
> https://github.com/pblasucci/GrowningGildedRose

Like the blog posts, the repo has been carved up into more-easily-digested
chunks. Specifically, there's a separate branch for the "end state" of each
blog post. There's also an initial state which is basically the original kata
(slightly updated for .NET 5 and C# 9).

 Branch       | Summary
--------------|-------------------------------------------------------------------------
 `0_original` | Original (in C#) console application, i.e. the start of the kata.
 `1_testable` | Introduces (in F#): approval tests, unit tests, property-based tests.
 `2_model-fs` | Introduces (in F#): functional requirements expressed as a domain model.
 `3_coalesce` | Demonstrates adding (new) F# code to a (legacy) C# codebase.
 `4_extended` | Extends previous work with new functional requirements.
 `5_fs-alone` | BONUS: replaces C# console application with F# equivalent.
 `6_model-cs` | BONUS: replaces F# domain model with something similar in C#.

There's also a discussion board for the repository (and, indirectly, this series
of blog post). Come join the conversation.

> ###### Discussion
>
> https://github.com/pblasucci/GrowningGildedRose/discussions


_And now, let's go [visit The Gilded Rose][1]._


[0]: ./grow-a-rose.html
[1]: ./rose-1-testable.html
[2]: ./rose-2-model-fs.html
[3]: ./rose-3-coalesce.html
[4]: ./rose-4-extended.html
[5]: ./rose-5-fs-alone.html
[6]: ./rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
[8]: https://twitter.com/TerryHughes
[9]: https://github.com/NotMyself/GildedRose
[10]: https://approvaltests.com/
[11]: https://jessitron.com/2013/04/25/property-based-testing-what-is-it/
[sln]: ../media/rose-0-sln.jpg
