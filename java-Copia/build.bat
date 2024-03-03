@echo off
echo.
echo Compiles your Java code into classes.dex
echo Verified to work for Delphi XE6
echo.
echo Place this batch in a java folder below your project (project\java)
echo Place the source in project\java\src\com\dannywind\delphi
echo If your source file location or name is different, please modify it below.
echo This assumes a Win64 system with the 64-bit Java installed by the Delphi XE6 
echo installer in C:\Program Files\Java\jdk1.7.0_25
echo.

setlocal
                 
rem set ANDROID_JAR="C:\Users\Public\Documents\Embarcadero\Studio\22.0\PlatformSDKs\adt-bundle-windows-x86-20131030\sdk\platforms\android-19\android.jar"
set ANDROID_JAR="C:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidSDK-2525-22.0.48361.3236\platforms\android-32\android.jar"
rem set DX_LIB="C:\Users\Public\Documents\Embarcadero\Studio\22.0\PlatformSDKs\adt-bundle-windows-x86-20131030\sdk\build-tools\android-4.4\lib"
set DX_LIB="C:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidSDK-2525-22.0.48361.3236\build-tools\32.0.0\lib64"
rem set EMBO_DEX="C:\Program Files (x86)\Embarcadero\Studio\22.0\lib\android\debug\classes.dex"
set EMBO_DEX="C:\GIT\Conversa\java\classes.dex"
set PROJ_DIR=%CD%
set VERBOSE=0
set JAVASDK="C:\Program Files\Java\jdk1.8.0_60\bin"
rem set DX_BAT="C:\Users\Public\Documents\Embarcadero\Studio\22.0\PlatformSDKs\adt-bundle-windows-x86-20131030\sdk\build-tools\android-4.4\dx.bat"
set DX_BAT="C:\Users\Public\Documents\Embarcadero\Studio\21.0\CatalogRepository\AndroidSDK-2525-21.0.40680.4203 - Copia\build-tools\29.0.3\dx.bat"

echo %PROJ_DIR%
echo.
echo 1 - Compiling the Java source files
echo.
pause
mkdir output 2> nul
mkdir output\classes 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=-verbose
%JAVASDK%\javac %VERBOSE_FLAG% -Xlint:all -classpath %ANDROID_JAR% -d output\classes ..\services\BootReceiver.java

echo.
echo 2 - Creating jar containing the new classes
echo.
pause
mkdir output\jar 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=v
%JAVASDK%\jar c%VERBOSE_FLAG%f output\jar\test_classes.jar -C output\classes com


echo.
echo 3 - Converting from jar to dex...
echo dx_path: %DX_BAT%
echo verbose_flag: %VERBOSE_FLAG%
echo positions: %PROJ_DIR%\output\jar\test_classes.jar
echo output: %PROJ_DIR%\output\dex\test_classes.dex
echo.
pause
mkdir output\dex 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=--verbose
call %DX_BAT% --dex %VERBOSE_FLAG% --output=%PROJ_DIR%\output\dex\test_classes.dex --positions=lines %PROJ_DIR%\output\jar\test_classes.jar

echo.
echo 4 - Merging dex files
echo.
pause
%JAVASDK%\java -cp %DX_LIB%\dx.jar com.android.dx.merge.DexMerger %PROJ_DIR%\output\dex\classes.dex %PROJ_DIR%\output\dex\test_classes.dex %EMBO_DEX%

echo.
echo Now use output\dex\classes.dex instead of default classes.dex
echo And add broadcastreceiver to AndroidManifest.template.xml
echo.

:Exit

endlocal
