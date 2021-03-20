#!/usr/bin/env python3


# import os
# import sys
# import orgparse

# def print_children(node):
#   max_level = node.level
#   parent = node

#   child_count = 0
#   for child in node:
#     if child.level == max_level:
#       child_count += 1
#   return "%i" % child_count

# def print_node(node):
#   level = node.level

#   prefix = ("="*level) + ">"
#   identifier = "{}".format(print_children(node))

#   return prefix+" "+identifier


# def print_levels(orgfile):
#   is_finished = False
#   node = orgfile
#   while not is_finished:

#     # children = []

#     # if not node.is_root():
#     #   print_node(node)

#     #   children = node.children
#     # else:
#     #   children = node.nodes

#     # if len(children) > 0:
#     #     print_children(node)

#     node = node.next_same_level
#     if node is None:
#       is_finished = True

# def print_env(orgfile):
#   result = "File: {node.filename}".format(node=orgfile.env)
#   result += "\n"
#   result += "  Todo: {node.todo_keys}".format(node=orgfile.env)
#   result += "\n"
#   result += "  Done: {node.done_keys}".format(node=orgfile.env)
#   print(result)

# def display_document(orgfile):
#   if orgfile.is_root():
#     print("================================================")

#   print_env(orgfile)
#   # for node in orgfile.env.nodes:
#   #   print(print_node(node))
#   # print_levels(orgfile)

#   print("================================================")



# def main(args=sys.argv):
#   if not len(args) > 1:
#     exit(1)

#   documents = []
#   for path in args[1::]:
#     if os.path.exists(path):
#       root = orgparse.load(path)
#       documents.append(root)

#   for doc in documents:
#     display_document(doc)


# =======
# Imports
# =======

import os
import sys
import pathlib
import argparse
from typing import List, Set, Dict, Tuple, Optional

import orgparse

# =========
# Functions
# =========

def parseOrgFile(filepath: pathlib.Path) -> orgparse.node.OrgRootNode:
  result = None
  if filepath.exists() and filepath.is_file():
    filepath_str = os.fspath(filepath.resolve())
    result = orgparse.load(filepath_str)
  return result

def parse_node(parent_index, child_index, parent, child):
  print(f"#{parent_index} @ {parent.level} : #{child_index} @ {child.level}")
  indent = '  ' * int((parent.level * child.level) / 2)
  print(f"{indent}{child.heading}")

def parse2html(orgfile: orgparse.node.OrgRootNode, css_files, script_files) -> str:
  result = ""
  # ====================
  env = orgfile.env
  keys_todo = env.todo_keys
  keys_done = env.done_keys

  document_nodes = orgfile
  node_index = 0

  for node in document_nodes:
    print(f"#{node_index} @ {node.level} with: {len(node.children)}")
    child_index = 0
    for child in node.children:
      parse_node(node_index, child_index, node, child)
      child_index += 1
    node_index += 1

  # ====================
  return result


def display(orgfile: orgparse.node.OrgRootNode, html_content: str, output_dir: pathlib.Path):
  if not (output_dir is None):
    target = pathlib.Path(orgfile.env.filename).with_suffix(".html")
    print(output_dir.resolve())
    if output_dir.exists() and output_dir.is_dir():
      output = output_dir.joinpath(target.name)
      length = output.write_text(html_content)
      print(f"Wrote {length} bytes to '{output.resolve()}'!")
  else:
    print(html_content)

# ===========
# Entry Point
# ===========

def main():
  parser = argparse.ArgumentParser(prog="org2html")
  parser.add_argument('--version', action='version', version='%(prog)s 0.1.0')
  parser.add_argument("-c", "--css", dest="css", type=pathlib.Path, nargs='*', action="append", help="insert reference to additional CSS file")
  parser.add_argument("-s", "--script", dest="script", type=pathlib.Path, nargs='*', action="append", help="insert reference to additional script file")
  parser.add_argument("orgfiles", metavar="file.org", type=pathlib.Path, nargs='+', help="path to an .org file to convert to an html file")
  parser.add_argument("-o", "--output", type=pathlib.Path, nargs='?', help="write the generated output to a directory instead of stdout")

  arguments = parser.parse_args()

  if not (arguments.output is None):
    if not arguments.output.exists():
      arguments.output.mkdir(parents=True)

  for filepath in arguments.orgfiles:
    orgfile = parseOrgFile(filepath)
    content = parse2html(orgfile, arguments.css, arguments.script)
    display(orgfile, content, arguments.output)

# ========================

if __name__ == "__main__":
  main()
