@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"


:: parameters
if "%~1"=="update"	call :update & exit /b
if "%~1"=="sign"	call :sign "%~2" & exit /b
if "%~1"=="cleanup"	call :cleanup silent & exit /b
for %%i in ("%~1") do if /i "%%~xi"==".apk" set "apk=%%~fi" & goto patch
for %%i in ("%~1") do if /i "%%~xi"==".apkm" set "apk=%%~fi" & goto patch


:: init
call :cleanup silent
call :update
call :init


:menu
cls
echo PATCHES   : !patches!
echo CLI       : !cli!
echo MICROG    : !microg!
echo APKEDITOR : !apkeditor!
echo 7Z        : !7z!
echo ZIPALIGN  : !zipalign!
echo APKSIGNER : !apksigner!
echo.
java -version
echo.
echo.
echo Available commands:
echo patch, list, cleanup, exit
echo.
set /p command=">> "
cls

for %%i in ("!command!") do if /i "%%~xi"==".apk" set "apk=%%~fi" & call :patch & goto menu
for %%i in ("!command!") do if /i "%%~xi"==".apkm" set "apk=%%~fi" & call :patch & goto menu
if "!command!" == "patch" call :patch & goto menu
if "!command!" == "p" call :patch & goto menu
if "!command!" == "1" call :patch & goto menu
if "!command!" == "list" call :list & goto menu
if "!command!" == "l" call :list & goto menu
if "!command!" == "2" call :list & goto menu
if "!command!" == "cleanup" call :cleanup & goto menu
if "!command!" == "c" call :cleanup & goto menu
if "!command!" == "3" call :cleanup & goto menu
if "!command!" == "exit" exit /b
if "!command!" == "e" exit /b
if "!command!" == "4" exit /b
echo Unknown command, sorry :( & echo. & pause & goto menu


:update
del /f /q tmp.bin >nul 2>&1
REM goto skipupdate
ping -n 1 1.1.1.1 >nul
if not errorlevel 1 (

	:: cli update
	echo Checking for Morphe cli update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-cli/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		echo.
		del /f /q "morphe-cli*.jar" >nul 2>&1
		move /y tmp.bin "!filename!" >nul 2>&1
	)

	:: patches update
	echo Checking for Morphe patches update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-patches/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.mpp'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		echo.
		del /f /q "patches-*.mpp" >nul 2>&1
		move /y tmp.bin "!filename!" >nul 2>&1
	)

	:: MicroG-RE update
	echo Checking for MicroG-RE update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/MicroG-RE/releases/latest).assets | Where-Object {$_.name -like '*.apk'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		echo.
		del /f /q "microg-*.apk" >nul 2>&1
		move /y tmp.bin "!filename!" >nul 2>&1
	)

	:: APKEditor update
	echo Checking for APKEditor update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/REAndroid/APKEditor/releases/latest).assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		del /f /q "APKEditor-*.jar" >nul 2>&1
		move /y tmp.bin "!filename!" >nul 2>&1
	)
	
	:: 7z.exe update
	if not exist 7z.exe	(
		echo Downloading 7z.exe
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/7z.exe" -o tmp.bin || ( echo. & pause & exit )
		echo.
		move /y tmp.bin 7z.exe >nul 2>&1
	)
	if not exist 7z.dll	(
		echo Downloading 7z.dll
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/7z.dll" -o tmp.bin || ( echo. & pause & exit )
		echo.
		move /y tmp.bin 7z.dll >nul 2>&1
	)
	
	:: zipalign.exe update
	if not exist zipalign.exe (
		echo Downloading zipalign.exe
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/zipalign.exe" -o tmp.bin || ( echo. & pause & exit )
		echo.
		move /y tmp.bin zipalign.exe >nul 2>&1
	)
	
	:: apksigner.jar update
	if not exist apksigner.jar (
		echo Downloading apksigner.jar
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/apksigner.jar" -o tmp.bin || ( echo. & pause & exit )
		echo.
		move /y tmp.bin apksigner.jar >nul 2>&1
	)
	
)
:skipupdate
exit /b


:patch
	call :cleanup silent
	call :init

	if "!apk!"=="" ( cls & set /p apk="Paste APK file path (.apk, .apkm): " & echo. )
	del /f /q morphe.apk >nul 2>&1
	for %%i in ("!apk!") do (
		if /i "%%~xi"==".apkm" (
			echo Converting splits into a single apk file
			mklink /h morphe.zip %%i >nul 2>&1 || copy /y %%i morphe.zip >nul 2>&1
			!7z! x morphe.zip -otmp >nul 2>&1
			java -jar !apkeditor! m -i tmp -o morphe.apk -clean-meta -extractNativeLibs false -vrd >nul 2>&1
			del /f /q morphe.zip >nul 2>&1
			rd /s /q tmp >nul 2>&1
		) else (
		mklink /h morphe.apk %%i >nul 2>&1 || copy /y %%i morphe.apk >nul 2>&1
		)
	)
	
	:: remove exotic libs
	echo Removing x86 and x86_64 ABI libs
	move /y morphe.apk morphe.zip >nul 2>&1
	!7z! d morphe.zip lib/x86/* lib/x86_64/* lib/x86 lib/x86_64 >nul 2>&1
	del /f /q morphe.zip.tmp >nul 2>&1
	move /y morphe.zip morphe.apk >nul 2>&1
	echo.
	
	:: set patch specific options below
	java -jar !cli! patch -p !patches! ^
		-e "Theme" -OdarkThemeBackgroundColor=@android:color/system_neutral1_900 -OlightThemeBackgroundColor=@android:color/white ^
		-f --unsigned ^
	morphe.apk
	echo.
	
	if not exist "%~dp0morphe-patched.apk" pause & call :cleanup silent & exit /b
	
	:: spoof version code to 2147483647
	echo Spoofing app version
	java -jar !apkeditor! d -i "%~dp0morphe-patched.apk" -o tmp -t xml -dex >nul 2>&1
	powershell -Command "(Get-Content tmp\AndroidManifest.xml) -replace 'android:versionCode=\"\d+\"','android:versionCode=\"2147483647\"' | Set-Content tmp\AndroidManifest.xml" >nul 2>&1
	del /f /q "%~dp0morphe-patched.apk" >nul 2>&1
	java -jar !apkeditor! b -i tmp -o "%~dp0morphe-patched.apk" >nul 2>&1
	
	call :sign "%~dp0morphe-patched.apk"
	
	del /f /q morphe.apk >nul 2>&1
	for %%i in ("!apk!") do (
		move /y "%~dp0morphe-patched.apk" "%%~dpni-patched.apk" >nul 2>&1
		echo Saved to %%~dpni-patched.apk
		REM adb get-state 1>nul 2>nul && adb install "%%~dpni-patched.apk"
	)
	call :cleanup silent
	
	if not "%~1"=="" cls & exit /b
	echo.
	echo Patching completed.
	echo.
	pause & set "apk=" & exit /b


:list
	java -jar !cli! list-patches --with-packages --with-versions --with-options !patches!
	echo.
	pause
	cls
	exit /b
	
	
:cleanup
	rd /s /q morphe-patched-temporary-files >nul 2>&1
	rd /s /q tmp >nul 2>&1
	del /f /q merge*.apk >nul 2>&1
	del /f /q morphe.apk >nul 2>&1
	del /f /q morphe2.apk >nul 2>&1
	del /f /q morphe.zip >nul 2>&1
	del /f /q morphe.zip.tmp* >nul 2>&1
	del /f /q *.idsig >nul 2>&1
	if not "%~1"=="silent" (
	cls
	echo Cleaning completed.
	echo.
	pause
	)
	exit /b
	
	
:sign
	call :init
	if not exist cli.keystore (
	echo Creating a new keystore for signing
	keytool -genkeypair ^
		-alias morphe ^
		-keyalg RSA ^
		-keysize 2048 ^
		-validity 10000 ^
		-keystore cli.keystore ^
		-storetype PKCS12 ^
		-storepass password ^
		-keypass password ^
		-dname "CN=Morphe,O=Dev,C=US" >nul 2>&1
	)
	echo Signing apk file
	!zipalign! -p -f 4 "%~1" "%~dpn1-aligned.apk" >nul 2>&1
	move /y "%~dpn1-aligned.apk" "%~1" >nul 2>&1
	java -jar !apksigner! sign ^
	  --ks cli.keystore ^
	  --ks-type PKCS12 ^
	  --ks-key-alias morphe ^
	  --ks-pass pass:password ^
	  --key-pass pass:password ^
	  --v1-signing-enabled true ^
	  --v2-signing-enabled true ^
	  --v3-signing-enabled true ^
	  --v4-signing-enabled false ^
	  "%~1" >nul 2>&1
	exit /b
	
	
:init
	for %%i in ("morphe-cli*.jar") do set cli=%%i
	for %%i in ("patches-*.mpp") do set patches=%%i
	for %%i in ("microg-*.apk") do set microg=%%i
	for %%i in ("APKEditor-*.jar") do set apkeditor=%%i
	set 7z=7z.exe
	set zipalign=zipalign.exe
	set apksigner=apksigner.jar
	exit /b