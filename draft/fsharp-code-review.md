# Better `F#` Code through Avoidance

{{What, why: good practices make for good experiences make for good software; Bona fides: F# since 2007; Pro F# since 2009; Mostly pro F# since 2009; Actively coding F# daily; Get paid for: devlopment, training teams, leading teams; open-source contributor; open-source maintainer; F# compiler contributor; Speaker; Co-ran 3 different meet-ups; Co-ran 1 F# conference}}

> ---
>
> ## Disclaimer
>
> ---

{{Context: professional software development, start-ups and enterprises, domains generally don't have ultra-high-perf requirements (fast is nice; but correct is a must), teams are typically 3+ (and expected to be able to grow) and/or have lots of rotations, code can run for months, code can live for years and years, tooling-friendly is important, NOT GAMING}}

## Some Useful Terms and Definitions

+ "application" ... any collection of code meant to be run on its own
+ "library" ... any reusable collection of code not meant to be run on its own
+ "public" (of an API) ... you have no idea who the consumers might be
+ "private" (of an API) ... you know, and can exert control over, the consumers
+ "function" (in F#) ... unit of behavior, usually let-bound in a module or class
+ "method" (in F#) ... unit of behavior attached to some type (Remember: in F# modules are *not* types)
+ "curried" (style in F#) ... `(a -> b -> c)` is really `(a -> (b -> c))`, i.e. each multi-argument function is really just a chain of single-argument functions (and each function returns a single output)
+ "tupled" (style in F#) ... `(a * b -> c)` is just `(a * b -> c)`, i.e. a multi-argument function takes several inputs and returns a single output.

## .NET Guidelines

1. ✘ Stringly-typed errors (ie: "Why do you hate your callers?!")
1. ✘ Primitives with back-door access to underlying data
1. ✘ Skipping **meaningful** XMLDoc comments (public APIs; telling "why" not "how")
1. ✘ Purely-technical code organization

## F#-Specific Guidelines

1. ✘ Curried Methods
1. ✘ SRTPs or IWSAMs used to make "typeclassopedia"
1. ✘ Excessive Use of Symbolic Operators (unless germane to the problem domain)
    + Implement operators as a pass-through to named functions
    + If you cannot give the operator a domain-grounded name, it's probably not good to have said operator
1. ✘ Using module conventions to define a contract
1. ✘ Using a Record-of-Functions to define a contract
1. ✘ Not using classes/methods/properties/interfaces ("because OO bad")
1. ✘ API generated from implicit partial application
    + Implicit partial application should only ever be an implementation detail
1. ✘ Library wrappers whose sole purpose is to translate methods into curried functions
    + Somewhat tolerable on a private, one-off, per-project basis -- if it benefits specific call-sites
1. ✘ Missing type annotations on "public"code
    + Consider using a signature file (especially in conjunction with XMLDoc comments)
1. ✘ Unnecessary type annotations on "private" code




✔ = u2714
✘ = u2718
