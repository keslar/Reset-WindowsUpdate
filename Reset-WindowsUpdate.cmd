@ECHO OFF
REM 
REM Reset Windows Update Database
REM

REM Create time stamp

REM YEAR
SET TIMESTAMP=%date:~-4%_
REM MONTH
IF "%date:~4,1%" == " " (
	SET TIMESTAMP=%TIMESTAMP%0%date:~5,1%_
) ELSE (
	SET TIMESTAMP=%TIMESTAMP%0%date:~4,2%_
)
REM DAY
IF "%date:~7,1%" == " " (
	SET TIMESTAMP=%TIMESTAMP%0%date:~7,1%_
) ELSE (
	SET TIMESTAMP=%TIMESTAMP%0%date:~7,1%_
)
REM HOUR
IF "%time:~0,1%" == " " (
	SET TIMESTAMP=%TIMESTAMP%0%time:~1,1%_
) ELSE (
	SET TIMESTAMP=%TIMESTAMP%%time:~0,2%_
)
REM MINUTESSEC
SET TIMESTAMP=%TIMESTAMP%%time:~3,2%_%time:~6,2%

ECHO %TIMESTAMP%

REM The list of Windows Update Services
SET UPDATESERVICES=wuauserv cryptSvc bits msiserver

REM Stop the servervices
for %%s in ( %UPDATESERVICES% ) DO NET stop %%s 

REM Delete files from the Microsoft Downloader cache
DEL /F /Q "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\*.*"

REM Move the current SoftwareDistrobution and Catroot2 folder aside for safe keeping
REN %windir%\SoftwareDistrobution SoftwareDistrobution.%TIMESTAMP%
REN %windir%\catroot2 Catroot2.%TIMESTAMP%

REM Reset the security descriptors on BITS and Windows Update Services
sc.exe sdset bits D:(A##CCLCSWRPWPDTLOCRRC###SY)(A##CCDCLCSWRPWPDTLOCRSDRCWDWO###BA)(A##CCLCSWLOCRRC###AU)(A##CCLCSWRPWPDTLOCRRC###PU)
sc.exe sdset wuauserv D:(A##CCLCSWRPWPDTLOCRRC###SY)(A##CCDCLCSWRPWPDTLOCRSDRCWDWO###BA)(A##CCLCSWLOCRRC###AU)(A##CCLCSWRPWPDTLOCRRC###PU) 

REM Re-register important DLL'safe
SET DLLS2REREG=atl.dll urlmon.dll mshtml.dll shdocvw.dll browseui.dll jscript.dll vbscript.dll scrrun.dll msxml.dll msxml3.dll msxml6.dll actxprxy.dll softpub.dll wintrust.dll dssenh.dll rsaenh.dll gpkcsp.dll sccbase.dll slbcsp.dll cryptdlg.dll oleaut32.dll ole32.dll shell32.dll initpki.dll wuapi.dll wuaueng.dll wuaueng1.dll wucltui.dll wups.dll wups2.dll wuweb.dll qmgr.dll qmgrprxy.dll wucltux.dll muweb.dll wuwebv.dll
PUSHD %windir%
FOR %%f in ( %DLLS2RESET% ) DO (
	IF EXIST %%f regsvr32 /s %%f
)
POPD

REM Reset the network connection just in case
netsh winsock reset
netsh winsock reset proxy


REM Start services
for %%s in ( %UPDATESERVICES% ) DO NET stop %%s 

REM Reboot
SHUTDOWN /r /f /d p:2:4