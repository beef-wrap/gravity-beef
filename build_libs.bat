clang -c -g -gcodeview -o gravity-windows.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall gravity\gravity.c

mkdir libs
move gravity-windows.lib libs
