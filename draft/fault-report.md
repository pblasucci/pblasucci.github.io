# FaultReport: an Hypothetical Alternative to `FSharp.Core.Result`

> **This post is part of the 2024 edition of the [F# Advent Calendar][4]**

This blog post is late. Not just days or weeks late. And not just because I promised Vlad and Jimmy I'd write up something back in early 2023 (sorry, gents). No, it's very much later: the approach described herein _should_ have been presented to the FSharp.Core maintainers way back in 2016. After all, that's where this all began. Part of the work for F# 4.1 was to introduce a type for modeling the outcome of an operation which might have either succeeded or failed. The decision was taken to introduce [`Result`][2]:

```fsharp
type Result<'T,'TError> =
    /// Represents an OK or a Successful result. The code succeeded with a value of 'T.
    | Ok of ResultValue:'T

    /// Represents an Error or a Failure. The code failed with a value of 'TError representing what went wrong.
    | Error of ErrorValue:'TError
```

Even back then, I had some [misgivings][1], having worked with similar constructs in various projects over the years. However, at the time of all this development, I only had "feels". I lacked a well-articualted set of issues, and -- more importantly -- I didn't have any sort of an alternative to propose. However, today (some 8-ish years later! 😲) the story changes. Prompted by some happenings at my current client (and a deep sense of guilt over not having done this sooner), I would like to present an approach I feel would have been a better addition to the FSharp.Core 4.1 release. Although I will present it in modern F#, potentially using features not available in 2016, the fundamental core of this approach is valid all the way back to F# 2.

## Some Background

The reader will very likely be familiar with using `Result`, as it is an _incredibly_ common type, which turns up everywhere from input validation to complex domain-state transitions. So, eight years on, what can one really say about `Result<'T, 'TError>`? Well, having it is _definitely_ better than not having it. But, as with all things, there's both good and bad.

### The Good

+ It exists in `FSharp.Core` -- having a common type available everywhere is awesome!
+ After 8 years, it has saturated the ecosystem. This flows from the previous point.
+ Is very minimally defined and, thus, very flexible (but that's a double-edged sword).

Let's see a basic example which showcases `Result`:

```fsharp
let parseCountryCode value =
  try
    if Regex.IsMatch(value, "^[A-Z]{2}$") then
      Ok(Iso2Country value)
    else
      Error(InvalidIso2 value)
  with
  | :? ArgumentNullException
  | :? RegexMatchTimeoutException -> Fail(InvalidIso2 value)
```

Here, some raw `string` is parsed according to a specification. If all is well, then a new type is created from the input and returned, wrapped in `Result.Ok` (to indicate success). However, if there is a problem -- either with input conforming to the specification, or because something went wrong mechanically -- then an error is returned, wrapped in `Result.Error` (to indicate failure). This is reasonably straight-forawrd, but software development is not always so simple. `Result` can also have some significant drawbacks.  

### The Not-So-Good

+ No consistency or guidelines when defining error types.
+ No defense against lazy developers (`string` is actually a worse error type then `exn` 😵).
+ Tedious mappings when combining libraries, especially for application developers.

Let's see some examples of the "not so good" usage of `Result`:

```fsharp
(* !! "stringly-typed" errors !! *)

let validateQuote baseCcy quoteCcy =
  match quoteCcy with
  | SupportedCcy quoteCcy & EqOrdCI baseCcy -> 
      Error $"Cannot use the same currency (%s{baseCcy}) for base and quote."
  
  | SupportedCcy quoteCcy -> Ok quoteCcy

  | _ -> Error $"Quote currency, '%s{quoteCcy}', is unrecogized or unsupported."
```

The problem in the previous function is, hopefully, obvious. Because the error type is a `string`, the _only_ thing the caller can do with it is I/O. That is: it can be written to a log, or surfaced in a graphical user-interface -- but that's it. This function actually encodes domain logic -- then throws it away! If the caller wanted to programmatically "react" in some smarter way, they don't really have any additional information with which to work (unless they start trying to carve the error `string`... but that's a quick trip to the land of madness). Further, because it's just strings everywhere, there's a chance all the carefully-constructed "error novellas" wind up with typos or incorrect details. "Oh, but then I'll put the string in a constant", you say. Really?! Great. Now take the extra 15 seconds and define a type! It can carry data then. Worst case: you make it a struct with no fields and it's basically a cheap placeholder for your error messages (localization, anyone?). Moving on...

This next example is more subtle. However, it is very common -- especially when building an application which pulls together several different 3rd-party libraries, each with their own sense of how to model failure.

```fsharp
(* !! Inconsistent error types !! *)

match atlasClient.FindCountryByName(name) with 
               // ▲▲▲ will return `Result<CountryInfo, AtlasError>`
| Ok country ->
    let ccyPair = { Base = EUR; Quote = country.Currency }
    match ccyPair |> Forex.getRatesForWindow context range with 
                        // ▲▲▲ will return `Result<RateSummary, ForExError>`
    | Ok rateSummary -> 
        Ok {| Country = country.Code; Rates = rateSummary |}
    
    | Error failure -> Error failure
| Error failure -> Error failure // ◀ will NOT compile!
```

If you were to try to use the previous snippet, you would find it does _not_ compile. Specifically, the two different calls (`FindCountryByName` and `getRatesForWindow`), while both returning `Result`, use different types for their errors. So the compiler, understandibly, marks the last line as erroneous. Remember: the entire `match` is a single _expression_, which means all branches through the expression must return the same type. It expected a `ForExError`, but it found an `AtlasError`. Now, there a a few different ways to address this, but they are all cumbersome. Specifically a developer must either:

+ Remap any `ForExError` into a `AtlasError` (how does that even make sense in the domain?!)
+ Remap any `AtlasError` into a `ForExError` (same issue: it's non-sensical in the domain!!)
+ Introduce a _whole new error type_, which encompasses both `ForExError` and `AtlasError`

The last option above is especially sad. It may seem reasonable to do on a one-off basis, but it quickly becomes tedious when you have 2/3/4/5 different types and need to amalgamate them all over a code base. Is it really so surprising, then, that a developer might convert both errors to `string` and call it a day? It'd be lazy and wrong -- but it's what current recommended practice (ie: `Result`) _incentivizes_.

> ---
> **Aside: A Cohesive Approach to Failure**
>
> While this article focuses entirely on how errors are modelled, it should be noted: this is only a small piece of the puzzle. That is, a robust strategy
> for handling _failures_ would encompass much more. Specifically, a library (ideally a foundational one, like FSharp.Core) would need to address the
> following:
>
> + Support the matrix of modes of failing: exceptional vs non-exceptional, and expected vs unexpected
> + Support the mechanisms of communicating failure: stop-the-world, side-effecting, or inline/return
> + Provide a type-based means of coordinating and / or unifying the different modes
> + Cleanly handle transitioning between mechanisms of failing
> + Ensure performance is acceptible (in non-side-effecting scenarios, at least)
>
> A full exploration of these points -- and how to best address them -- is beyond the scope of this article.
> However, I have annecdotal evidence to suggest F#, as part of the .NET ecosystem, has all the building blocks needed.
> What's lacking is a cohesive _treatment_ (APIs, sugaring, documentation, etc).
> Perhaps I will explore this in a future blog post, or possibly an open-source project 🙃.
>
> ---

## What might've been

So, it turns out `FSharp.Core.Result` wasn't _too_ far off. It was a good start, but needs more. Specifically, we _can_ address the limitations mentioned previously, while still retaining the most important benefits. If you look carefully at the limitations listed above, it becomes clear the issues are all around how one models errors. A pragmatic way to address this is by defining a common contract for _all_ failures. That is, we can use an interface to specify the bare minimum we expect when modeling errors.

```fsharp
/// Minimal contract provided by any failure.
[<Interface>]
type IFault =
  /// An unstructured human-readable summary of the current failure.
  abstract Message : string

  /// An optional reference to the failure which triggered the current failure
  /// (n.b. most failure do NOT have a cause).
  abstract Cause : IFault option
```

But simply defining this contract isn't enough. In order to enforce it, we need to rethink our discriminated union slightly (**pay close attention to the generic constraints** -- it's really the linchpin of the whole approach):

```fsharp
type Report<'Pass, 'Fail when 'Fail :> IFault> =
                            // ▲▲▲ tells the compiler to enforce a common contract on all errors

  /// Represents the successful outcome of an operation (i.e. it passed).
  | Pass of value : 'Pass

  /// Represents the unsuccessful outcome of an operation (i.e. it failed).
  | Fail of fault : 'Fail
```

> ---
> **Aside: A note on naming ('cuz it's hard)**
>
> Throughout this article, I use `Result`, or similar, to refer to the type currently shipped in the FSharp.Core library.
> I also use `Report`, or similar, to refer to the aspirationtional type I _wish_ existed in FSharp.Core.
> However, this naming is only to avoid confusion. In reality, the names of the types involved are not terribly important and many variations would be perfectly suitable
> (though I like how `Pass` and `Fail` are: easy to type, have the same length, function as both nouns and verbs, and don't run afoul of established naming conventions in the larger .NET ecosystem 😊).
>
> ---

With these two pieces (`IFault` and `Report`) in place, we have successfully mitigated two of the three previously identified short-comings. Specifically, we now know that any error will, at a minimum, provide: a summary message, and (potentially) a parent fault. This latter property is uncommon in practice, but does facilitate modelling arbitrarily complex sequences of errors. Further, by requiring _any_ explicit contract, we make it that much more difficult for lazy developers to just use "`string`ly-typed" errors. Let's consider a trivial example:

```fsharp
type ForExFault =
  // ... other faults omitted for clarity
  | InvalidQuote of currency : string
  | QuoteIsBase of currency : string
  interface IFault with
    member _.Cause = None
    member me.Message =
      match me with
      // ... other faults omitted for clarity
      | InvalidQuote ccy -> $"Quote currency, '%s{ccy}', is invalid."
      | QuoteIsBase ccy -> $"Cannot use the same currency (%s{ccy}) for base and quote."

let validateQuote baseCcy quoteCcy =
  match quoteCcy with
  | SupportedCcy quoteCcy & EqOrdCI baseCcy -> Fail(QuoteIsBase quoteCcy)
  | SupportedCcy quoteCcy -> Pass quoteCcy
  | _ -> Fail(InvalidQuote quoteCcy)
```

This is very similar to how one might use `Result`, albeit with more attention paid to the design of errors (trust me, this is a _good_ thing 😉). Further, we have now laid the groundwork to better handle combining multiple different types of failures (eg: when combining different libraries in an application). How? By switching from `Report<_, SomeSpecificFaultType>` to `Report<_, IFault>` we can work with various types, without resorting to tedious and error-prone re-mapping code. For example:

```fsharp
match atlasClient.FindCountryByName(name) with 
               // ▲▲▲ will return `Report<CountryInfo, AtlasError>`
| Pass country ->
    let ccyPair = { Base = EUR; Quote = countryInfo.Currency }
    match ccyPair |> Forex.getRatesForWindow context range with 
                        // ▲▲▲ will return `Report<RateSummary, ForExError>`
    | Pass rateSummary -> 
        {| Country = countryInfo.Code; Rates = rateSummary |}  
        |> Pass 
        |> Report.generalize // ◀ lifts the faults to `IFault`

    | Fail fault -> Fail fault
| Fail fault -> Fail fault
```

That's it. We no longer have compiler errors. We haven't had to introduce cumbersome mappings or new types. And we didn't get lazy (no calls to `string` here). "But wait", you say, "you _are_ remapping the error type!" Well, yes; this is true. But it's a mapping common to _all_ uses of `Report`. Developers don't have to spend any cycles thinking about it. It will be the same from library-to-libary and from application-to-application. And, better, `Report.generalize` is a simple function added to a base library (write once; reuse forever). In fact, one possible definition is as follows (type annotations added for explanatory purposes only):

```fsharp
let generalize (report : Report<'Pass, #IFault>) : Report<'Pass, IFault> =
  // NOTE: `#IFault` is just a short-hand for `'T when 'T :> IFault`
  match report with
  | Pass value -> Pass value
  | Fail error -> error :> IFault |> Fail
```

Further, nothing about generalizing to a shared interface _prevents_ any of the techniques one is forced to use with `Result`. If you really want / need to map one failure type to another -- or even introduce a whole new type -- that's still perfectly possible (if seemingly unnecessary).

This is a definite improvement. It's especially useful in situations where the caller will handle all errors the same, regardless of the actual type of failure. One such example is ASP.NET Core Minimal API, where commonly all errors funnel into a single code path (eg, returning a [Problem Details response][3]). However, it's not quite "good enough". We'd still like to have the ability to target specific types of errors, while handling the rest generically. Fortunately, with the addition of a small active pattern, we can. For example:

```fsharp
match name |> fetchRatesForCountry context range with 
| Pass country -> ...
| FailAs(fault : TransportError) -> ...
// ▲▲▲ handle one very specific error type differently
| Fail fault -> ...
// ▲▲▲ handle any other errors identically, as `IFault`
```

In the previous snippet, `FailAs` is an active pattern doing a little type-system slight-of-hand. It performs roughly the _inverse_ of `Report.generalize`. That is, it takes an `IFault` and tries to safely downcast it to a more concrete type. If the downcast holds, the active pattern "matches", returning the concrete type. If the downcast does not hold, we simply proceed to the next case. This approach is roughly analogous to a `try ... with` expression catching specific sub-classes of `exn`, while also having a "catch all" for the base type. Its definition is as follows:

```fsharp
let inline (|FailAs|_|) (report : Report<'Pass, IFault>) : 'Fail option when 'Fail :> IFault =
  match report with
  | Fail(:? 'Fail as fault) -> Some fault
  | _ -> None
```

I know: _technically_ the `FailAs` active pattern is using a run-time type-test (and conversion) -- but the generic constraint discussed previously, when combined with the affordances of a partial active pattern, makes it a "safe enough" downcast. This sort of carefully-balanced trade-off is exactly the pragamtism which has always been at the core of F#'s ethos.

## In Conclusion

So, to recap, we have been able address all of `Result`'s short-comings -- and in a way which still maintains its most important benefits. Further, we were able to accomplish this with only five pieces:

+ An interface
+ A discriminated union
+ A generic type constraint (◄◄◄ _this is the really critical piece!_)
+ A function to simplify upcasting
+ A "safe" down-cast (dressed up as an Active Pattern)

Now, in practice, this approach would also benefit from many more supporting functions (`bind`, `bindFault`, et cetera), a few additional commonly-wanted type definitions (eg: `Demotion`, `CompoundFault`), and possibly even a computation expression. However, those are definitely not the "bare minimum" required to realize the approach.

> ---
> **Aside: What about C#?**
>
> This article has focused entirely on F#. However, all the core elements described above are applicable to C# -- especially if it _ever_ finally
> gets some form of sum type 🙄. Further, it is entirely possible to support C# from F#, through careful adaptation of the `IFault` and `Report` types.
> However, it is not common to adpat F# libraries to support C#. Given this precedent, and the number of trade-offs involved, we won't explore this any further.
>
> ---

Ultimately, much like JavaScript, the true strength of `FSharp.Core.Result` lies in its ubiquity. So, at this point, it's probably not worth the effort to change the whole ecosystem -- but, wow!, the future could've been grand, eh? At least, this is what I ponder every time a library forces me to use `string`ly-typed errors. And for those of you who may want to rumiate further on FaultResult, or adapt it into your own works (or even petition the F# Core team to adopt it formally 😜🤣.. jk), everything discussed in this article (and more!) is available as a [gist][0].

Good luck! And have fun coding!

[0]: https://gist.github.com/pblasucci/7dee5f662956eaaa2ece07dcd9d6488c
[1]: https://github.com/fsharp/fslang-design/issues/49#issuecomment-263686153
[2]: https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/results
[3]: https://www.rfc-editor.org/rfc/rfc7807.html
[4]: https://sergeytihon.com/2024/10/26/f-advent-calendar-in-english-2024/
