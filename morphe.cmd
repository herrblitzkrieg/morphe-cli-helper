@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"


:: update
if "%~1"=="update"	call :update & exit /b
if "%~1"=="sign"	call :sign "%~2" & exit /b
if "%~1"=="cleanup"	call :cleanup "silent" & exit /b
if "%~1"=="" 		call :update


:: init
call :init


:menu
cls
for %%i in ("%~1") do if /i "%%~xi"==".apk" set "apk=%%~fi"
for %%i in ("%~1") do if /i "%%~xi"==".apkm" set "apk=%%~fi"
if not "!apk!"=="" goto patch
echo PATCHES   : !patches!
echo CLI       : !cli!
echo MICROG    : !microg!
echo APKEDITOR : !apkeditor!
echo 7Z        : !7z:~1,-1%!
echo ZIPALIGN  : !zipalign:~1,-1%!
echo APKSIGNER : !apksigner:~1,-1%!
echo.
java -version
echo.
echo.
echo Available commands:
echo patch, list, cleanup, exit
echo.
set /p command=">> "
cls

for %%i in ("%command:~1,-1%") do if /i "%%~xi"==".apk" set "apk=%%~fi"
for %%i in ("%command:~1,-1%") do if /i "%%~xi"==".apkm" set "apk=%%~fi"
if not "!apk!"=="" call :patch & goto menu
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
	echo Checking for Morphe cli update...
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-cli/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		cls
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		del /f /q "morphe-cli*.jar" >nul 2>&1
		ren tmp.bin "!filename!" >nul 2>&1
	)

	:: patches update
	cls
	echo Checking for Morphe patches update...
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-patches/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.mpp'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		cls
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		del /f /q "patches-*.mpp" >nul 2>&1
		ren tmp.bin "!filename!" >nul 2>&1
	)

	:: MicroG-RE update
	cls
	echo Checking for MicroG-RE update...
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/MicroG-RE/releases/latest).assets | Where-Object {$_.name -like '*.apk'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		cls
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		del /f /q "microg-*.apk" >nul 2>&1
		ren tmp.bin "!filename!" >nul 2>&1
	)

	:: APKEditor update
	cls
	echo Checking for APKEditor update...
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/REAndroid/APKEditor/releases/latest).assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set url=%%i
	for %%f in ("!url!") do set filename=%%~nxf
	if not exist "!filename!" (
		cls
		echo Downloading !filename!
		echo.
		curl -L -f "!url!" -o tmp.bin || ( echo. & pause & exit )
		del /f /q "APKEditor-*.jar" >nul 2>&1
		ren tmp.bin "!filename!" >nul 2>&1
	)
	
	:: 7z.exe update
	if not exist 7z.exe	(
		cls
		echo Downloading 7z.exe
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/7z.exe" -o tmp.bin || ( echo. & pause & exit )
		ren tmp.bin 7z.exe >nul 2>&1
	)
	if not exist 7z.dll	(
		cls
		echo Downloading 7z.dll
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/7z.dll" -o tmp.bin || ( echo. & pause & exit )
		ren tmp.bin 7z.dll >nul 2>&1
	)
	
	:: zipalign.exe update
	if not exist zipalign.exe (
		cls
		echo Downloading zipalign.exe
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/zipalign.exe" -o tmp.bin || ( echo. & pause & exit )
		ren tmp.bin zipalign.exe >nul 2>&1
	)
	
	:: apksigner.jar update
	if not exist apksigner.jar (
		cls
		echo Downloading apksigner.jar
		echo.
		curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/apksigner.jar" -o tmp.bin || ( echo. & pause & exit )
		ren tmp.bin apksigner.jar >nul 2>&1
	)
	
)
:skipupdate
cls & exit /b


:patch
	cls
	if "!apk!"=="" ( set /p apk="Paste APK path: " )
	del /f /q morphe.apk >nul 2>&1
	for %%i in ("!apk!") do (
		if /i "%%~xi"==".apkm" (
			echo Using APKEditor to convert split to single apk...
			mklink /h morphe.zip %%i >nul 2>&1
			rd /s /q extractedapkm >nul 2>&1
			!7z! x morphe.zip -oextractedapkm >nul 2>&1
			java -jar !apkeditor! m -i extractedapkm -o morphe.apk >nul 2>&1
			rd /s /q extractedapkm >nul 2>&1
		) else (
		mklink /h morphe.apk "!apk!" >nul 2>&1
		)
	)
	cls
	
	:: remove exotic libs
	echo Removing exotic libs...
	copy /y morphe.apk morphe.zip >nul 2>&1
	REM !7z! d morphe.zip lib/x86/* >nul 2>&1
	REM !7z! d morphe.zip lib/x86_64/* >nul 2>&1
	REM !7z! d morphe.zip lib/x86 >nul 2>&1
	REM !7z! d morphe.zip lib/x86_64 >nul 2>&1
	!7z! d morphe.zip lib/x86/* lib/x86_64/* lib/x86 lib/x86_64 >nul 2>&1
	del /f /q morphe.zip.tmp >nul 2>&1
	move /y morphe.zip morphe.apk >nul 2>&1
	cls
	
	:: set patch specific options here
	REM java -jar !cli! patch -p !patches! ^
		REM -e "Theme" -OdarkThemeBackgroundColor=@android:color/system_neutral1_900 -OlightThemeBackgroundColor=@android:color/white ^
	REM morphe.apk
	java -jar !cli! patch -p !patches! ^
		-e "Theme" -OdarkThemeBackgroundColor=@android:color/system_neutral1_900 -OlightThemeBackgroundColor=@android:color/white ^
		--unsigned ^
	morphe.apk
	
	call :sign "%~dp0morphe-patched.apk"
	
	del /f /q morphe.apk >nul 2>&1
	if not errorlevel 1 (
	for %%i in ("!apk!") do (
		move /y "%~dp0morphe-patched.apk" "%%~dpni-patched.apk" >nul 2>&1
		cls
		echo Saved to: %%~dpni-patched.apk
		REM adb get-state 1>nul 2>nul && adb install "%%~dpni-patched.apk"
	)
	) else exit /b 1
	
	if not "%~1"=="" cls & exit /b
	echo.
	pause
	set "apk="
	cls
	exit /b


:list
	java -jar !cli! list-patches --with-packages --with-versions --with-options !patches!
	echo.
	pause
	cls
	exit /b
	
	
:cleanup
	rd /s /q morphe-patched-temporary-files >nul 2>&1
	rd /s /q extractedapk >nul 2>&1
	rd /s /q extractedapkm >nul 2>&1
	del /f /q merge*.apk >nul 2>&1
	del /f /q morphe.apk >nul 2>&1
	del /f /q morphe2.apk >nul 2>&1
	del /f /q morphe.zip >nul 2>&1
	del /f /q morphe.zip.tmp* >nul 2>&1
	del /f /q *.idsig >nul 2>&1
	if not "%~1"=="silent" (
	echo Cleaned.
	echo.
	pause
	)
	cls
	exit /b
	
	
:sign
	call :init
	cls
	echo Signing...
	if not exist cli.keystore (
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
	!zipalign! -p -f 4 "%~1" "%~dpn1-aligned.apk" >nul 2>&1
	move /y "%~dpn1-aligned.apk" "%~1" >nul 2>&1
	ren "%~1" morphe.zip >nul 2>&1
	!7z! d "%~dp1morphe.zip" META-INF/* META-INF >nul 2>&1
	ren "%~dp1morphe.zip" "%~nx1" >nul 2>&1
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
	cls
	exit /b
	
	
:init
	for %%i in ("morphe-cli*.jar") do set cli=%%i
	for %%i in ("patches-*.mpp") do set patches=%%i
	for %%i in ("microg-*.apk") do set microg=%%i
	for %%i in ("APKEditor-*.jar") do set apkeditor=%%i
	set 7z="7z.exe"
	set zipalign="zipalign.exe"
	set apksigner="apksigner.jar"
	exit /b