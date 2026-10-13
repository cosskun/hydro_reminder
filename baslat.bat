@echo off
setlocal EnableDelayedExpansion
title HydroSoft Baslatici

REM Proje dizinine gecis yap
cd /d "%~dp0"

REM Flutter komutunu tespit et
set "FLUTTER_CMD="
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat"
) else if exist "C:\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=C:\flutter\bin\flutter.bat"
) else if exist "%USERPROFILE%\.puro\envs\stable\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%USERPROFILE%\.puro\envs\stable\flutter\bin\flutter.bat"
) else (
    where flutter >nul 2>nul
    if %errorlevel% equ 0 (
        set "FLUTTER_CMD=flutter"
    ) else (
        where puro >nul 2>nul
        if %errorlevel% equ 0 (
            set "FLUTTER_CMD=puro flutter"
        ) else if exist "C:\src\flutter\bin\flutter.bat" (
            set "FLUTTER_CMD=C:\src\flutter\bin\flutter.bat"
        ) else (
            set "FLUTTER_CMD=flutter"
        )
    )
)

:MENU
cls
echo =======================================================
echo               HYDROSOFT BASLATICI
echo =======================================================
echo.
echo  [1] Google Chrome ile Baslat (TAVSIYE EDILEN - Hizli ve Otomatik)
echo  [2] Web Sunucusu ile Baslat (flutter run -d web-server)
echo  [3] Microsoft Edge ile Baslat (flutter run -d edge)
echo  [4] Windows Masaustu Olarak Baslat (flutter run -d windows)
echo  [5] Bagli Cihazlari Listele (flutter devices)
echo  [6] Paketleri Yenile (flutter pub get)
echo  [7] Projeyi Temizle (flutter clean)
echo  [0] Cikis
echo.
echo =======================================================
set "SECIM=1"
set /p "SECIM=Lutfen bir secim yapin [Varsayilan: 1]: "

if "%SECIM%"=="1" goto RUN_CHROME
if "%SECIM%"=="2" goto RUN_WEBSERVER
if "%SECIM%"=="3" goto RUN_EDGE
if "%SECIM%"=="4" goto RUN_WINDOWS
if "%SECIM%"=="5" goto LIST_DEVICES
if "%SECIM%"=="6" goto PUB_GET
if "%SECIM%"=="7" goto CLEAN_PROJECT
if "%SECIM%"=="0" goto CIKIS
goto GECERSIZ

:RUN_CHROME
echo.
echo [*] HydroSoft Chrome uzerinde baslatiliyor (Release mod - En Hizli)...
echo.
cmd /c "%FLUTTER_CMD% run -d chrome --release"
goto BITTI

:RUN_WEBSERVER
echo.
echo [*] HydroSoft Web Sunucusu baslatiliyor (http://localhost:8080)...
echo.
cmd /c "%FLUTTER_CMD% run -d web-server --release --web-port=8080 --web-hostname=localhost"
goto BITTI

:RUN_EDGE
echo.
echo [*] HydroSoft Microsoft Edge uzerinde baslatiliyor (Release mod)...
echo.
cmd /c "%FLUTTER_CMD% run -d edge --release"
goto BITTI

:RUN_WINDOWS
echo.
echo [*] HydroSoft Windows uygulamasi olarak baslatiliyor...
echo.
cmd /c "%FLUTTER_CMD% run -d windows"
goto BITTI

:LIST_DEVICES
echo.
echo [*] Bagli cihazlar taraniyor...
echo.
cmd /c "%FLUTTER_CMD% devices"
echo.
pause
goto MENU

:PUB_GET
echo.
echo [*] Paketler indiriliyor ve guncelleniyor...
echo.
cmd /c "%FLUTTER_CMD% pub get"
echo.
pause
goto MENU

:CLEAN_PROJECT
echo.
echo [*] Proje gecici dosyalari temizleniyor...
echo.
cmd /c "%FLUTTER_CMD% clean"
echo.
pause
goto MENU

:GECERSIZ
echo.
echo [!] Gecersiz bir secim yaptiniz. Lutfen tekrar deneyin.
timeout /t 2 >nul
goto MENU

:BITTI
echo.
echo =======================================================
echo  Uygulama oturumu sonlandi veya durduruldu.
echo =======================================================
echo.
pause
goto MENU

:CIKIS
exit /b 0
