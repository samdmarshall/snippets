import macros

macro dsl(body: untyped): untyped =
  echo lispRepr(body)

dsl:
 foo { bar }

