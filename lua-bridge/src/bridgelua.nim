
# =======
# Imports
# =======

# Standard Library Imports
import macros
import sequtils
import strutils
import strformat


# Third Party Package Imports
import lua
import luna

# =============
# Functionality
# =============

proc printChildren(node: NimNode, indent: int) =
  let indentation = repeat("  ", indent).join("")
  for child in node.children():
    case child.kind
    of nnkNone, nnkEmpty, nnkNilLit:
      echo fmt"{indentation}{child.kind}"
    of nnkCharLit..nnkUInt64Lit:
      echo fmt"{indentation}{child.kind}: {child.intVal}"
    of nnkFloatLit..nnkFloat64Lit:
      echo fmt"{indentation}{child.kind}: {child.floatVal}"
    of nnkStrLit..nnkTripleStrLit, nnkCommentStmt, nnkIdent, nnkSym:
      echo fmt"{indentation}{child.kind}: {child.strVal}"
    else:
     echo fmt"{indentation}{child.kind}: ..."
     printChildren(child, indent + 1)

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
          of "cint", "cfloat", "cstring", "bool", "void":
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

proc bridgeNimFunction(procDef: NimNode) =
  let func_name = procDef.name
  let parameters = procDef.params
  let return_type = parseReturnType(parameters)
  let arguments = parseArguments(parameters)
  echo fmt"{return_type} {procDef.name}({arguments})"
  #TODO: Implement the glue code to attach the lua C interface to the nim function

  #[
    register(L, fmt"{procDef.name}", proc)

    var arg: array[0..len(arguments)]
    var argument_index = 0
    for argument in arguments:
      case argument
      of "cint":
        arg[argument_index] = tointeger(L, argument_index)
      of "cfloat":
        arg[argument_index] = tonumber(L, argument_index)
      of "cstring":
        arg[argument_index] = tostring(L, argument_index)
      of "bool":
        arg[argument_index] = toboolean(L, argument_index)
      else:
        discard
      inc(argument_index)

    block "Return Value":
      case return_type
      of "cint":
        pushinteger(L, result)
      of "cfloat":
        pushnumber(L, result)
      of "cstring":
        pushstring(L, result)
      of "bool":
        pushboolean(L, result)
      else:
        discard
  ]#

macro bridgeLua*(definition: untyped) =
  case definition.kind
  of nnkProcDef:
    bridgeNimFunction(definition)
  else:
    discard
