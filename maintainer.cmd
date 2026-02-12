@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"


:: update
call morphe.cmd update


:: init
cls
for %%i in ("morphe-cli*.jar") do set cli=%%i
for %%i in ("patches-*.mpp") do set patches=%%i
for %%i in ("microg-*.apk") do set microg=%%i
for %%i in ("APKEditor-*.jar") do set apkeditor=%%i
set 7z="7z.exe"
md maintain\original
md maintain\patched


:: cleanup
rd /s /q morphe-patched-temporary-files >nul 2>&1
rd /s /q extractedapk >nul 2>&1
rd /s /q extractedapkm >nul 2>&1
del /f /q morphe.apk >nul 2>&1
del /f /q morphe2.apk >nul 2>&1
del /f /q morphe.zip >nul 2>&1
del /f /q morphe.zip.tmp* >nul 2>&1
	

REM Check if any APK exists in maintain folder
for %%a in ("maintain\original\*.apk*") do (

	:: uodate not needed?
	for %%i in ("maintain\patched\*!patches:~8,-4%!*.apk") do (
		echo APKs are up-to-date.
		timeout /t 3 >nul 2>&1
		exit /b
	)

	:: update needed
	rd /s /q maintain\patched >nul 2>&1
	md maintain\patched >nul 2>&1
	for /r maintain\original %%j in ("*.apk*") do (
		set "apk=%%j"
		call morphe.cmd !apk!
		
		java -jar "!apkeditor!" info -i "%%~dpnxj" > tmp.bin
		for /f "tokens=1,2 delims==" %%k in (tmp.bin) do (
			if /i "%%k"=="AppName" set "APPNAME=%%l"
			if /i "%%k"=="VersionName" set "VERSIONNAME=%%l"
			if /i "%%k"=="package" set "PACKAGENAME=%%l"
		)
		set APPNAME=!APPNAME:"=!
		set VERSIONNAME=!VERSIONNAME:"=!
		set PACKAGENAME=!PACKAGENAME:"=!

		REM !7z! l "%%~dpnxj" > tmp.bin
		REM for /f "tokens=1,2 delims==" %%k in (tmp.bin) do (
			REM if /i "%%k"=="AppName" set "APPNAME=%%l"
			REM if /i "%%k"=="VersionName" set "VERSIONNAME=%%l"
			REM if /i "%%k"=="package" set "PACKAGENAME=%%l"
		REM )
		REM set ABI=!APPNAME:"=!
		del /f /q tmp.bin >nul 2>&1
		
		if not exist "maintain\patched\!APPNAME! v!VERSIONNAME! Morphe v!patches:~8,-4%!.apk" (
			move /y "maintain\original\%%~nj-patched.apk" "maintain\patched\!APPNAME! v!VERSIONNAME! Morphe v!patches:~8,-4%!.apk"
		) else (
			move /y "maintain\original\%%~nj-patched.apk" "maintain\patched\!APPNAME! v!VERSIONNAME! Morphe v!patches:~8,-4%! (2).apk"
		)
		
	)
	explorer.exe maintain\patched
	exit /b

)