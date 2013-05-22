@echo off
set mainpath=%~dp0
set gcConfigPath=%SYSTEMDRIVE%\%HOMEPATH%\.gitencrypt
if not exist  %gcConfigPath%\clean_filter_openssl call init.bat