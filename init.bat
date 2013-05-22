@echo off
:: BatchGotAdmin  
::-------------------------------------  
REM  --> Check for permissions  
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"  
  
REM --> If error flag set, we do not have admin.  
if '%errorlevel%' NEQ '0' (  
    echo Requesting administrative privileges...  
    goto UACPrompt  
) else ( goto gotAdmin )  
  
:UACPrompt  
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"  
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"  
  
    "%temp%\getadmin.vbs"  
    exit /B  
  
:gotAdmin  
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )  
    pushd "%CD%"  
    CD /D "%~dp0"  
::--------------------------------------  
@echo off
echo ------------------------------------------------------------
echo.
echo               正在初始化，请稍后。。。
echo.
echo ------------------------------------------------------------
set mainpath=%~dp0
set gcConfigPath=%SYSTEMDRIVE%\%HOMEPATH%\.gitencrypt
if not exist  %gcConfigPath% md %gcConfigPath%
if not exist key.rnd openssl rand -hex -out key.rnd 32
if not exist salt.rnd openssl rand -hex -out salt.rnd 11
set /p key=<key.rnd
set /p salt=<salt.rnd
copy /y *.template *.ready
sed -i "s/<your-passphrase>/%key%/g" *.ready
sed -i "s/<your-salt>/%salt%/g" *.ready
copy /y clean_filter_openssl.ready %gcConfigPath%\clean_filter_openssl
copy /y diff_filter_openssl.ready %gcConfigPath%\diff_filter_openssl
copy /y smudge_filter_openssl.ready %gcConfigPath%\smudge_filter_openssl
del *.ready
del sed*
echo ------------------------------------------------------------
echo.
echo                初始化完成。
echo.
echo ------------------------------------------------------------
pause