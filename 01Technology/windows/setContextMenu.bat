echo off
color 1f
:start
cls
echo,
echo     修改右键菜单模式
echo,
echo   1 Windows 10 传统模式
echo,
echo   2 Windows 11 默认模式
echo,
echo,
echo,
echo   0 放弃修改，退出
echo,
echo,
choice /c:120 /n /m:"请选择要使用的模式"
if %errorlevel%==0 exit
if %errorlevel%==2 goto cmd2
if %errorlevel%==1 goto cmd1
exit


:cmd1
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
taskkill /f /im explorer.exe & start explorer.exe
@REM shutdown -l
exit

:cmd2
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe & start explorer.exe
@REM shutdown -l
exit