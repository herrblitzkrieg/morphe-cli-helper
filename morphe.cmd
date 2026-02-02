@echo off
setlocal EnableDelayedExpansion


:: update
del /f /q tmp.bin >nul 2>&1
ping -n 1 8.8.8.8 >nul
if not errorlevel 1 (

	:: cli update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-cli/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set URL=%%i
	for %%f in ("!URL!") do set FILENAME=%%~nxf
	if not exist "!FILENAME!" (
		del /f /q *.jar >nul 2>&1
		cls
		echo Downloading !FILENAME!
		echo.
		curl -L "!URL!" -o tmp.bin || exit /b 1
		ren tmp.bin "!FILENAME!" >nul 2>&1
	)

	:: patches update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/morphe-patches/releases).Where({$_.prerelease})[0].assets | Where-Object {$_.name -like '*.mpp'} | Select-Object -Expand browser_download_url"
	') do set URL=%%i
	for %%f in ("!URL!") do set FILENAME=%%~nxf
	if not exist "!FILENAME!" (
		del /f /q *.mpp >nul 2>&1
		cls
		echo Downloading !FILENAME!
		echo.
		curl -L "!URL!" -o tmp.bin || exit /b 1
		ren tmp.bin "!FILENAME!" >nul 2>&1
	)

	:: MicroG-RE update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/MorpheApp/MicroG-RE/releases/latest).assets | Where-Object {$_.name -like '*.apk'} | Select-Object -Expand browser_download_url"
	') do set URL=%%i
	for %%f in ("!URL!") do set FILENAME=%%~nxf
	if not exist "!FILENAME!" (
		del /f /q microg*.apk >nul 2>&1
		cls
		echo Downloading !FILENAME!
		echo.
		curl -L "!URL!" -o tmp.bin || exit /b 1
		ren tmp.bin "!FILENAME!" >nul 2>&1
	)

	:: APKEditor update
	for /f "delims=" %%i in ('
	  powershell -NoProfile -Command ^
	  "(Invoke-RestMethod https://api.github.com/repos/REAndroid/APKEditor/releases/latest).assets | Where-Object {$_.name -like '*.jar'} | Select-Object -Expand browser_download_url"
	') do set URL=%%i
	for %%f in ("!URL!") do set FILENAME=%%~nxf
	if not exist "!FILENAME!" (
		del /f /q APKEditor*.jar >nul 2>&1
		cls
		echo Downloading !FILENAME!
		echo.
		curl -L "!URL!" -o tmp.bin || exit /b 1
		ren tmp.bin "!FILENAME!" >nul 2>&1
	)

)


:: init
for %%i in ("morphe-cli*.jar") do set cli=%%i
for %%i in ("patches-*.mpp") do set patches=%%i
for %%i in ("APKEditor-*.jar") do set apkeditor=%%i


:: lessgo
:loop
cls
echo CLI: %cli%
echo PATCHES: %patches%
echo APKEDITOR: %apkeditor%
echo.
echo Available commands:
echo patch, list, cleanup
echo.
echo.
set /p command=">> "
cls

for %%i in ("%command%") do if /i "%%~xi"==".apk" set "apk=%command%" && goto patch
for %%i in ("%command%") do if /i "%%~xi"==".apkm" set "apk=%command%" && goto patch
if %command% == patch goto patch
if %command% == p goto patch
if %command% == 1 goto patch
if %command% == list goto list
if %command% == l goto list
if %command% == 2 goto list
if %command% == cleanup goto cleanup
if %command% == c goto cleanup
if %command% == 3 goto cleanup
echo Unknown command, sorry :( && goto done


:patch
	cls
	if "%apk%"=="" ( set /p apk="Paste APK path: " )
	del /f /q morphe.apk >nul 2>&1
	for %%i in ("%apk%") do (
		if /i "%%~xi"==".apkm" (
			echo Using APKEditor to convert split to single apk...
			mklink /h morphe.zip "%%i" >nul 2>&1
			rd /s /q extractedapkm >nul 2>&1
			powershell -command "Expand-Archive -Path morphe.zip -DestinationPath extractedapkm" >nul 2>&1
			del /f /q morphe.zip >nul 2>&1
			java -jar %apkeditor% m -i extractedapkm -o morphe.apk >nul 2>&1
			rd /s /q extractedapkm >nul 2>&1
		) else (
		mklink /h morphe.apk "!apk!" >nul 2>&1
		)
	)
	cls
	
	:: set patch specific options here
	java -jar %cli% patch -p %patches% ^
		-e "Theme" -OdarkThemeBackgroundColor=@android:color/system_neutral1_900 -OlightThemeBackgroundColor=@android:color/white ^
	morphe.apk
	
	if not errorlevel 1 (
	for %%i in ("!apk!") do (
		del /f /q morphe.apk >nul 2>&1
		move /y morphe-patched.apk "%%~dpi" >nul 2>&1
		del /f /q "%%~dpni-patched.apk" >nul 2>&1
		ren "%%~dpimorphe-patched.apk" "%%~ni-patched.apk" >nul 2>&1
		adb get-state 1>nul 2>nul && adb install "%%~dpni-patched.apk"
	)
	)
	goto done


:list
	java -jar %cli% list-patches --with-packages --with-versions --with-options %patches%
	goto done
	
:cleanup
	rd /s /q morphe-patched-temporary-files >nul 2>&1
	rd /s /q extractedapkm >nul 2>&1
	del /f /q morphe.apk >nul 2>&1
	echo Cleaned.
	goto done


:done
echo.
pause
set "apk="
goto loop