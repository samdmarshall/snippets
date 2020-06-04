
switch("cc", "clang")

switch("dynlibOverride", "lua")

switch("passL", "-L/brew/Cellar/lua@5.1/5.1.5_11/lib")
switch("passL", "-llua")

switch("passL", "-Xlinker -rpath")
switch("passL", "-Xlinker /brew/Cellar/lua@5.1/5.1.5_11/lib/")
