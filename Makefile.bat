cd /D "%~dp0"
set ASM=C:\jac\system\Atari800\Tools\ASM\ATASM\atasm.exe
set MADS=C:\jac\system\Atari800\Tools\ASM\MADS\mads.exe

DEL *.xex
%MADS% JHV2002-Fade.asm -o:JHV2002-Fade.xex
if ERRORLEVEL 1 goto :mads_error
%MADS% JHV2002-Devil.asm -o:JHV2002-Devil.xex
if ERRORLEVEL 1 goto :mads_error
%ASM% JHV2002-Main.asm -oJHV2002-Main.xex
if ERRORLEVEL 1 goto :atasm_error

copy /b JHV2002-Fade.xex + /b JHV2002-Devil.xex JHV2002.xex /b

rem copy /b JHV2002-Fade.xex + /b JHV2002-Devil.xex + /b JHV2002-Main.xex JHV2002.xex /b

pause
start JHV2002.xex
goto :eof

:mads_error
pause

:atasm_error
pause


