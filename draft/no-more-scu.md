You Really Wanna Put Union There? Really?
===

_TL;DR -- I don't often use single-case discriminated unions. Check the
[flowchart](#picktype) to see what I'd use instead._

In F#, single-case discriminated unions crop up fairly often. However, in many
cases, there are other alternatives one might consider. In this post I want to
sketch some of these alternatives, providing an account of the possibilities
and -- more importantly -- the trade-offs involved. In order to keep this post
to a reasonable length, I will consider three very common scenarios for which
one might use single-case discriminated unions. Specifically, they are:

1. As [Marker Values](#markervalue)
1. As [Tagged Primitives](#taggedprimitive)
1. As [Value Objects](#valueobject)

> #### _!!! DISCLAIMER_ !!!_
>
> The advice in this post is meant to be a set of _guidelines_. A starting
> point. A way of consciously evaluating decisions (instead of just blindly
> copy-pasting some code). Further, after nearly 15 years of doing F#
> professionally, I've developed a lot of 'instinctual decision making'. This
> blog is very much an attempt at unpacking some of that, and codifying it in a
> way others might leverage. In short, it represents how _I_ approach things.
> This might not necessarily "work" for someone else. And it certainly won't
> cover all possible scenarios one might encounter. Still, I hope you find it
> useful.
>
> Just take everything herein with a grain of salt, OK?  :-)

### Marker Values <a id="markervalue"/>

For the purposes of this discussion, let's define a "marker value" as: a type
only ever manifested in a single instance. [Python's `None`][1] is one example.
The standard library in Pony also uses marker values to great effect. Though
unlike Python, where `None` is a built-in construct, Pony leverages its flexible
["primitive"][2] construct. In F#, you might see a single-case discriminated
union used for this purpose. In fact, one might argue any non-data-carrying
variant of _any_ discriminated union is an example of a marker value (but I
don't want to wade too deeply into philosophical topics here).

```fsharp
type AmbientAuth = AmbientAuth'
```

In any case, the main things one wants out of a marker value are:

1. It should _not_ carry data
1. It should _not_ support null-ness
1. It should be an actual type
1. It should have easy ergonomics (at the call site)
1. ~~It should have only one instance~~ All occurrences should be semantically equivalent

So, what _other_ alternatives are there in F#?

Plot Twist!!! **SCDUs _are_ the perfect type for this in F#.** But do consider
decorating them with the [`StructAttribute`][3]. Really?! Well, yes... and no.
There is one caveat. If you intend to have your F# "marker value" be consumed
by other .NET languages (e.g. C#, VB), you may want to consider a struct instead.

```fsharp
type AmbientAuth = struct (* MARKER *) end
```

Why something different for other languages? Because F# discriminated unions,
regardless of the number of variants, generate some extra code (as part of the
machinery encoding them onto the CLR). F# neatly hides this detail from you.
However, it's plainly visible in, for example, C# consumers. So, using a struct
produces a more language-neutral solution. But it will mean slightly more
cumbersome invocation for F# consumers.

```fsharp
// with a single-case union
let auth = AmbientAuth'

// versus a struct
let auth = AmbientAuth()
(*
let auth = AmbientAuth   ← partially applied constructor -- NOT a value!!
forgetting the parens ↑↑ is a subtle source of confusion
*)
```

So, to recap _Marker Values_ present the following options and trade-offs:

Single-case Union                   | CLR Struct
------------------------------------|-------------------------------------------
Pro: Hits a syntactic 'sweet spot'  | Pro: Language neutral
Con: Funky when used outside F#     | Con: Instantiation cruft in F#

### Tagged Primitives <a id="taggedprimitive"/>

Perhaps the most common usage of single-case unions -- or at least the one that
leaps foremost into people's minds -- is that of a "Tagged Primitive". In other
words, a simple wrapper of some other basic type, usually meant to provide more
context. Again, we can find similar constructs in other languages. Most notably,
[a `newtype` in Haskell][4]. Some fairly common examples of such a thing in F#
might be:

```fsharp
type ClientId = ClientId of Guid // ← this should probably be a Value Object!

type Pixels = Pixels of uint64
    // NOTE other operators omitted for brevity
    static member ( + ) (Pixels l, Pixels r) = Pixels(l + r)
```

In fact, if you squint a  bit, some of those ever (sort of) _look_ like
`newtype`. Alas, _F# is not Haskell_. Let me repeat that one more time for the
folks in the cheap seats:

**_F# IS NOT HASKELL._**

It really isn't. And it certainly doesn't have `newtype`. The above example
behaves rather differently (than `newtype`) in terms of what the compiler emits.
Requests to add such a feature have, to date, languished in discussion. So,
instead, we have the previous example, or a few other alternatives. But first,
let's have some criteria for why we'd want (need?) a `newtype`-like construct.

1. It should provide contextual information about the role of some code.
1. The 'new' type should be type-checked distinctly from the 'wrapped' type.
1. There are _no behavioral restrictions_ imposed on the underlying type.

This seem like very useful goals. However, item 2 means we can _not_ use
[type abbreviations][5]. And item 3 requires a significant amount of
'boilerplate' code to do correctly (as we want to have a lot of behavior pass
through to the underlying primitive). Also, let's pause to appreciate: if we
want the opposite of item 3, then we are almost certainly talking about a
"Value Object" (discussed later in this post). So what's left (besides
single-case unions)? Depending on the type being wrapped, and the target usage,
there are a few alternatives. Let's consider each in turn:

##### Units of Measure

[Units of Measure][6] meet all our given criteria. And syntactically they are
very light-weight, as well. Further, they enforce the fundamental rules of
mathematics at compile time (e.g. quantities of dissimilar units can be
multiplied together -- but not combined via addition).

```fsharp
[<Measure>]
type pixels

let offset = 240UL<pixels>
``

However, they carry some heavy restrictions. They are _limited to only numeric_
primitives (`int`, `float`, et cetera). They are _erased at compile time_ (so
no reflective meta-programming support -- and no visibility in other .NET
languages). Additionally, since many operations in .NET are _not_ "units aware",
it's not uncommon to have to explicitly temporarily discard the units for
certain operations (only to re-apply them later). This unwrap-compute-rewrap
dance has come to upset many an F# developer.

##### Generic Tags

It turns out, with just a little bit of hackery, we can actually get something
like Units of Measure -- but for non-numeric types. We call this a Generic Tag.
I won't go into the specific mechanics of it, though. There are a few different
ways to achieve it. And all of them are definitely _advanced_ (not to mention a
bit... circumspect). However, there's a [library which hides the details][11]
for many (most?) common non-numeric primitives. So I _will_ should you an
example.

```fsharp
open System

#r "nuget: FSharp.UMX"
open FSharp.UMX

[<Measure>]
type ClientId

let current : Guid<ClientId> = UMX.tag (Guid.NewGuid())
```

As with everything, there are some more trade-offs here. In fact, other than
lifting the restriction to numerics, generic tags have _all_ the same caveats as
units of measure. Further, their are at least _some_ "units aware" functions in
the core F# library. For generic tags, none of that machinery exists.

> #### A Matter of Philosophy
>
> It's also worth noting that things like customer identifers and invoice
> numbers might happen to "be numeric" but aren't actually "numbers". That is,
> subtracting one invoice number from another probably isn't a useful operation.
>
> Nothing in the mechanics of Units of Measure or Generic Tags prevents such
> silliness from occurring. But then again, how likely is a developer to
> 'accidentally' perform such an operation? Something to ponder during code
> reviews, I guess.  ;-)

##### Records

Since both Units of Measure and Generic Tags are erased at compile time, there
really is no way to expose them to other .NET Languages. And, as mentioned in
the section on Marker Values, even a Single-Case Union will surface some extra
cruft when consumed from, e.g., Visual Basic. So, in cases where a (CLR)
language-neutral implementation is required. We fallback to records, the
bread-and-butter of F# data types.

```fsharp
type ClientId = { Value : Guid } // ← this should probably be a Value Object!

type Pixels = { Value : uint64 }
    // NOTE other operators omitted for brevity
    static member ( + ) (Pixels l, Pixels r) = Pixels(l + r)
```

The drawback here is, clearly, the same as with single-case unions:
more boilerplate, as we'd like all our behavior to pass through to the
underlying primitive -- but need to code it ourselves.

> #### Code Generation to the Rescue?
>
> It's very possible much of the boilerplate for this approach could be
> addressed using a technique called code generation. If that's of interest to
> you, I encourage you to investigate the up-and-coming tool, [Myriad][7].
> It's very useful. But outside the scope of the current discussion (indeed,
> one could devote several blog posts just to Myriad).

Before moving, the trade-offs for various _Tagged Primitives_ can be summarized
as follows:

Single-case Union               | Units of Measure              | Generic Tag                   | Record
--------------------------------|-------------------------------|-------------------------------|---------------------------
Pro: Feel like a Haskeller      | Pro: Low-syntax, No-overhead  | Pro: Low-syntax, No-overhead  | Pro: Language neutral
Con: Requires boilerplate       | Con: Numeric types only       | Con: Dodgy use of type system | Con: Requires boilerplate
Con: Funky when used outside F# | Con: Erased at compile-time   | Con: Erased at compile-time   |

### Value Objects <a id="valueobject"/>

Earlier, I mentioned how a "primitive with customized behavior" is its own kind
of construct (and the closely related notion: maybe your `CustomerId`s
_shouldn't_ be divisible by _any_ number?). But this is a very well-explored
area of software development. It's called a "Value Object". It's an essential
part of [Domain-Driven Design][8]. And was first defined by Eric Evans in his
[seminal work on the subject][9]. But let me re-iterate here, the main aspects
of a value object:

1. It lacks identity
1. It has no lifecycle
1. It is self-consistent

Unpacking these a bit...

- "lacks identity" means there's no well-know identifier for this thing (e.g.
`row id = 12345`). In practical terms, it means a thing with _structural
equality semantics_. These are plentiful in F# (yay!).
- "no lifecycle" means it's not data which evolves over time. Again, concretely,
this means it's _immutable_. Cool. Lots of immutable constructs in F#.
- "self-consistent" means if you've got an instance of it, that instance can be
reliably assumed to contain (domain) valid data. Oh, hmm. So this one doesn't
come for free. In F#, we use carefully controlled construction functions to
realize self-consistent values.

Fortunately, there are several ways to encode a value object in F#. The most
common are as a discriminated union or as a record. Rarely, it will be
beneficial to model the internal state of the value object as one of a set of
mutually exclusive alternatives. In that (very infrequent) case, there's clearly
only one tool for the job -- a multi-case union. However, in this post, we're
focused on _single-case_ unions. And they can be used to address the most
common scenario of a value object simply wrapping one (or a few) field(s).

```fsharp
//TODO example of SCUD as VO
```

However, it's equally valid to use a _record_ for this. In fact, the code is
nearly identical. The only difference being how you define and access the
underlying data.

```fsharp
//TODO example of record as VO
```

In either case, the 'recipe' for a Value Object is roughly as follows:

1. Decide between a discriminated union or a record
1. Mark constructor and field(s) `private`
1. Add public construction (either by static methods or companion module)
1. Add any public read-only properties or operators (as needed)
1. Add any extra operations (either as methods or in a companion module)

But why pick a union? When should you prefer a record? Honestly, this comes down
to personal preference and sense of style. Me? Personally, I prefer the record.
Performing a decomposition just to access the internal state feels... gratuitous.
But to each his own. I certainly wouldn't balk at code that chose to go the
other way.

For completeness sake, the following table lists the trade-offs between unions
and records for encoding a _Value Object_ (though it's a very silly difference):

Single-case Union                       | Record
----------------------------------------|---------------------------------------
Con: Awkward access to underlying data  | Pro: Direct access underlying data

> #### Why lock the door if you're gonna leave the window wide open?!
>
> One thing I've seen (far too often) is code like the following:
>
> ```fsharp
> //TODO example of VO  with .Value
> ```
>
> Personally, this seems like a big let down. Why go through all the trouble of
> avoiding the so-called "[primitive obsession][10]" if you're just gonna {{???}}
>
> {{ why is this bad }}
>
> ```fsharp
> //TODO example of VO with explicit cast
> ```

### Conclusion <a id="picktype"/>

Hopefully, by now, I've at least got you thinking about the various alternative
approaches one might use when trying to 'level up' from simple primitives in F#.
To further help, and for easier reference, I've also created the following
flow chart ("How Paul Pick's His Primitives", so to speak):

![My Instincts -- Visualized][A]

Starting at the blue circle, follow the arrows. Each yellow rectangle is a
different use case. The amber diamonds represent a `yes || no` decision. By
answering these, you arrive at a green capsule containing the F# feature I'd
likely employ, given the previous constraints.

Have fun and happy coding!


[A]: ../media/pick-a-type.png "How I (usually) Choose a Representation"

[1]: https://docs.python.org/3/reference/datamodel.html#the-standard-type-hierarchy "Python Standard Type Hierarchy"
[2]: https://tutorial.ponylang.io/types/primitives.html#what-can-you-use-a-primitive-for "What can you use a primitive for?"
[3]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/discriminated-unions#struct-discriminated-unions "Struct Discriminated Unions"
[4]: https://wiki.haskell.org/Newtype "Haskell Newtype"
[5]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/type-abbreviations "F# Type Abbreviations"
[6]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure "F# Units of Measure"
[7]: https://moiraesoftware.github.io/myriad/ "Myriad: Code Generation for F#"
[8]: https://fsharpforfunandprofit.com/ddd/ "Domain-driven Design"
[9]: https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215 "Blue Book"
[10]: https://blog.ploeh.dk/2011/05/25/DesignSmellPrimitiveObsession/ "Primitive Obsession"
[11]: https://github.com/fsprojects/FSharp.UMX "FSharp.UMX"
