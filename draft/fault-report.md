Fault-Report: an Hypothetical Alternative to ```FSharpResult`2```
===

This blog post is late. Not just days or weeks late. And not just because I promised Vlad and Jimmy I'd write up something back in early 2023 (sorry, gents). No, it's very much later: the approach described herein _should_ have been presented to the FSharp.Core maintainers way back in 2016. After all, that's where this all began. Part of the work for F# 4.1 was to introduce a type for modeling the outcome of an operation which might have either succeeded or failed. The decision was taken to introduce [`Result`][2]:

```fsharp
type Result<'T,'TError> =
    /// Represents an OK or a Successful result. The code succeeded with a value of 'T.
    | Ok of ResultValue:'T

    /// Represents an Error or a Failure. The code failed with a value of 'TError representing what went wrong.
    | Error of ErrorValue:'TError
```

Even back then, I had some [misgivings][1], having worked with similar constructs in various projects over the years. However, at the time of all this development, I only had "feels". I lacked a well-articualted set of issues, and -- more importantly -- I didn't have any sort of an alternative to propose. However, today (some 8-ish years later! 😲) the story changes. Prompted by some happenings at my current client (and a deep sense of guilt over not having done this sooner), I would like to present an approach I feel would have been a better addition to the FSharp.Core 4.1 release. Although I will present it in modern F#, potentially using features not available in 2016, the fundamental core of this approach is valid all the way back to F# 2.

### Some Background

??need to say something about reuslt??

```fsharp
//TODO snippet in action
```

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

So, it turns out ```FSharpResult`2``` wasn't _too_ far off. It was a good start, but needs more. Specifically, we _can_ address the limitations mentioned previously, while still retaining the most important benefits. If you look carefully at the limitations listed above, it becomes clear the issues are all around how one deals with _failures_. A pragmatic way to address this is by defining a common contract for _all_ failures. That is, we can use an interface to specify the bare minimum we except when modeling errors.

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

But simply defining this contract isn't enough. In order to enforce it, we need to rethink our discriminated union slightly (pay close attention to the generic constraints -- it's really the linchpin of the whole approach):

```fsharp
type Report<'Pass, 'Fail when 'Fail :> IFault> =
  /// Represents the successful outcome of an operation (i.e. it passed).
  | Pass of value : 'Pass

  /// Represents the unsuccessful outcome of an operation (i.e. it failed).
  | Fail of fault : 'Fail
```

With these two pieces in place, we have successfully mitigated two of the three previously identified short-comings. Specifically, we now know that any error will, at a minimum, provide: a summary message, and (potentially) a parent fault. This latter property is uncommon in practice, but does facilitate modelling arbitrarily complex sequences of errors. Further, by requiring _any_ explicit contract, we make it that much more difficult for lazy developers to just use "`string`ly-typed" errors. Let's consider a trivial example:

```fsharp
type ParserFault =
  | EmptyInput
  | InvalidSequence of offender : string

  interface IFault with
    member _.Cause = None

    member me.Message =
      match me with
      | EmptyInput ->
          "Parser input must be non-null and contain at least one non-whitespace value."
      | InvalidSequence offender ->
          $"The input sequence: '%s{offender}' is not valid or this parser."

// assume a function `parseInput` with signature: `input : string -> Report<ParserData, ParserFault>`

match parseInput input with
| Pass parsed -> ...
| Fail EmptyInput -> ...
| Fail(InvalidSequence offender) -> ...
```

This is very similar to how one might use `Result`, albeit with more attention paid to the design of errors (trust me, this is a _good_ thing 😉). Further, we have now laid the groundwork to better handle combining multiple different types of failures (eg: when combining different libraries in an application). How? By switching from `Report<_, MyFaultType>` to `Report<_, IFault>` we can work with various types, without resorting to tedious and error-prone re-mapping code. For example:

```fsharp

(* one externally-provided library *)

module Auth =
  let getAccessToken (credentials : OAuthCredentials) : Report<JwtSecurityToken, AuthorizationFault> =
    // ... code elided ...

(* a different externally-provided library *)

module Graph =
  let fetchSubgraph (query : GraphQLRequest) (token : JwtSecurityToken) : Report<'T, GraphQLFault> =
  // ... code elided ...

(* ... elsewhere, in application code ... *)

let subgraph =
  credentials
  |> getAccessToken
  |> Report.generalize
  |> Report.bind (fun token -> token |> fetchSubgraph query |> Report.generalize)

match subgraph with
| Pass graph -> ...
| Fail fault -> ...
```

In the previous code, we can imagine the authorization logic is from one library, while the graph-querying logic is from a different library. Each library works in terms our `Report<_,_>`, but with very different failure types. However, rather than use some bespoke mapping code, we can simply "generalize" the errors into their shared contract. The is exactly what the call to `Report.generalize` does (its signature is `Report<'Pass, 'Faill> -> Report<'Pass, IFault>`). This works well, since we intend to handle failures from either library in the same way. However, what if we want to single-out a specific fault? For instance, ?BLAH?. Could we specially handle just that one case? Turns out, we still can. We can modify the previous code as follows:

```fsharp
match subgraph with
| Pass graph -> ...
| FailAs(???) -> ...
| FailAs(???) -> ...
| Fail fault -> ...
```

In the previous snippet, `FailAs` is an active pattern doing a little type-system slight-of-hand:

```fsharp
let inline (|FailAs|_|) (report : Report<'Pass, IFault>) : 'Fail option when 'Fail :> IFault =
  match report with
  | Fail(:? 'Fail as fault) -> Some fault
  | Fail _
  | Pass _ -> None
```

I know: _techically_ the `FailAs` active pattern is using a run-time type-test (and conversion) -- but the generic constraint discussed previously makes this a "safe enough" downcast. This sort of carefully-balanced trade-off is exactly the pragamtism which has always been at the core of F#'s ethos.


At a minimum:
  + IFault
  + Report<'P, 'F when 'F :> IFault>
  + 3 Active Patterns
  + 3 library functions


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

### Conclusion

Probably not worth the effort to change, at this point -- but, wow, the future could've been grand.

Also: [gist][0]


[0]: https://gist.github.com/pblasucci/7dee5f662956eaaa2ece07dcd9d6488c
[1]: https://github.com/fsharp/fslang-design/issues/49#issuecomment-263686153
[2]: https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/results
[3]: https://learn.microsoft.com/en-us/dotnet/fsharp/style-guide/conventions#error-management
