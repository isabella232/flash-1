@echo off

IF NOT EXIST PubNubAirAndroid.JAR goto fail

REM delete any old stuff
del library.swf
rmdir /s /q Android-ARM
rmdir /s /q Android-x86
mkdir Android-ARM
mkdir Android-x86

REM move a jar into a proper place, also, ensure its name capitalization 
REM is correct (PubNubAirAndroid.JAR and PubNubAirAndroid.jar are same for Windows, but not for Java!)
copy PubNubAirAndroid.jar Android-ARM\PubNubAirAndroid.jar

REM extract library.swf from an swc and put into a proper place
7z e ..\PubNubAirLib\bin\PubNubAirLib.swc library.swf
copy library.swf Android-ARM\

REM make temp folder, put PubNubAirAndroid.jar there, extract, then extract any JARs in its
REM libs\ folder, unpack them into root, delete, then repackage JAR again
rmdir /S /Q tmp
mkdir tmp
move PubNubAirAndroid.jar tmp\
cd tmp
jar -xf PubNubAirAndroid.jar
move libs\*.* .
del PubNubAirAndroid.jar
for %%f in (*.jar) do jar -xf %%f
del *.jar
jar -cf PubNubAirAndroid.jar .
move PubNubAirAndroid.jar ..\Android-ARM\
cd ..
rmdir /S /Q tmp
xcopy /Y Android-ARM Android-x86

REM now do the actual build of an ANE
call buildf.bat

goto end
:fail
ECHO PubNubAirAndroid.JAR not found!
:end