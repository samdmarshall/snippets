
import jscore
import jsffi
import jsconsole
import sequtils
import typeinfo

proc objToSeq(root: JsObject): seq[JsObject] =
  result = newSeq[JsObject]()
  result.add root
  for child in root["children"].items():
    let sub_nodes = child.objToSeq()
    result = result.concat(sub_nodes)

proc main() =
  let orga = require("/brew/lib/node_modules/orga")
  let ast = orga.parse("target.org")
  for node in ast.objToSeq():
    for key in node.keys():
      echo key
    let position = node["position"]
    let start_pos = position["start"]
    let end_pos = position["end"]
    echo $(start_pos["line"].to(int))
    echo "" & start_pos["line"].to(string) & ":" & start_pos["column"].to(string) & " -> " & end_pos["line"].to(string) & ":" & end_pos["column"].to(string) & " : " 

when isMainModule:
  main()
