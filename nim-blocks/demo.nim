
{.passL: "-framework Foundation".}
{.compile: "blocks.m".}

type 
  Id {.importc: "id", header: "<objc/NSObject.h>", final.} = distinct int

proc newFoo(): Id {.importobjc: "[Foo alloc] init", header: "blocks.h", nodecl.}
proc description(self: Id): Id {.importobjc: "description", nodecl.}
proc UTF8String(self: Id): cstring {.importobjc: "UTF8String", nodecl.}
proc doubleValueWithBlock(self: Id, value: cdouble, withBlock: proc (value: cdouble): cdouble): int {.importobjc: "doubleValue", nodecl.}

proc add5(a: cdouble): cdouble =
  return cdouble(5.0) + a

when isMainModule:
  let obj = newFoo()
  echo(obj.description().UTF8String())
  echo(obj.doubleValueWithBlock(cdouble(2.5), add5))

