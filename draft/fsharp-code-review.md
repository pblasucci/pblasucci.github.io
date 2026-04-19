# Things to Avoid for Better `F#` Code

+ Introduction
  + Context
  + Disclaimers

+ Some general definitions:
  + "library"
  + "application"
  + "public"OK
  + "private"
  + "method"
  + "function"
  + "curried"
  + "tupled"

+ In .NET, generally, avoid:
  1. Stringly-typed errors (ie: "Why do you hate your callers?!")
  1. Primitives with back-door access to underlying data
  1. Skipping **meaningful** XMLDoc comments (public APIs; telling "why" not "how")
  1. Purely-technical code organization

+ In F#, specifically, avoid:
  1. Curried Methods
  1. SRTPs or IWSAMs used to make "typeclassopedia"
  1. Excessive Use of Symbolic Operators (unless germane to the problem domain)
    + Implement operators as a pass-through to named functions
    + If you cannot give the operator a domain-grounded name, it's probably not good to have said operator
  1. Using module conventions to define a contract
  1. Using a Record-of-Functions to define a contract
  1. Not using classes/methods/properties/interfaces ("because OO bad")
  1. API generated from implicit partial application
    + Implicit partial application should only ever be an implementation detail
  1. Library wrappers whose sole purpose is to translate methods into curried functions
    + Somewhat tolerable on a private, one-off, per-project basis -- if it benefits specific call-sites
  1. Missing type annotations on "public"code
    + Consider using a signature file (especially in conjunction with XMLDoc comments)
  1. Unnecessary type annotations on "private" code
