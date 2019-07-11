# JNI

https://stackoverflow.com/questions/5963266/call-c-function-from-java
http://nerdposts.blogspot.com/2010/10/jni-mac-os-x-simple-sample.html
class HelloWorld {
    private native void print();

    public static void main(String[] args) {
        new HelloWorld().print();
    }

    static {
        System.loadLibrary("HelloWorld");
    }
}
两种加载方式:

1. System.load("/absolute/path/to/file.suffix")

2. System.loadLibrary("HelloWorld"); - no lib prefix, no .so suffix
-Djava.library.path=/path/to/lib/directory

javac HelloWorld.java
javah -jni HelloWorld
java HelloWorld

mac:
name: lib<name>.dylib or lib<name>.jnilib
cc -c -I $JAVA_HOME/include -I $JAVA_HOME/include/darwin HelloWorld.c
cc -dynamiclib -framework JavaVM HelloWorld.o -o libhelloworld.jnilib
合并成一个命令 `cc -dynamiclib -I $JAVA_HOME/include -I $JAVA_HOME/include/darwin -framework JavaVM ./jni/HelloJNI.c -o libhelloworld.jnilib`
合并成一个命令 `cc -dynamiclib -I $JAVA_HOME/include -I $JAVA_HOME/include/darwin -framework JavaVM ./jni/HelloJNI.c -o libHelloJNI.dylib`

centos:
name: lib<name>.so
compile to `.o`: `cc -c -I $JAVA_HOME/include -I $JAVA_HOME/include/linux HelloWorld.c`
`cc -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" -shared HelloWorld.c -o libHelloWorld.so`

windows:
name: name.dll
`gcc -c -I"E:\JDK\include" -I"E:\JDK\include\win32" jni/HelloJNI.c`
`gcc -Wl,--add-stdcall-alias -shared -o hello.dll HelloJNI.o`
合并成一个命令 `gcc -Wl,--add-stdcall-alias -I"E:\JDK\include" -I"E:\JDK\include\win32" -shared ./jni/HelloJNI.c -o ./lib/hello.dll`
