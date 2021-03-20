
import os
import strutils

import commandeer


type
  OrgNodeType* = enum
    onInvalid,

    onRoot,

    onDirective,

    onHeading,

    onPropertyDrawer,
    onPropertyValue,

    onText,
    onBold,
    onItalic,
    onUnderline,
    onCode,
    onVerbatim,
    onStrikeThrough,
    onSuperScript,
    onSubScript,
    onTimestamp,

    onLink,
    onFootnote,
    onImage,

    onTag,

    onTable,
    onTableRow,

  OrgNode* = object
    case kind*: OrgNodeType
    of onRoot:
      discard
    of onDirective:
      directiveName*: string
      directiveValue*: seq[string]
    of onHeading:
      headingLevel*: int
      headingTitle*: OrgNode
    else:
      discard
    children*: seq[OrgNode]


  OrgFile* = object
    path*: string
    ast*: OrgNode

# proc parseLines()

proc parseFile*(filepath: string): OrgFile =
  result.path = filepath
  result.ast = OrgNode(kind: onRoot, children: @[])
  let contents = readLines(filepath)




proc main() =
  commandline:
    argument OrgFilePath, string

  if not fileExists(OrgFilePath):
    echo "cannot access file at path: " & OrgFilePath
    quit(QuitFailure)

  let orgdoc = parseFile(OrgFilePath)


when isMainModule:
  main()
