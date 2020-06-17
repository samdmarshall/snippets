#!/bin/sh
DYLIB_CODE="#define DYLD_INTERPOSE(_replacement,_replacee) \
__attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
__attribute__ ((section (\"__DATA,__interpose\"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

#include <Cocoa/Cocoa.h>

int WTF__system(const char *c) {
	__block char *save_path = calloc(strlen(c)+1, sizeof(char));
	memcpy(save_path, c, strlen(c));
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@\"%s\",getprogname()] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@\"You are calling system(%s)\",save_path];
		[alert runModal];
	});
	return system(c);
}

DYLD_INTERPOSE(WTF__system, system);"

CURRENT_SDK_PATH=`xcrun -sdk macosx --show-sdk-path`
CURRENT_BUILD_PATH=`pwd`
DYLIB_CODE_NAME="system_check"

CLANG_PATH=`xcrun -f clang`

function run_build() {
	cd $CURRENT_BUILD_PATH

	BUILD_ARCH=$1
	
	mkdir $BUILD_ARCH
	cd $CURRENT_BUILD_PATH/$BUILD_ARCH
	
	$CLANG_PATH -x objective-c -arch $BUILD_ARCH $BUILD_FLAGS -isysroot $CURRENT_SDK_PATH -mmacosx-version-min=10.6 -c $CURRENT_BUILD_PATH/$DYLIB_CODE_NAME.m -o $CURRENT_BUILD_PATH/$BUILD_ARCH/$DYLIB_CODE_NAME.o
	$CLANG_PATH -arch $BUILD_ARCH -dynamiclib $CURRENT_BUILD_PATH/$BUILD_ARCH/$DYLIB_CODE_NAME.o -isysroot $CURRENT_SDK_PATH -L$CURRENT_BUILD_PATH/$BUILD_ARCH/ -F$CURRENT_BUILD_PATH/$BUILD_ARCH/ -mmacosx-version-min=10.6 -single_module -compatibility_version 1 -current_version 1 -fobjc-link-runtime -framework Cocoa -o $CURRENT_BUILD_PATH/$BUILD_ARCH/lib$DYLIB_CODE_NAME.dylib
}

function remove_old() {
	BUILD_ARCH=$1
	
	cd $CURRENT_BUILD_PATH/$BUILD_ARCH
	rm -f *
	cd ..
	
	rmdir -p $BUILD_ARCH
}

echo "$DYLIB_CODE" > $CURRENT_BUILD_PATH/$DYLIB_CODE_NAME.m 

echo "Building i386"
run_build i386

echo "Building x86_64"
run_build x86_64

cd $CURRENT_BUILD_PATH

lipo -create $CURRENT_BUILD_PATH/x86_64/lib$DYLIB_CODE_NAME.dylib $CURRENT_BUILD_PATH/i386/lib$DYLIB_CODE_NAME.dylib -output $CURRENT_BUILD_PATH/lib$DYLIB_CODE_NAME.dylib

remove_old x86_64
remove_old i386

echo "now run: \`export DYLD_INSERT_LIBRARIES=$CURRENT_BUILD_PATH/lib$DYLIB_CODE_NAME.dylib;\`"
echo "then launch your desired target from the terminal prompt. (eg: /Applications/Steam.app/Contents/MacOS/steam.sh)"
echo "and watch for the error messages on system() usage ^_^"