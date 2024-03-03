@echo off
echo.
echo Compilando código java para jar
echo.

setlocal
                 
set ANDROID_JAR="C:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidSDK-2525-22.0.48361.3236\platforms\android-32\android.jar"
set DX_LIB="C:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidSDK-2525-22.0.48361.3236\build-tools\32.0.0\lib64"
rem set EMBO_DEX="C:\GIT\Conversa\java\classes.dex"
set PROJ_DIR=%CD%
set VERBOSE=0
set JAVASDK="C:\Program Files\Java\jdk1.8.0_60\bin"
rem set DX_BAT="C:\Users\Public\Documents\Embarcadero\Studio\22.0\PlatformSDKs\adt-bundle-windows-x86-20131030\sdk\build-tools\android-4.4\dx.bat"
set DX_BAT="C:\Users\Public\Documents\Embarcadero\Studio\21.0\CatalogRepository\AndroidSDK-2525-21.0.40680.4203 - Copia\build-tools\29.0.3\dx.bat"

echo %PROJ_DIR%
echo.
echo 1 - Compiling the Java source files
echo.
mkdir BootReceiver\classes 2> nul
%JAVASDK%\javac -Xlint:all -classpath %ANDROID_JAR% -d BootReceiver\classes BootReceiver\BootReceiver.java
mkdir ServiceRestart\classes 2> nul
%JAVASDK%\javac -Xlint:all -classpath %ANDROID_JAR% -d ServiceRestart\classes ServiceRestart\ServiceRestart.MyWorker.java
%JAVASDK%\javac -Xlint:all -classpath %ANDROID_JAR% -d ServiceRestart\classes ServiceRestart\ServiceRestart.MyReceiver.java

echo.
echo 2 - Creating jar containing the new classes
echo.
%JAVASDK%\jar cf BootReceiver\BootReceiver.jar -C BootReceiver\classes com
%JAVASDK%\jar cf ServiceRestart\ServiceRestart.MyWorker.jar -C ServiceRestart\classes com
%JAVASDK%\jar cf ServiceRestart\ServiceRestart.MyReceiver.jar -C ServiceRestart\classes com

pause

:Exit

endlocal
