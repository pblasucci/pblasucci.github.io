# Things I look for in F# code bases

?? overview ??

## Language-agnostic

1. stringly-typed errors
1. technical code organization
    1. prefer domain-driven organization
1. lack of XMLDoc comments
1. custom primitives with "backdoor access" (eg: `Value` "getter", or `getValue` helper)
    1. prefer type-directed explicit conversions

## Language-specific

1. curried methods
1. "typeclassopedia:" (via SRTPs and / or IWSAMs)
1. excessive use of symbolic operators (unless germane to the problem domain)
    1. aside: if you can give the operator a domain-grounded name, it's probably not a good idea to have the operator
1. using RoF to define _contracts_
    1. prefer interfaces for contracts
1. using modules to define _contracts_
    1. prefer interfaces for contracts
1. avoiding methods / properties (because "OO bad")
1. API generated from _implicit_ parial application
1. unnecessary type annotations in private / internal code
1. missing type annotation on "public" APIs
    1. "public" meaning: caller could be anyone
    1. consider using a signature file (especially is "public" surface is relatively much smaller than non-public bits)
1. wrappers whose sole purpose is to translate tupled methods into curried functions
    1. note: sometimes acceptible on a small-scale per-project basis, particularly in applications
