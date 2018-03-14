@ECHO OFF
rem usage sample: make-new-ver-in-repo.bat 0.0.11

SETLOCAL

SET EXITCODE=0

SET install=false
SET clean=false
SET package=true
SET version=
SET addon=pvr.puzzle.tv

SETLOCAL EnableDelayedExpansion
FOR %%b IN (%*) DO (
  IF %%b == install (
    SET install=true
  ) ELSE ( IF %%b == clean (
    SET clean=true
  ) ELSE ( IF %%b == package (
    SET package=true
  ) ELSE (
    SET version=%%b
  )))
)
SETLOCAL DisableDelayedExpansion

ECHO addon=%addon%
ECHO version=%version%

SET CUR_PATH=%CD%

ECHO --------------------------------------------------
ECHO Updating from GIT... 
ECHO --------------------------------------------------
CD %addon%
git reset --hard HEAD
git pull

ECHO --------------------------------------------------
ECHO Generating addon description in Kodi souce tree ... 
ECHO --------------------------------------------------
CD %CUR_PATH%
SET kodi_cmake_addon=xbmc/project/cmake/addons/addons/%addon%
IF EXIST "%kodi_cmake_addon%" RD /q /s "%kodi_cmake_addon%"
MKDIR "%kodi_cmake_addon%"
IF %errorlevel% neq 0 EXIT /b %errorlevel%
CD "%kodi_cmake_addon%"
ECHO all>platforms.txt
ECHO %addon% https://github.com/srg70/%addon% master > %addon%.txt
ECHO Done

ECHO --------------------------------------------------
ECHO Building addon %addon% ...
ECHO --------------------------------------------------
CD %CUR_PATH%
CD xbmc\tools\buildsteps\win32
CALL make-addons.bat %addon% clean
CALL make-addons.bat %addon% package

IF %errorlevel% NEQ 0 GOTO :error

ECHO --------------------------------------------------
ECHO Updateing GIT repository ...
ECHO --------------------------------------------------

REM GOTO :exit

CD %CUR_PATH%
CD  kodi_repo
git reset --hard HEAD
git pull

CD %CUR_PATH%

SET addon_zip=%addon%-%version%.zip
SET platfrom_repo=kodi_repo\repo\windows-x86
SET addon_platfrom_repo=%platfrom_repo%\%addon%

COPY /Y  xbmc\project\cmake\addons\build\%addon%\%addon%\addon.xml %addon_platfrom_repo%
COPY /Y xbmc\project\cmake\addons\build\zips\%addon_zip_file% %addon_platfrom_repo%

SET addon_zip_file_in_repo=%addon_platfrom_repo%\%addon_zip%
DEL /Q %addon_zip_file_in_repo%.md5
SETLOCAL EnableDelayedExpansion
SET "md5="
FOR /f "skip=1 tokens=* delims=" %%# in ('certutil -hashfile "%addon_zip_file_in_repo%" MD5') do (
	if not defined md5 (
		for %%Z in (%%#) do set "md5=!md5!%%Z"
	)
)
ECHO Addon MD5 = %md5%
ECHO %md5% > %addon_zip_file_in_repo%.md5
SETLOCAL DisableDelayedExpansion

CD  kodi_repo\repo\windows-x86 
ECHO PWD=%CD%
python @generate.py

CD ..\..
git add "repo\windows-x86\addons.*"
git add "repo\windows-x86\%addon%"
git commit  --author="Sergey Shramchenko <sergey.shramchenko@gmail.com>" -m "Win-x86-%addon%-%version%"
git push

GOTO :exit

:error
echo There was an error during build!

:exit