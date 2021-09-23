Growing a Gilded Rose, Part 2: Next Year's Model
===

This is part two-of-six in the series, [_Growing a Gilded Rose_][0]. Over the
course of these six blog posts, I hope to demonstrate incrementally improving
a legacy code base which has thorny requirements, while also presenting a few
different software development tools or concepts. The full series is as follows:

1. [Make it Testable][1]
1. **This Year's Model** (this post)
1. [When Worlds Collide][3]
1. [A New Requirement Appears][4]
1. [Bonus: F# All the Things!][5]
1. [Bonus: Meh... C# Can Do That, Too][6]

![Solution Evolution][sln]

### Overview

So [last time][1], we got acquainted with our problem domain, the
[Gilded Rose Kata][12]. We made a tiny change to the existing code to enable a
very crude sort of [approval test][10]. Then using this test to guide us, we made
another small change. This one enabled us to write a few
[property-based tests][11]. We tested nine properties in total, based on the
observed behavior of the program and an informal explanation, which we received
as part of the overall requirements. But it's all been very casual, so far.

The code, as it stands at the end of the previous post, is available in the
[companion repository][7], in a branch called [`1_testable`][8].

In this post, we'll build on our previous work to define a proper _domain model_.
That is, we will make explicit, in code, the important business details, which
until now have been merely implicit in the behavior of the legacy software.
Further, we will extend our suite of tests to exercise the logic of our model.
It's also worth noting what we _won't_ do. Specifically, we won't touch the
legacy code at all!

### Adding a Model

To begin working on our domain model, we will add a new F# library project to
our existing solution. We're forced to do this because you cannot mix C# and F#
in the same unit of compilation (also referred to as a "project"). The library,
though, requires no special configuration or any extra references. Further the
project itself only contains two files:

+ `Inventory.fsi`, an F# _signature file_.
+ `Inventory.fs`, an F# _source file_.

---

> #### Seeing Double, or, Why Are There Two Files?!
>
> The naming and ordering of these two files is very intentional. They exist as
> two parts of whole. Specifically: the signature file contains the publicly
> consumable types and behaviors, while the source file provides the actual
> implementation details. In other words, any code in the source -- but _not_ in
> the signature file -- is only "visible" within said source file. Other files
> in the same project and, more importantly, other code bases which consume this
> library will _only_ know about what's listed in the signature file. Of course,
> the signature file isn't required; but it confers some nice benefits. We can
> maintain explicit control over the public API -- without cluttering the
> implementation with type info. Similarly, we don't have to scatter `private`
> or `internal` access modifiers all over the place. [XMLDoc comments][22] can
> also be lifted out of the way of actual logic. It enables a form of data
> hiding not otherwise possible in F#. And recent versions of IDEs and editors
> perform faster when very large source files also have a signature file
> (especially, if much of the implementation is not public).

---

As for the actual model, carefully re-reading [the description][12] brings to
light a few different requirements:

1. Each inventory item has one, and only one, "kind".
1. Most items have a "quality", which changes over time.
1. Quality is a constrained value.
1. Some item's have a quality which does _not_ change.
1. Unchanging qualities do not have the same constraints as those which change.
1. Most items have an "age", some do not.
1. An item's quality is updated using rules specific to its kind.

Further buried in the actual implementation of `UpdateQuality` are other facts:

8. An item's kind is determined by its "name", which never changes.
8. When an item's quality is updated, so too is its age.
8. Item's are aged one whole (integral) "day" at a time.

Working through the signature file (from top to bottom) we can see all of these
points addressed with five relatively simple constructs. First, we have a
[unit of measure][16]:

```fsharp
/// A common unit of time (n.b. "business day" -- not necessarily a "solar day").
type [<Measure>] days
```

We'll use this to distinguish an item's age, which we'll actually call "Sell In",
so as to be consistent with the vocabulary used by domain experts (i.e. other
Gilded Rose employees). This will help to address point ten from the previous
list.

Then we define a [struct][17] to represent the constrained _value_ of an item:

```fsharp
/// The value of a ordinary item
/// (n.b. constrained within: 0 .. 50 "units", inclusive).
[<Struct>]
type Quality =
  private { Value : uint8 }

  /// The smallest possible value of a Quality (0 "units").
  static member MinValue : Quality

  /// The largest possible value of a Quality (50 "units").
  static member MaxValue : Quality

  /// Constructs a Quality from the given value
  /// (n.b. overlarge inputs are truncated to Quality.MaxValue).
  static member Of : value : uint8 -> Quality

  /// Defines an explicit conversion of a Quality to an unsigned 8-bit integer.
  static member op_Explicit : Quality -> uint8

  /// Adds two Quality values
  /// (n.b. result does not overflow, but is truncated to Quality.MaxValue).
  static member ( + ) : left : Quality * right : Quality -> Quality

  /// Subtracts two Quality values
  /// (n.b. result does not underflow, but is truncated to Quality.MinValue).
  static member ( - ) : left : Quality * right : Quality -> Quality
```

This is very much in the vein of a "Value Object", as one might find in
literature about [Domain Driven Design][15]. It actually follows a coding style
I've [written about][13], a few times, [in the past][14]. It defines a primitive type which:

+ has a minimum value
+ has a maximum value
+ can be increased or decreased
+ can be converted to or from a `uint8` (i.e. an 8-bit whole number).

The most important detail of this type is that values are truncated on both the
high and low ends. That is, rather than having operations like addition and
subtract "wrap around" (e.g. `49 + 3 = 2`), we simple "cap" at `MinValue` or
`MaxValue` (e.g. `49 + 3 = 50`) We can see how this is achieved in this excerpt
from `Inventory.fs` (n.b. comments added solely for this blog post):

```fsharp
// ... other functionality elided ...

static member Of(value) =
  // Internally we store values in a `byte`. Since the smallest possible
  // value for a `byte` (0) is also the smallest possible value for a
  // `Quality`, on construction we only have to guard against over-large
  // inputs, which we truncate to `Quality.MaxValue` (50).
  { Value = min value 50uy }

static member ( + ) (left, right) =
  let sum = left.Value + right.Value
  // ⮟⮟⮟ simple check for "wrap around"
  if sum < left.Value then Quality.MaxValue else Quality.Of(sum)

static member ( - ) (left, right) =
  let dif = left.Value - right.Value
  // ⮟⮟⮟ simple check for "wrap around"
  if left.Value < dif then Quality.MinValue else Quality.Of(dif)
```

Returning to our signature file, we also define a struct for our "constant"
value, though it requires significantly less functionality:

```fsharp
/// The value of an extraordinary item (80 "units", always).
[<Struct>]
type MagicQuality =
  /// Defines an explicit conversion of a MagicQuality to an unsigned 8-bit integer.
  static member op_Explicit : MagicQuality -> uint8
```

Next, we make, perhaps, the most important change from the legacy code. We
explicitly codify the various "kinds" of inventory items. To recap, this is
how an `Item` is defined in the original program (and remember, we _cannot_
change this, lest we ire the goblin in the corner):

```csharp
public class Item
{
    public string Name { get; set; } = "";

    public int SellIn { get; set; }

    public int Quality { get; set; }
}
```

However, when we re-read the description of the system, we find no less than
four different types of inventory. As these are mutually exclusive, we can
neatly describe the whole lot with a [discriminated union][18]:

```fsharp
/// Tracks the category, name, value, and "shelf life" of any inventory.
type Item =
  /// An item with a constant value and no "shelf life".
  | Legendary of name : string * quality : MagicQuality

  /// An item whose value decreases as its "shelf life" decreases.
  | Depreciating of name : string * quality : Quality * sellIn : int32<days>

  /// An item whose value increases as its "shelf life" decreases.
  | Appreciating  of name : string * quality : Quality * sellIn : int32<days>

  /// An item whose value is subject to complex, "shelf life"-dependent rules.
  | BackstagePass of name : string * quality : Quality * sellIn : int32<days>
```

Effectively, each kind of inventory item gets its own "variant" (or "case" or
"label"), plus any relevant data. It is important to note, conceptually:
_this is still only one type_. But it can exist in exactly one of these four --
and _only_ these four -- states. Further, though we may refer to the field as
"age" or "shelf life" elsewhere, here we use the term `sellIn`, as this
reflects usage in both the legacy code and by domain experts (i.e. other
Gilded Rose inn employees).

So far, we've address roughly 7 or 8 of the 10 requirements listed above.
All of the remaining behavior will be accounted for in a single function, given
at the end of the signature file as:

```fsharp
/// Change the quality and "shelf life" for an Item
/// (i.e. apply appropriate rules for the passage of a single "business day").
val updateItem : item : Item -> Item
```

This seemingly simple fellow is somewhat analogous to the body of the `foreach`
loop in the original code's `UpdateQuality` method. That is, it operates on a
single inventory item. However, rather than modifying the item in place, it
takes an item as input and returns a _new item_ as output. Given the immutable
nature of discriminated unions, this is hardly surprising. However, this also
makes it easier to reason about and test the code. Let's now jump back to the
implementation file and see the details. The function, in its entirety, is as
follows (we'll break it down immediately after):

```fsharp
let updateItem item =
  // advance the "shelf life" clock by a single day
  let (|Aged|) sellIn = Aged(sellIn - 1<days>)

  // items with negative "shelf life" gain/lose value twice as quickly
  let rateOfChange sellIn = if sellIn < 0<days> then 2uy else 1uy

  match item with
  | Legendary _ -> item

  | Depreciating (name, quality, Aged sellIn') ->
      let quality' = quality - Quality.Of(rateOfChange sellIn')
      Depreciating(name, quality', sellIn')

  | Appreciating (name, quality, Aged sellIn') ->
      let quality' = quality + Quality.Of(rateOfChange sellIn')
      Appreciating(name, quality', sellIn')

  | BackstagePass (name, quality, sellIn & Aged sellIn') ->
      let quality' =
        if sellIn' < 0<days> then
          Quality.MinValue
        else
          //  NOTE
          //  ----
          //  Pass quality has a "hard cliff", based on "shelf life".
          //  However, until then, its value is calculated against
          //  the _current_ expiry (i.e. before advancing the clock).
          quality + Quality.Of(
            match sellIn with
            | days when days <=  5<days> -> 3uy
            | days when days <= 10<days> -> 2uy
            | _                          -> 1uy
          )
      BackstagePass(name, quality', sellIn')
```

The implementation begins by defining two helpers:

+ an [active pattern][20] for reducing the "shelf life" of an item
+ a function to determine how quickly an item's quality will degrade.

```fsharp
// advance the "shelf life" clock by a single day
let (|Aged|) sellIn = Aged(sellIn - 1<days>)
```

This single-case total active pattern works more-or-less like an ordinary
function (in fact, you could use it that way if you really wanted). It takes
a number of `days` as input, and returns that number reduced by one day. But,
by making it an active pattern, we can perform this operation _anyplace where
one might pattern match!_

```fsharp
// items with negative "shelf life" gain/lose value twice as quickly
let rateOfChange sellIn = if sellIn < 0<days> then 2uy else 1uy
```

This function helps determine how quickly an item's `Quality` increases or
decreases. It's basically a multiplier, such that when an item's "shelf life"
is negative, things change twice as fast. In any other case, value is altered
at the normal rate (i.e. changed by one "unit").


---

> #### Future Evolution
>
> Since active patterns work more-or-less the same as regular functions, it
> would be a rather nice (and fairly simple) improvement to have both the
> "aging" pattern and the `rateOfChange` function become parameters which are
> passed _into_ the `updateItem` function.
>
> This enhancement is left as an exercise to the reader.

---


Next, we have a [match expression][19], which takes different actions based on
the kind of inventory item passed into the function. Notice the symmetry
between the definition of `Item` and how we pattern match against an instance
of it. This effectively replaces the many many `if` statements in the legacy
code. And it no longer requires potentially fragile `string` comparisons in
order to make decisions. Further, it groups together related bits of logic.
Let's consider each case in turn.

```fsharp
match item with
| Legendary _ -> item
```

This one is straight-forward. To quote the initial project description:

> ... a legendary item, never has to be sold or decreases in Quality.

Basically, being given a `Legendary` item is a non-operation. So we immediately
return the input data exactly as we received it. Then things gets more
interesting.

```fsharp
match item with
// ... other code elided ...

| Depreciating (name, quality, Aged sellIn') ->
    let quality' = quality - Quality.Of(rateOfChange sellIn')
    Depreciating(name, quality', sellIn')
```

`Depreciating` items are those items whose value decreases every time the "shelf
life" decreases. First, we extract the `name` and `quality` fields. Technically,
we also extract the `sellIn` field. But that's hidden behind an invocation of
the `(|Aged|)` active pattern, which is giving us a _new_ "shelf life", bound to
`sellIn'`, which has _already_ been reduced by one day. Effectively, we "advance
the clock" at the same time as decomposing the item into its constituent parts.
Then, with the help of the `rateOfChange` function we defined earlier, we make
a new value (`quality'`), which has been appropriately reduced. Finally, we
package up the `name`, the reduced quality, and the aged "shelf life" into a
new instance of a `Depreciating` item. And, as this is the last expression in
the current code path, it becomes a return value for the overall function.

Next, we have `Appreciating` items, which are very similar to `Depreciating`
ones. However, in this variant, the relationship between time and value is
_inverted_. When "shelf life" decreases, quality _increases_.

```fsharp
match item with
// ... other code elided ...

| Appreciating (name, quality, Aged sellIn') ->
    let quality' = quality + Quality.Of(rateOfChange sellIn')
    Appreciating(name, quality', sellIn')
```

This is a simple matter of using addition, where we'd previously used
subtraction, to produce a new value for the item. It is interesting to note:
the `rateOfChange` helper function is still used in _exactly_ the same way.

Finally, we arrive at the branch for the inventory item type with the most
complex update logic: backstage passes. A `BackstagePass` increases in value
by several different increments, depending on its "shelf life". However, it
also ceases to be worth _anything_, after a certain point-in-time. We start by
decomposing the item into its constituents.

```fsharp
match item with
// ... other code elided ...

| BackstagePass (name, quality, sellIn & Aged sellIn') ->
```

However, unlike the previous cases, here we extract _two_ values for the item's
"shelf life". `sellIn` is the value which was passed into the `updateItem`
function. That is, it's the age _before_ "advancing the clock". Meanwhile,
`sellIn'` is the newly advanced age, and it comes from the `(|Aged|)` active
pattern (just as we did for depreciating and appreciating items).

---

> #### And, Per Se, What Now?!
>
> The [ampersand][21] operator (`( & )`) is used to combine patterns in F#.
> Normally, pronounced "and", it is the logical dual of the vertical bar
> operator (`( | )`), which is pronounced "or". Effectively, the ampersand tells
> the compiler a match is only valid if the input succeeds on _both_ sides of
> the operator. Further, you may combine as many ampersands as you'd like
> against a single operand (and they _all_ have to succeed for the match to be
> valid).

---

Next, we have to determine the updated value of the item's quality. This is a
bit non-obvious, as it requires _first_ checking the _updated_ "shelf life".

```fsharp
let quality' =
  if sellIn' < 0<days> then
    Quality.MinValue
```

If we're passed the day of the show for which the `BackstagePass` grants access,
it's not worth _anything_. So, the pass's new worth (`quality'`) is just set to
`Quality.MinValue` (which happens to be zero units). However, if the show's
not-yet-started, things get more complex. We increase the item's worth. But the
amount of increase is determined by the "shelf life" _before_ any aging has
taken place.

```fsharp
let quality' =
  // ... code elided ...
  else
    //  NOTE
    //  ----
    //  Pass quality has a "hard cliff", based on "shelf life".
    //  However, until then, its value is calculated against
    //  the _current_ expiry (i.e. before advancing the clock).
    quality + Quality.Of(
      match sellIn with
      | days when days <=  5<days> -> 3uy
      | days when days <= 10<days> -> 2uy
      | _                          -> 1uy
    )
```

Thus, quality is incremented by three units when the show is less than six days
away. The increment falls to two units when the show is less then eleven days
away. Finally, if we've got more than ten days to wait, the backstage pass will
increase by one unit.

```fsharp
BackstagePass(name, quality', sellIn')
```

We conclude the current branch (and the `updateItem` function) by building and
returning a new `BackstagePass` instance, comprised of the original item's
`name`, the increased -- or worthless! -- quality, and the aged "shelf life".

### Testing a Model

Now that we've formalized the domain logic, it behooves us to test everything.
Again, we will leverage property-based testing. In fact, we will duplicate the
existing tests, "re-phrasing" them in terms of our new model. As this winds up
being a useful-but-rote conversion, we won't explore it here. Instead, we will
highlight one very interesting deviation.

---

> #### Show Me the Code!!!
>
> Readers curious about the reworked tests are encouraged to review the
> [previous entry][31] in this series. Also, the following table enumerates the
> tests, with links to both the previous and current iterations:
>
> Name                                                                 | No Model     | F# Model
> ---------------------------------------------------------------------|:------------:|:-----------:
> `after +N days, Legendary item is unchanged`                         | [before][23] | [after][33]
> `after +N days, ordinary item has sellIn decreased by N`             | [before][24] | [after][34]
> `after +N days, depreciating item has lesser quality`                | [before][25] | [after][35]
> `after +1 days, depreciating item has 0 <= abs(quality change) <= 2` | [before][26] | [after][36]
> `after +N days, appreciating item has greater quality`               | [before][27] | [after][37]
> `after +1 days, appreciating item has 0 <= abs(quality change) <= 2` | [before][28] | [after][38]
> `after +1 days, backstage pass has no quality if sellIn is negative` | [before][29] | [after][39]
> `after +1 days, backstage pass has quality reduced by appropriately` | [before][30] | [after][40]

---

Perhaps the most obvious -- but most significant -- change in the new model is
the creation of the `Quality` type. This value object encodes logic which was
previously only _manifest_ in the behavior of the `UpdateQuality` method. This
change also gives rise to an important change in the test suite. Instead of one
single test ([`after +N days, ordinary item has 0 <= quality <= 50`][32]),
included in `UpdateQualitySpecs.fs`, we have an entire set of new assertions
around the behavior of the `Quality` type. Specifically, we ensure that creation,
addition, and subtraction all uphold our invariants (i.e. never less than 0 and
never more than 50). The portions of `QualitySpecs.fs` covering the classical
arithmetic properties of addition are as follows (comments added for this post):

```fsharp
module QualitySpecs =
  // ... other tests elided ...

  [<Property>]
  let ``additive identity holds`` quality =
    // incrementing by nothing is a non-operation ... A + 0 = A
    quality + Quality.MinValue = quality

  [<Property>]
  let ``addition is commutative`` (quality1 : Quality) (quality2 : Quality) =
    // ordering of operands does NOT matter ... A + B = B + A
    quality1 + quality2 = quality2 + quality1

  [<Property>]
  let ``addition is associative``
    (quality1 : Quality)
    (quality2 : Quality)
    (quality3 : Quality)
    =
    //  grouping of operands does NOT matter ... A + (B + C) = (A + B) + C
    quality1 + (quality2 + quality3) = (quality1 + quality2) + quality3

  // ... other tests elided ...
```

So, not only have we made explicit some key behavior in the system, but also we
have greatly increased our confidence in the logical soundness of that behavior.

### Conclusion

Building on previously gained insights, we've now:

+ Formally codified the program's behavior into a domain model.
+ Expanded and further improved the soundness of our test coverage.

And all of the code listed above, plus several other bits and bob, may
be found in the [companion repository][7], in a branch called [`2_model-fs`][9].

It might not seem like it, but we've come a very long way in a very short period
of time. Having all the pieces in place means we're now ready to start adding
new features. Weeeeeell, we're _almost_ ready. But not quite. &#x1F609; Before
we add support for new "conjured" items, we need to integrate the F# model into
our C# program, which is the subject of the [next blog post][3].


[0]: ./grow-a-rose.html
[1]: ./rose-1-testable.html
[2]: ./rose-2-model-fs.html
[3]: ./rose-3-coalesce.html
[4]: ./rose-4-extended.html
[5]: ./rose-5-fs-alone.html
[6]: ./rose-6-model-cs.html
[7]: https://github.com/pblasucci/GrowningGildedRose
[8]: https://github.com/pblasucci/GrowningGildedRose/tree/1_testable
[9]: https://github.com/pblasucci/GrowningGildedRose/tree/2_model-fs
[10]: https://github.com/pblasucci/GrowningGildedRose/blob/1_testable/source/GildedRose.Test/ProgramTests.fs#L17
[11]: https://github.com/pblasucci/GrowningGildedRose/blob/1_testable/source/GildedRose.Test/UpdateQualitySpecs.fs#L15
[12]: https://github.com/NotMyself/GildedRose
[13]: ./really-scu.html#valueobject
[14]: ./even-more-scu.html#a-clarification
[15]: https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215
[16]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure
[17]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/structures
[18]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/discriminated-unions
[19]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/pattern-matching
[20]: https://www.youtube.com/watch?v=Q5KO-UDx5eA
[21]: https://en.wikipedia.org/wiki/Ampersand#Etymology
[22]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/xml-documentation
[23]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L24
[24]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L44
[25]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L86
[26]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L104
[27]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L122
[28]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L140
[29]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L158
[30]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L177
[31]: ./rose-1-testable.html#adding-property-based-tests
[32]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/UpdateQualitySpecs.fs#L65
[33]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L20
[34]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L35
[35]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L50
[36]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L65
[37]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L80
[38]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L95
[39]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L110
[40]: https://github.com/pblasucci/GrowningGildedRose/blob/2_model-fs/source/GildedRose.Test/InventorySpecs.fs#L127

[sln]: ../media/rose-2-sln.jpg
