

type BlockPointer* = distinct pointer

{.passC: "-I./".}
{.passC: "-fblocks".}
when not defined(macosx):
  {.passL: "-lBlockRuntime".}
{.compile: "blocks.c".}

import sequtils
import strutils
import strformat
import macros

import md5
import std/sha1

#[
proc doubleValueWithBlock(value: cdouble, withBlock: BlockPointer): int {.importc: "doubleValueWithBlock", nodecl.}


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
]#

proc parseReturnType(node: NimNode): string =
  for child in node.children():
    case child.kind
    of nnkEmpty:
      result = "void"
    of nnkIdent:
      result = child.strVal
    else:
      discard
    if result != "":
      break

proc parseArguments(node: NimNode): seq[string] =
  for argument in node.children():
    case argument.kind
    of nnkIdentDefs:
      var argument_counter = 0
      for argument_ident in argument.children():
        case argument_ident.kind
        of nnkIdent:
          let value = argument_ident.strVal
          case value
          of "cint", "cfloat", "cdouble", "cstring", "cbool", "void":
            if value != "void":
              let arguments = sequtils.repeat(value, argument_counter)
              result = concat(result, arguments)
            argument_counter = 0
          else:
            inc(argument_counter)
        else:
          discard
    else:
      discard

proc translateBlock(body: NimNode, prefix: string): NimNode =
  result = newStmtList()
  case body.kind
  of nnkProcDef:
    let name = body.name
    let parameters = body.params
    let return_type = parseReturnType(parameters)
    let arguments = parseArguments(parameters)
    case body.pragma.kind
    of nnkEmpty:
      body.pragma = newNimNode(nnkPragma)
    else:
      discard
    echo body.pragma
      
    echo fmt"""{return_type} {name}({arguments.join(",")})"""
    result.add body
  else:
    discard
#    {.fatal: "The `objcblock` and `cblock` pragmas can only be used on `proc` defintions!".}

macro objcblock*(def: untyped): untyped =
  return translateBlock(def, "objcBlockBridge_")

macro cblock*(def: untyped): untyped =
  return translateBlock(def, "")

proc add5(a: cdouble): cint {.cblock.} =
  result = cint(5.0 + a)


when isMainModule:
  let block_ptr = cast[BlockPointer](add5)
  echo repr(block_ptr)
#  echo doubleValueWithBlock(2.5, block_ptr)
