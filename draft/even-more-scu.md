Single-Case Unions: a Clarification and a Confession
===

What?! Are we _stiiill_ talking about single-case discriminated unions in F#?

Well... um, yeah. We are. Sorry.

Despite having written [quite a few words][0] about the topic recently, I
realized there was a little bit more I'd like to say about it. Specifically,
I want to clarify a point made, briefly, in the previous article. I've received
several questions about it (all from folks who're generally much cleverer than
me), so follow-up seems worthwhile.

Also, I realized the previous post talked a lot about _not_ using SCUs --
instead suggesting that records, structs, or tagged types might better serve
certain ends. However, I realized there's one scenario where I will very often
_prefer single-case unions_. And I felt I owed it to the discussion to review
said usage in more detail.

### A Clarification

In my [last exposition][1], I included an aside titled:

> Why lock the door if you're gonna leave the window wide open?!"

In it, I argued against adding a member called `.Value` to a wrapper type
(whereby the intent is for said member to expose whatever primitive "value" is
being wrapped). For example:

```fsharp
type Price =
    private { Value' of decimal }

[<RequireQualifiedAccess>]
module Price =
    let value (price : Price) = price.Value'
    // ⮝⮝⮝ let's have less of this, please.

    (* ... other behaviors elided ... *)

(* ... elsewhere ... *)

let computeLineValue quantity price =
    // let's assume, for argument's sake, this function works in different
    // context where we shift from Domain model to primitive values...
    // since otherwise we'd hide this sort of thing inside our domain types.
    Quantity.value quantity * (price |> Price.value |> float)
```

Please allow me to explain:

+ This is only in the context of [DDD Value Objects][2].
+ The Value Object _IS_ the "primitive".

In other words, you should not think of it as "exposing the underlying value".
Rather, you want to think in terms of "converting a (domain) primitive to a
different context's primitive". This will help with information hiding, and
helps guide consumers in the expected ways of using the value object. The
canonical example of this (for me) is the `System.Guid` type found in the
[.NET standard library][3]. Internally, `Guid` stores data via
[several numeric fields][4]. Yet, it doesn't expose any of them -- because
"the guid" _is_ "the primitive". Instead, it has methods like `.ToString()` and
`.ToByteArray()`, which provide conversion into different "primitive" types.
The same might be argued for email address, currency, or any number of other
value objects. Thus, the previous example _might_ be better coded as follows:

```fsharp
type Price =
  private { Value' of decimal }

  static member op_Explicit (price) = float price.Value'
  // ⮝⮝⮝ this will encourage more direct logic at call sites.

(* ... elsewhere ... *)

let computeLineValue quantity price =
  // let's assume, for argument's sake, this function works in different
  // context where we shift from Domain model to primitive values...
  // since otherwise we'd hide this sort of thing inside our domain types.
  float quantity * float price
```

### And a Confession

After digesting my [previous post][0], you might think I don't use SCUs all
that often, and that I'm not a fan of them. But that's not exactly true. There
is one scenario where I use them quite a bit. That scenario? Type-directed
random data generation with [FsCheck][5].

Very often, I will want to customize how random data is generated for my tests.
FsCheck tends to prefer driving things off of the nominal type of a given test
input. So, it's not uncommon for me to use a single-case union as a thin wrapper
for some bespoke generation logic. "What sort of bespoke generation logic?", you
ask. All sorts. But mainly, whenever I need to limit or direct the values being
generated (but still random-ish-ly?). The key points for consideration are:

+ A need for a real nominal type (an alias or a tag won't cut it).
+ The type's scope is limited to my test suite.
+ The wrapper type only serves to help FsCheck's internal machinery.
+ The wrapper is (almost always) _immediately discarded_.

An example hopefully makes things clear.

Imagine a parsing function which only succeeds on a certain, limited set of
characters. We can use an SCU and a Regex to produce random strings which,
nevertheless, conform to our needs.

```fsharp
type UrlSafeString = UrlSafeString of string

type Generators =
  static member UrlSafeString =
    let isValid value =
      try
        Regex.IsMatch(
          input=value,
          pattern="""\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z""",
          options=RegexOptions.Compiled,
          matchTimeout=TimeSpan.FromSeconds(1.0)
        )
      with _ -> false

    let generate =
      Arb.generate<_>
      |> Gen.where (fun (NonEmptyString value) -> isValid value)
      |> Gen.map   (fun (NonEmptyString value) -> UrlSafeString value)
      // ⮝⮝⮝ FsCheck doesn't have a combinator for performing
      // a filter and a map in a single pass. Thus, pipeline.

    let shrink (UrlSafeString value) =
      value
      |> NonEmptyString
      |> Arb.shrink
      |> Seq.choose (fun (NonEmptyString value) ->
        if isValid value then Some (UrlSafeString value) else None
      )

    Arb.fromGenShrink (generate, shrink)
```

I don't want to go into too much detail about writing generators/shrinkers, as
that's not really the focus of this post. But briefly, the core logic in
`generate` is:

1. Generate a random non-empty string of characters.
1. Only permit generated strings which match our regular expression.
1. Wrap valid values in our single-case union.

Meanwhile, the logic in `shrink` is similar, albeit with sequences of values.

1. Convert from our nominal wrapper to a primitive type known to FsCheck.
1. "Cheat", by using the shrinker built into FsCheck.
1. Discard any shrunken values which do not match our regular expression.
1. Wrap valid values in our single-case union.

We do have a bit of a [Texas two-step][6] (the dance -- not the lottery) with
wrapping and unwrapping as part of the `generate` and `shrink` logic. But
overall, this approach works well for our purposes. We can then use this to
test our hypothetical parser as follows:

> #### Aside
> Let's assume this is a sort of 'oracular' test. That is, maybe our parser is
> _much_ faster than a regular expression -- but we know the regular expression
> to be correct. So we use _it_ to validate the accuracy of our parser.

```fsharp
let ``Can parse valid input`` (UrlSafeString input) =
  let expected = Some input
  let actually = SuperFastParser.TryParse input

  expected = actually
  |@ $"%A{expected} <> %A{actually}"
  |> Prop.collect (input)
```

In the previous code, notice how we don't really interact with the singe-case
union. It's a directive for FsCheck. We _immediately discard it_ in favor of
its randomly-generated inner value. Testing then proceeds as normal (and gives
us some helpful diagnostics, too). It's also important to stress: this technique
of using a single-case union wrapper to direct FsCheck's data generation is _not_
limited to strings. Other common applications include: generating numbers such
that the value is within a fixed range; generating just one case out of a
typical multiple-case discriminated union; and much more! Some cursory searching
of "property-based testing" will, no doubt, provide lots of motivational examples.

### Conclusion

Ultimately, single-case unions are not unlike any other F# language feature.
They have their time and place to shine. But apply them judiciously, and be
sure to avail yourself of the full range of capabilities the language offers.
Above all, _understand the trade-offs inherent to the choices your are making_.
Good luck! And happy coding!


[0]: https://paul.blasuc.ci/posts/really-scu.html
[1]: https://paul.blasuc.ci/posts/really-scu.html#openwindow
[2]: https://martinfowler.com/bliki/EvansClassification.html
[3]: https://docs.microsoft.com/en-us/dotnet/api/system.guid?view=net-5.0
[4]: https://source.dot.net/#System.Private.CoreLib/Guid.cs,b622ef5f6b76c10a
[5]: https://fscheck.github.io/FsCheck/TestData.html
[6]: https://en.wikipedia.org/wiki/Country-western_two-step
