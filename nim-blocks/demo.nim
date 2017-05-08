

type BlockPointer = distinct pointer


{.passL: "-framework Foundation".}
{.passC: "-I./".}
{.passC: "-fblocks".}
{.compile: "blocks.m".}

import strutils
import tables
import macros

type 
  Id {.importc: "id", header: "<objc/NSObject.h>", final.} = distinct int

proc newFoo(): Id {.importobjc: "[Foo alloc] init", header: "blocks.h", nodecl.}
proc doubleValueWithBlock(self: Id, value: cdouble, withBlock: BlockPointer): int {.importobjc: "doubleValue", nodecl.}


import macros

proc mangleBlockName(name: string): string {.compileTime.} = 
  return staticExec("md5 -qs " & name)

template CreateBlock(declaredName: string, returnValue: string, parameters: OrderedTable[string, string]): void =
  {.emit: "typedef " & returnValue & " (^" & mangleBlockName(declaredName) & ")();".}
  let 
  {.emit: "static " & mangleBlockName(declaredName) & " " & declaredName & " = ^" & returnValue & "(double a) { return nimCall_" & declaredName & "(" & arguments.join(",") & "); };".}

CreateBlock("add5", "int", @{"a": "double"}.toOrderedTable)

macro importBlock(imp: stmt): stmt = 
  result = newStmtList()
  let prefix = "objcBlockBridge_"
  for i in 0..(imp.len - 1):
    let s = imp[i]
    case s.kind
    of nnkProcDef:
      if s.pragma.kind == nnkEmpty:
        s.pragma = newNimNode(nnkPragma)
      s[4].add(newNimNode(nnkExprColonExpr).add(!"exportc", newStrLitNode(prefix & $ident(basename(name(s))))))
    else:
      discard
    result.add s

  proc add5(a: cdouble): cint =
    return cint(5.0 + a)


when isMainModule:
  let obj = newFoo()
  let block_ptr = cast[BlockPointer](add5)
  echo(repr(block_ptr))
  let output = obj.doubleValueWithBlock(cdouble(2.5), block_ptr)
