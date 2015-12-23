@echo off
call rsvars.bat
msbuild msa.dproj /t:build /p:Platform=Win32 /p:config="Release"
msbuild msa.dproj /t:build /p:Platform=Win64 /p:config="Release"
pause