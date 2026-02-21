@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"


if not exist morphe.cmd (
	echo Downloading morphe.cmd
	echo.
	curl -L -f "https://raw.githubusercontent.com/herrblitzkrieg/morphe-cli-helper/main/morphe.cmd" -o tmp.bin || ( echo. & pause & exit )
	ren tmp.bin morphe.cmd >nul 2>&1
)


:: update
call morphe.cmd update


:: init
cls
for %%i in ("morphe-cli*.jar") do set cli=%%i
for %%i in ("patches-*.mpp") do set patches=%%i
for %%i in ("microg-*.apk") do set microg=%%i
for %%i in ("APKEditor-*.jar") do set apkeditor=%%i
set 7z="7z.exe"
md maintain\original >nul 2>&1
md maintain\patched >nul 2>&1


:: cleanup
call morphe.cmd cleanup
	

REM Check if any APK exists in maintain folder
for %%j in ("maintain\original\*.apk*") do (

	:: update not needed?
	for %%i in ("maintain\patched\*!patches:~8,-4%!*.apk") do (
		echo APKs are up-to-date.
		timeout /t 5 >nul 2>&1
		exit /b
	)

	:: update needed
	rd /s /q maintain\patched >nul 2>&1
	md maintain\patched >nul 2>&1
	for /r maintain\original %%i in ("*.apk*") do (
	
		call morphe.cmd "%%i"
		
		java -jar "!apkeditor!" info -i "%%~dpnxi" > tmp.bin
		for /f "tokens=1,2 delims==" %%k in (tmp.bin) do (
			if /i "%%k"=="AppName" set "appname=%%l"
			if /i "%%k"=="VersionName" set "versionname=%%l"
			if /i "%%k"=="package" set "packagename=%%l"
		)
		set appname=!appname:"=!
		set versionname=!versionname:"=!
		set packagename=!packagename:"=!

		del /f /q tmp.bin >nul 2>&1
		
		if not exist "maintain\patched\!appname! v!versionname! Morphe v!patches:~8,-4%!.apk" (
			move /y "maintain\original\%%~ni-patched.apk" ^
			"maintain\patched\!appname! v!versionname! Morphe v!patches:~8,-4%!.apk" >nul 2>&1
		) else (
			cls
			echo Merging apk files... 
			rd /s /q maintain\patched\merge >nul 2>&1
			md maintain\patched\merge >nul 2>&1
			move /y "maintain\patched\!appname! v!versionname! Morphe v!patches:~8,-4%!.apk" ^
			"maintain\patched\merge\!appname! v!versionname! Morphe v!patches:~8,-4%!.apk" >nul 2>&1
			move /y "maintain\original\%%~ni-patched.apk" ^
			"maintain\patched\merge\!appname! v!versionname! Morphe v!patches:~8,-4%! (2).apk" >nul 2>&1
			java -jar !apkeditor! m -i maintain\patched\merge >nul 2>&1
			
			call morphe.cmd sign "%~dp0maintain\patched\merge_merged.apk"
			
			ren "maintain\patched\merge_merged.apk" "!appname! v!versionname! Morphe v!patches:~8,-4%!.apk" >nul 2>&1
			rd /s /q maintain\patched\merge >nul 2>&1
		)
		
	)
	explorer.exe maintain\patched
	exit /b

)