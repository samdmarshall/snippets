import os
import strutils
import tables

proc isDependency(name: string, tree: TableRef[string, seq[string]]): (bool, string)  =
  for pkg, value in tree:
    if value.contains(name):
      return (true, pkg)
  return (false, nil)

let path = expandTilde("~/Desktop/installed.txt")
var contents = newTable[string, seq[string]]()
let fd = open(path)
while not fd.endOfFile():
  let info = fd.readline()
  let deps = info.split(":")
  let name = deps[0]
  var deps_list = newSeq[string]()
  for dep in deps[1..deps.high()]:
    let dep_name = dep.split(" ")
    deps_list.add(dep_name)
  contents[name] = deps_list

for pkg, deps in contents:
  let (isDep, ofPkg) = pkg.isDependency(contents)
  if not isDep:
    echo(pkg)
  # else:
    # echo(pkg & " is a dependency of " & ofPkg)
