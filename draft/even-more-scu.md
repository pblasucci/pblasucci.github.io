Single-Case Unions: a Clarification and a Confession
===

What?! Are we _stiiill_ talking about single-case discriminated unions in F#?

Well... um, yeah. We are. Sorry.

Despite having written [quite a few words][0] about the topic recently, I
realized there was a little bit more I'd like to say about it. Specifically,
I want to clarify a point made, briefly. in the previous article. I've received
several questions about it (all from folks who're generally much cleverer than
me), so follow-up seems worthwhile. Also, I realized the previous post talked a
lot about _not_ using SCUs -- instead suggesting that records, structs, or
tagged types might better serve certain ends. However, I realized there's one
scenario where I will very often _prefer single-case unions_. And I felt I owed
it to the discussion to review said usage in more detail.

### Clarification

In my [last exposition][0], I included an aside titled:

> Why lock the door if you're gonna leave the window wide open?!"

In it, I argued against adding a member called `.Value` to a wrapper type
(whereby the intent is for said member to expose whatever primitive "value" is
being wrapped). For example:

```fsharp
//TODO example of bad code here.
```

Please allow me to explain:

+ This is only in the context of [DDD Value Objects][1].
+ The Value Object _IS_ the "primitive".

In other words, you should not think of it as "exposing the underlying value".
Rather, you want to think in terms of "converting a (domain) primitive to a
different type". This will help with information hiding, and helps guide
consumers in the expected ways of using the value object. The canonical example
of this (for me) is the `System.Guid` type found in the [.NET's standard library][2].
Internally, `Guid` stores data via [several numeric fields][3]. Yet, it doesn't
expose any of them -- because "the guid" is "the primitive". Instead, it has
methods like `.ToString()` and `.ToByteArray()`, which provide conversion into
different "primitive" types. The same might be argued for email address,
currency, or any number of other value objects. Thus, the previous example might
be better coded as follows:

```fsharp
//TODO example of good code here.
```

### Confession



[0]: https://paul.blasuc.ci/posts/really-scu.html
[1]: https://martinfowler.com/bliki/EvansClassification.html
[2]: https://docs.microsoft.com/en-us/dotnet/api/system.guid?view=net-5.0
[3]: https://source.dot.net/#System.Private.CoreLib/Guid.cs,b622ef5f6b76c10a
