A Critical Analysis of Single-Case Unions in F#
===

__TL;DR -- alternatives to common uses of SCUs in F#__

_under-developed sum types are fine._

- Singleton Atoms
    - Notes from Pony
    - Example in F#
    - Alternatives:
        - Struct
            - Example
            - Trade-Offs

- Tagged Primitive
    - Notes from Haskell
    - Example in F#
    - Alternatives:
        - Unit of measure
            - Example
            - Trade-Offs
        - Generic tag
            - Example
            - Trade-Offs
        - Or maybe you really want a Value Object?
    - _MAYBE: Does the type being wrapped influence the choice of alternative?_

- Value Object
    - Notes from Visual Basic
    - _MAYBE: sidebar on identifying Value Objects in the domain_
    - Example in F#
    - Alternatives:
        - Using a record or a POCO
            - Example
            - Trade-Offs
        - Whence a record? Whence a POCO?
