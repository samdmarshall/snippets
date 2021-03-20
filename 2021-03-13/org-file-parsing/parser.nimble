
import distros

# Package Metadata

version = "0.1.0"
author = "Samantha Demi"
description = "invoking nim->python bridge to use a module for parsing org files"
license = "BSD-3-Clause"

bin = @["pyparser", "nodejsparser", "jsparser"]

# Dependencies

requires "nim >= 1.4.2"
requires "nimpy"
requires "commandeer"

foreignDep "python3"
