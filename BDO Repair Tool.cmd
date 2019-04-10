@echo off
SET build=1.0.4
title BDO Repair Tool (BETA) v%BUILD%

:checkPrivileges
:: Check for Admin by accessing protected stuff. This calls net(#).exe and can stall if we don't kill it later.
NET FILE 1>nul 2>&1 2>nul 2>&1
if '%errorlevel%' == '0' ( goto eula) else ( goto getPrivileges ) 

:getPrivileges
:: Write vbs in temp to call batch as admin.
if '%1'=='ELEV' (shift & goto eula)                               
for /f "delims=: tokens=*" %%A in ('findstr /b ::- "%~f0"') do @Echo(%%A
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
Echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
Echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B

:eula
:: Post a EULA because people.
Cls
Echo                                                      **EULA**
Echo.
Echo Brought to you by Solaris17 (Quora / NA / Valk)
Echo.
Echo This tool is third party and not developed or supported by
Echo Pearl Abyss, Kakao Games or any other interested parties.
Echo.
Echo This script and its Author(s) offer no warranty expressed or implied.
Echo The Author(s) of this script are not responsible for any damages causes by the script.
Echo.
Echo By continuing you agree to run this script and its processes at your own risk.
Echo.
Echo If you do not agree simply close the script.
Echo.
Pause
goto start

:start
:: Explain what this is and what it does.
:: Use '>nul 2>&1' alot to supress command output so people dont freak and increase redability.
cls
Echo                                          **Welcome to the BDO Repair tool**
Echo.
Echo This tool was made using the vanilla (non-steam) version because I don't have it on steam.
Echo.
Echo This tool was created to help players get BDO running.
Echo This tool automates some of the best practices outlined by BDO staff.
Echo You can visit the support forum for more assistance here, https://goo.gl/wUrVQ3
Echo.
Echo This script will also log what it is doing to a .log on your desktop.
Echo This script will also occasionally attempt to access the internet and download files.
Echo.
Echo                               *** THIS TOOL MUST BE RAN/PLACED IN THE BDO DIRECTORY ***
Echo.
pause
goto checknet

:checknet
:: We do a ping test vs google to check for connection. I then look for a certain response indicating its working and move on.
cls
ECHO Checking connection, please wait...
PING -n 1 www.google.com|find "Reply from " >nul 2>&1
IF NOT ERRORLEVEL 1 goto check
IF     ERRORLEVEL 1 goto neterr

:neterr
:: No network trap.
cls
Echo.
Echo Hey; We detected you aren't online, please check your connection and try again.
Echo.
pause
goto cleanup

:check
:: Run a check against the current directory to make sure you see BDO files.
:: Check for a few incase the game is seriously f$%%#. (leap frog system)
cls
Echo Let me check to make sure I'm being run out of the correct directory.
IF EXIST "%~dp0\cef.pak" ( GOTO diag ) ELSE ( GOTO check2 )
:check2
IF EXIST "%~dp0\Black Desert Online Launcher.exe" ( GOTO diag ) ELSE ( GOTO check3 )
:check3
IF EXIST "%~dp0\icudt.dll" ( GOTO diag ) ELSE ( GOTO wrongdir )
Echo.

:wrongdir
:: Trap for failed detection.
cls
Echo Woops, I don't seem to be in the BDO main folder.
Echo If you think it is incorrect you can try running me anyway.
Echo Otherwise copy and run me from the BDO directory.
Echo.
Echo 1 = I'll try again
Echo.
Echo 2 = I'm sure this is right.
set choice=
ECHO.
set /p choice=
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto exit
if '%choice%'=='2' goto diag
goto dirwarn

:dirwarn
:: Key trap for selecting something out of scope.
cls
Echo "Invalid Selection Please Try again..."
Echo.
pause
goto wrongdir

:diag
cls
:: This will get the logs needed by the team at https://goo.gl/RhCvEw
Echo Ok so first things first we need to collect some logs for the BDO team to help diagnose.
Echo.
Echo The requirements for logs are here https://goo.gl/RhCvEw
Echo Remember to start your own thread replying to the script thread won't help you.
Echo.
Echo This will create a folder called "BDO Logs" on your desktop.
Echo It will have all the logs the BDO team needs.
Echo For advanced users this might not show up if you redirect your folders.
Echo.
pause
goto logcollect

:logcollect
cls
Echo Starting Data collection. (This can take a bit)
Echo.
::Create Log folder on desktop
MD "%userprofile%\desktop\BDO Logs" >nul 2>&1
::Now start log collection
bitsadmin /transfer ZIP-Tool /download /priority FOREGROUND http://www.teamdotexe.org/Downloads/zip.vbs "C:\windows\system32\zip.vbs" >nul 2>&1
dxdiag /dontskip /whql:on /t "%userprofile%\desktop\BDO Logs\dxdiag.txt" >nul 2>&1
CScript zip.vbs "%~dp0\Log" "%userprofile%\desktop\BDO Logs\BDOLogDIR.zip" >nul 2>&1
xcopy "%~dp0\bin64\xigncode*" "%userprofile%\desktop\BDO Logs\" /sy >nul 2>&1
tracert 209.58.130.81 > "%userprofile%\desktop\BDO Logs\TracertNA.txt"
tracert 81.171.14.178 > "%userprofile%\desktop\BDO Logs\TracertEU.txt"
ping 209.58.130.81 -n 20 > "%userprofile%\desktop\BDO Logs\pingNA.txt"
ping 81.171.14.178 -n 20 > "%userprofile%\desktop\BDO Logs\pingEU.txt"
nslookup blackdesertonline.com > "%userprofile%\desktop\BDO Logs\nslookup.txt" >nul 2>&1
CScript zip.vbs "%userprofile%\desktop\BDO Logs" "%userprofile%\desktop\BDO Logs.zip" >nul 2>&1
Echo Complete.
Echo.
pause
goto menu
::Need to change up the way this works before using this command to log.
::call :menu >> "%userprofile%\desktop\BDO Logs\BDOTool.log" 2>&1

:menu
::Main Menu lets see if we can fix it.
cls
Echo OK down to business. Lets take a stab at whats happening.
Echo.
Echo 1 = Launcher Error/Connectivity Issues
Echo.
Echo 2 = File Corruption/Patching Issues
ECHO.
Echo 3 = Xigncode Crash
set choice=
ECHO.
set /p choice=
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto launchererr
if '%choice%'=='2' goto fileerr
if '%choice%'=='3' goto anticheaterr
goto menuwarn

:manuwarn
::Key trap for selecting something out of scope.
cls
Echo "Invalid Selection Please Try again..."
Echo.
pause
goto menu

:launchererr
cls
Echo                                                **LAUNCHER REPAIR SECTION**
Echo.
Echo In this section we will begin an automated sequence of events
Echo That generally fix launcher related issues.
Echo.
Echo Some of these tests will temporarily result in a lose of network connectivity.
Echo If the game is running it will also be closed.
Echo.
pause
cls
Echo Working
Echo.
Echo Close out of the completion Window when the program finishes.
Echo.
::Begin process kills
taskkill /F /IM "xm".exe >nul 2>&1
taskkill /F /IM "Black Desert Online Launcher".exe >nul 2>&1
taskkill /F /IM "BlackDesert64".exe >nul 2>&1
taskkill /F /IM "BlackDesert32".exe >nul 2>&1
taskkill /F /IM "CoherentUI_Host".exe >nul 2>&1
taskkill /F /IM "DGCefBrowser".exe >nul 2>&1
::Cleanup disk space.
CLEANMGR /verylowdisk >nul 2>&1
::Get new CEF file
bitsadmin /transfer DGCef /download /priority FOREGROUND https://www.teamdotexe.org/Downloads/DGCefBrowser.exe "C:\DGCefBrowser.exe" >nul 2>&1
MOVE /Y "C:\DGCefBrowser.exe" "%~dp0\DGCefBrowser.exe" >nul 2>&1
::Network Ops
netsh i i r r >nul 2>&1
netsh i i de ar >nul 2>&1
netsh winsock reset >nul 2>&1
netsh advfirewall reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
::Delete user/BDO Cache
RMDIR "%userprofile%\Documents\Black Desert\UserCache" /s /q >nul 2>&1
RMDIR "%~dp0\Cache" /s /q >nul 2>&1
CScript zip.vbs "%userprofile%\desktop\BDO Logs" "%userprofile%\desktop\BDO Logs.zip" >nul 2>&1
Echo Complete, Please attach the BDO Logs.zip file to a thread if issues persist.
Echo.
Echo Please reboot your machine.
Pause
goto cleanup


:fileerr
cls
Echo                                               **FILE REPAIR SECTION**
Echo.
Echo In this section we will begin an automated sequence of events
Echo That generally fix file related issues.
Echo.
Echo These tests will force a recheck of BDO files.
Echo I will start the launcher when preperations are complete.
Echo.
Echo If the game is running it will also be closed.
Echo.
pause
cls
Echo Working
Echo.
Echo This may take some time to complete depending on PC speed and files needed.
Echo.
Echo It is important to understand this is not a full download, even though it says "Downloading".
Echo This only checks for differences and downloads if required.
Echo.
Echo This is generally very CPU and Hard drive intensive.
Echo.
Echo When the launcher comes up please login to begin repairs.
Echo.
Echo When repairs complete and reach 100%% Please close the launcher. Script will continue.
Echo.
::Begin process kills
taskkill /F /IM "xm".exe >nul 2>&1
taskkill /F /IM "Black Desert Online Launcher".exe >nul 2>&1
taskkill /F /IM "BlackDesert64".exe >nul 2>&1
taskkill /F /IM "BlackDesert32".exe >nul 2>&1
taskkill /F /IM "CoherentUI_Host".exe >nul 2>&1
taskkill /F /IM "DGCefBrowser".exe >nul 2>&1
::Delete version to invoke repair also delete bad repair files.
::Rude ass DEVs wont give me command flags on the launcher to invoke repair without doing this!!!
DEL "%~dp0\version.dat" >nul 2>&1
DEL /s "%~dp0\*.PAP" >nul 2>&1
CALL "%~dp0\Black Desert Online Launcher.exe"
CScript zip.vbs "%userprofile%\desktop\BDO Logs" "%userprofile%\desktop\BDO Logs.zip" >nul 2>&1
Echo Complete.
Echo.
Echo Please attach the BDO Logs.zip file to a thread if issues persist.
Echo.
pause
goto cleanup

:anticheaterr
cls
Echo                                              **XIGNCODE REPAIR SECTION**
Echo.
Echo In this section we will begin an automated sequence of events
Echo That generally fix file xigncode related issues.
Echo.
Echo These tests will delete core xigncode files forcing a rebuild of them.
Echo.
Echo If the game is running it will also be closed.
Echo.
pause
Echo.
::Begin process kills
taskkill /F /IM "xm".exe >nul 2>&1
taskkill /F /IM "Black Desert Online Launcher".exe >nul 2>&1
taskkill /F /IM "BlackDesert64".exe >nul 2>&1
taskkill /F /IM "BlackDesert32".exe >nul 2>&1
taskkill /F /IM "CoherentUI_Host".exe >nul 2>&1
taskkill /F /IM "DGCefBrowser".exe >nul 2>&1
::Delete files
DEL /s "%~dp0\xmag.xem" >nul 2>&1
DEL C:\Windows\xhunter1.sys >nul 2>&1
Echo Complete.
Echo.
Echo Please attach the BDO Logs.zip file to a thread if issues persist.
Echo.
pause
goto cleanup

:cleanup
:: Lets cleanup the files we downloaded so people dont get mad.
rmdir "%userprofile%\desktop\BDO Logs" /s /q
DEL C:\windows\system32\zip.vbs
DEL C:\DGCefBrowser.exe
goto exit

:exit
exit