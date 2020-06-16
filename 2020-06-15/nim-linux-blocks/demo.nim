

type BlockPointer* = distinct pointer

{.passC: "-I./".}
{.passC: "-fblocks".}
when not defined(macosx):
  {.passL: "-lBlocksRuntime".}
{.compile: "blocks.c".}

import sequtils
import strutils
import strformat
import macros

proc doubleValueWithBlock(value: cdouble, withBlock: BlockPointer): cint {.importc: "doubleValueWithBlock", nodecl.}


proc parseReturnType(node: NimNode): string {.compiletime.} =
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

proc parseArguments(node: NimNode): seq[string] {.compiletime.} =
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

proc toCType(nimType: string): string {.compiletime.} =
  case nimType
  of "cdouble":
    result = "double"
  of "cfloat":
    result = "float"
  of "cint":
    result = "int"
  of "cbool":
    result = "bool"
  of "void":
    result = "void"
  of "cstring":
    result = "char *"
  else:
    discard

proc genArgName(num: int): string {.compiletime.} =
  let index = num mod 26
  let count = num div 26
  let alpha = toSeq('a'..'z')
  result = fmt"{alpha[index]}{count}"

proc toParamsDeclaration(arguments: seq[string]): string {.compiletime.} =
  var items = newSeq[string]()
  var index = 0
  while index < len(arguments):
    items.add fmt"{toCType(arguments[index])} {genArgName(index)}"
    inc(index)
  result = items.join(", ")

proc toParamsArgs(arguments: seq[string]): string {.compiletime.} =
  var items = newSeq[string]()
  var index = 0
  while index < len(arguments):
    items.add fmt"{genArgName(index)}"
    inc(index)
  result = items.join(", ")

proc translateBlock(procDef: NimNode, prefix: string): NimNode {.compiletime.} =
  result = newStmtList()
  case procDef.kind
  of nnkProcDef:
    let name = procDef.name
    let parameters = procDef.params
    let return_type = parseReturnType(parameters)
    let arguments = parseArguments(parameters)

    var exportc_expr = newColonExpr(newIdentNode("exportc"), newStrLitNode(fmt"{prefix}{name}_func"))
    procDef.addPragma(exportc_expr)

    var block_typedef = newNimNode(nnkPragma)
    var block_typedef_expr = newColonExpr(newIdentNode("emit"), newStrLitNode(fmt"typedef {toCType(return_type)} (^{name}_block)({toParamsDeclaration(arguments)});"))
    block_typedef.add block_typedef_expr
    
    var block_definition = newNimNode(nnkPragma)
    var block_definition_expr = newColonExpr(newIdentNode("emit"), newStrLitNode(fmt"""static {name}_block {name} = ^{toCType(return_type)}({toParamsDeclaration(arguments)}) {{ printf("arg: %f\n", a0); return {prefix}{name}_func({toParamsArgs(arguments)}); }};"""))
    block_definition.add block_definition_expr

    var block_import = newNimNode(nnkPragma)
    block_import.add newColonExpr(newIdentNode("importc"), newStrLitNode(fmt"{name}"))
    block_import.add newIdentNode("nodecl")

    var block_proc = newProc(name = newIdentNode(fmt"{name}_block"), params = toSeq(parameters.children()), pragmas = block_import)
#    echo fmt"""{return_type} {name}({arguments.join(",")})"""
    result.add block_typedef
    result.add block_definition
    result.add block_proc
    result.add procDef
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
  let block_ptr = cast[BlockPointer](add5_block)
  echo repr(block_ptr)
  echo doubleValueWithBlock(2.5, block_ptr)
