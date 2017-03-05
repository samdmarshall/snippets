
{.passL: "-framework Foundation".}
{.compile: "blocks.m".}

type Foo {.importc: "Foo", header: "blocks.h".} = ptr object

proc allocFoo(): Foo {.importobjc: "Foo alloc", nodecl.}
proc init(self: Foo): Foo {.importobjc: "init", nodecl.}
proc doubleValueWithBlock(self: Foo, value: cdouble, callback: proc (value: cdouble): int): int {.importobjc: "doubleValue", nodecl.}

proc add5(a: cdouble): cdouble =
  return cdouble(5.0) + a

when isMainModule:
  let allocation = allocFoo()
  let obj = allocation.init()
  echo(obj.doubleValueWithBlock(cdouble(2.5), add5))

