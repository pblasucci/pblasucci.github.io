Fault-Report: an Hypothetical Alternative to ```FSharpResult`2```
===

This blog post is late. Not days or weeks late. And not because I promised Vlad and Jimmy I'd write up something back in early 2023 (sorry, fellas). No, it's very much later: the approach describes herein should have been presented to the FSharp.Core maintainers way back in 2016. After all, that's where this all began. Part of the work for F# 4.1 was to introduce a type for modelling the outcome of an operation which might have either succeeded or failed. The decision was taken to introduce `Result`:

```fsharp
//TODO snippet from core
//TODO snippet in action
```
Even back then, I had some [misgivings][1], having worked with similar constructs in various projects over the years. However, at the time of all this development, I only had "feels". I lacked a well-articualted set of issues, and -- more importantly -- I didn't have any sort of an alternative to propose.

So, fast-forward to today. Prompted by some happenings at my current client (and a deep sense of guilt over not having done this sooner), I would like to present an approach I feel would have been a better addition to the FSharp.Core 4.1 release.

### Some Background

So, eight years on, what can one really say about `Result<'T, 'TError>`? Having it is _definitely_ better than not having it. But, as with all things, there's both good and bad.

_The Good_
  + It exists in `FSharp.Core` -- having a common type available everywhere is awesome!
  + After 8 years, has saturated the ecosystem. This flows from the previous point
  + Is very minimally defined and, thus, very flexible (double-edged sword?)

_The Not-So-Good_
  + No consistency or guidelines when defining error types
  + No defense against lazy developers (`string` is actually a worse error type then `exn`)
  + Tedious mappings when combining libraries, especially for application developers

```fsharp
//TODO worked example of issues
```

> ---
> **Aside: A Cohesive Approach to Failure**
>
> + Supported mechanisms of failing: stop-the-world, side-effecting, or inline
> + Supported models of failure: exceptional vs non-exceptional, and expected vs unexpected
> + Type-based means of arranging and/or unifying the different models
> + Support conversion between different models
> + Should handle transitioning between mechanisms of failing
> + Should handle transitioning between models of failure
> + Performance shouldn't be too bad in non-side-effecting scenarios
>
> ---

### What might've been

At a minimum:
  + IFault
  + Report<'P, 'F when 'F :> IFault>
  + 3 Active Patterns
  + 3 library functions

> ---
> **Aside: What about C#?**
>
> 1. ``panic!`` gets CompiledName("Panic")
> 1. `IFault.Cause` replaced with `IFault.TryGetCause : [<MaybeNull>] cause : byref<IFault> -> bool`
> 1. `IFault.Cause` becomes type augmentation
> 1. `IReport<_>.Match` uses `Func<_,_>` delegates instead of F# functions
> 1. `Report<_,_>` becomes opaque (gives up inlining, adds active pattern, adds constructor functions)
> 1. Introduce `ReportExtensions` class which adapts `Report` module functions into extension members
> 1. Introduce `FaultExtensions` class which adapts `Fault` module functions into extension members
>
> *-OR-*
>
> 1. Introduce C# library, `fouten.core`, which contains:
>   + `IFault` (with a default implemetation of `TryGetCause`)
>   + `FaultExtensions`
>   + `Demotion`
>   + `Demotion<_>`
>   + `IReport<_>`
>   + `ReportExtensions` (with a nested hidden non-union implementation of `IReport<_>`)
>   + `CompoundFault`
> 1. `fauten` library reference `fauten.core` are builds on it to achieve optimal API
>
> ---

```fsharp
//TODO worked example
```
+ benefits
  + Meets 100% of the same use cases as Result<'T, 'E>
  + Affords a measure of consistency in designing errors
  + Simplifies combining libraries
  + Simplified working with collections

```fsharp
//TODO worked example
```

+ limitations
  + whole new set of types
  + supporting functions/types/etc need to be rewritten
  + harder to "cheat" at error modeling

### Conclusion

Probably not worth the effort to change, at this point -- but, wow, the future could've been grand.

Also: [gist][0]


[0]: https://gist.github.com/pblasucci/7dee5f662956eaaa2ece07dcd9d6488c
[1]: https://github.com/fsharp/fslang-design/issues/49#issuecomment-263686153
