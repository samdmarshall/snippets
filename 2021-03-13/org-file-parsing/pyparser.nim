
import os
import sequtils
import strtabs
import xmltree
import htmlgen
import strutils
import options

import nimpy
import commandeer

let py = pyBuiltinsModule()
let orgparse = pyImport("orgparse")
let orgparse_node = orgparse.node #pyImport("orgparse.node")


type
  ToDo_Keywords = seq[string]
  ToDo = tuple[todo: Todo_Keywords, done: ToDo_Keywords]
  CommentLine = tuple[key: string, value: Todo_Keywords]

proc objToSeq(root: PyObject): seq[PyObject] =
  result = newSeq[PyObject]()
  result.add root
  for child in root.children:
    let nodes = child.objToSeq()
    result = result.concat(nodes)

proc renderHtml(nodes: seq[PyObject]): string =
  var meta_tags = newSeq[string]()
  block InitialMetaTags:
    meta_tags.add meta(charset="utf-8")
    meta_tags.add meta(name="viewport", content="width=device-width, initial-scale=1.0, user-scalable=yes")
    # meta_tags.add link(rel="alternate", `type`="application/rss+xml", title="Blog RSS Feed", href="/feed.xml")

  var header_tags = newSeq[string]()
  var body_tags = newSeq[string]()
  var footer_tags = newSeq[string]()
  for node in nodes:
    let level = node.level.to(int)
    case level
    of 0:
      # start of document, before first heading, this should all be metadata comments
      let contents = node.get_body().to(string)
      for line in contents.split(Newlines):
        let parse_result = orgparse_node.parse_comment(line)
        if parse_result != py.None:
          let data = parse_result.to(CommentLine)
          meta_tags.add meta(name=data.key, content=data.value.join(", "))
        else:
          # non-comment line
          discard
    of 1:
      # h1
      let node_title = node.get_heading().to(string)
      body_tags.add h1(node_title)
    of 2:
      # h2
      let node_title = node.get_heading().to(string)
      body_tags.add h2(node_title)
    of 3:
      # h3
      let node_title = node.get_heading().to(string)
      body_tags.add h3(node_title)
    of 4:
      # h4
      let node_title = node.get_heading().to(string)
      body_tags.add h4(node_title)
    of 5:
      # h5
      let node_title = node.get_heading().to(string)
      body_tags.add h5(node_title)
    of 6:
      # h6
      let node_title = node.get_heading().to(string)
      body_tags.add h6(node_title)
    else:
      # header deeper than h6, this should become an unordered list or bolded
      let node_title = node.get_heading().to(string)
      body_tags.add `div`(b(node_title))

  result = html(
    head(meta_tags.join("\n")),
    body(
      header(header_tags.join("\n")),
      `div`(id="documentId", class="document", `div`(class="container", body_tags.join("\n"))),
      footer(footer_tags.join("\n"))
    )
  )

proc main() =
  commandline:
    argument OrgFilePath, string

  if not fileExists(OrgFilePath):
    echo "cannot access file at path: " & OrgFilePath
    quit(QuitFailure)

  try:
    let orgfile = orgparse.load(OrgFilePath)
    let nodes = orgfile.objToSeq()
    let output = renderHtml(nodes)
    echo $output
  except:
    echo getCurrentExceptionMsg()

when isMainModule:
  main()
