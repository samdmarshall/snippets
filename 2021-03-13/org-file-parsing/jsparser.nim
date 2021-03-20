

import jsconsole
import jsffi
import dom

const page_contents = staticRead("target.org")


type
  OrgParser {.importjs: "Org.Parser".} = JsObject
  OrgDocument {.importjs, nodecl.} = JsObject
  OrgNode {.importjs: "Org.Node".} = JsObject

proc newOrgParser(): OrgParser {.importjs: "new Org.Parser()".}
proc parse(p: OrgParser, document: cstring): OrgDocument {.importjs: "#.parse(@)".}


proc renderHtml(document: OrgDocument): string =
  discard

proc readyStateChangeHandler(event: Event) =
  let target = cast[JsObject](event.target)
  let document_state = target.readyState.to(cstring)
  if document_state == "interactive":
    console.log("DOM is ready!")
  if document_state == "complete":
    console.log("All resources are ready!")
    let org = newOrgParser()
    let orgfile = org.parse(page_contents)
    console.log(orgfile)

    for node in orgfile.nodes:
      let nodeType = $(node["type"].to(cstring))
      case nodeType
      of "directive":
        let name = node.directiveName.to(cstring)
        let values = node.directiveArguments.to(seq[cstring])
      of "header":
        let level = node.level.to(int)
      of "paragraph":
        discard
      of "inlineContainer":
        discard
      of "text":
        let value = node.value.to(cstring)
      of "italic":
        discard
      of "bold":
        discard
      of "underline":
        discard
      of "dashed":
        discard
      of "link":
        let src = node.src.to(cstring)
      of "code":
        discard
      of "table":
        discard
      of "tableRow":
        discard
      else:
        echo nodeType

when isMainModule:
  console.log("loading page...")
  document.addEventListener("readystatechange", readyStateChangeHandler)
