
import unittest
import math

import lua
import luna
import bridgelua


suite "Lua -> Nim":

  test "Call Nim Function":
    let L = newstate()
    openlibs(L)

    proc subtract(a, b: cint): cint {.bridgeLua.} =
      result = a - b

    proc addition(a: cint, b: cint): cint {.bridgeLua.} =
      result = a + b

    proc round(a: cfloat): cint {.bridgeLua.} =
      result = int(round(a))

    proc noop1() {.bridgeLua.} =
      break

    proc noop2(): void {.bridgeLua.} =
      break

    proc noop3(void) {.bridgeLua.} =
      break

    proc noop4(void): void {.bridgeLua.} =
      break

    let lua_code = "print(addition(1,2))"
    discard dostring(L, lua_code)


suite "Nim -> Lua":

  test "Call Lua Function":
    let L = newstate()
    openlibs(L)

    let lua_code = """
    function lua_sum_values(a, b)
      return a+b
    end
    """

    discard dostring(L, lua_code)

    let lv1 = LuaVal(kind: LVNumber, n: 3)
    let lv2 = LuaVal(kind: LVNumber, n: 4)
    let lua_value: LuaVal = callLuaFunc(L, "lua_sum_values", [lv1, lv2])

    let value_str = stringifyLuaVal(lua_value)
    assert(value_str == "7.0")
