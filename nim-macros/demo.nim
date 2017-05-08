import macros


macro appendExportPragma(body: NimNode): untyped =
  echo(body.kind)

macro exportForBlock(body: untyped): untyped =
  for index in 0..(body.len-1):
    let node = body[index]
    case node.kind
    of nnkSym:
      appendExportPragma(node.symbol.getImpl())
    else:
      discard
  return body

exportForBlock:
  proc foo(a: int): int =
    return a + a

when isMainModule:
  echo("Hello world!")      
  discard foo(1)
