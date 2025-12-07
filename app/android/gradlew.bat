@ECHO OFF
SETLOCAL

SET DIR=%~dp0
SET APP_HOME=%DIR%
SET WRAPPER_DIR=%APP_HOME%gradle\wrapper
SET PROPERTIES_FILE=%WRAPPER_DIR%\gradle-wrapper.properties
SET WRAPPER_MAIN=%WRAPPER_DIR%\gradle-wrapper.jar
SET WRAPPER_SHARED=%WRAPPER_DIR%\gradle-wrapper-shared.jar
SET WRAPPER_REPO_BASE=https://repo.gradle.org/gradle/libs-releases-local/org/gradle

REM Extract wrapper version from distributionUrl
SET WRAPPER_VERSION=
IF EXIST "%PROPERTIES_FILE%" (
  FOR /F "usebackq tokens=*" %%A IN (`powershell -NoLogo -NoProfile -Command "($content = Get-Content '%PROPERTIES_FILE%') ^| Where-Object { $_ -match '^distributionUrl=' } ^| ForEach-Object { ($_ -replace '.*gradle-','') -replace '-(bin|all)\\.zip','' -replace '\\.zip','' }"`) DO (
    SET "WRAPPER_VERSION=%%A"
  )
)

CALL :DownloadJar "%WRAPPER_MAIN%" "gradle-wrapper"
CALL :DownloadJar "%WRAPPER_SHARED%" "gradle-wrapper-shared"

IF NOT EXIST "%WRAPPER_MAIN%" (
  ECHO ERROR: Gradle wrapper JAR is missing and could not be downloaded.
  EXIT /B 1
)

IF EXIST "%WRAPPER_SHARED%" (
  SET CLASSPATH=%WRAPPER_MAIN%;%WRAPPER_SHARED%
) ELSE (
  SET CLASSPATH=%WRAPPER_MAIN%
)

IF NOT "%JAVA_HOME%"=="" (
  SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
) ELSE (
  SET JAVA_EXE=java
)

"%JAVA_EXE%" -Dorg.gradle.appname=%~n0 -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
ENDLOCAL
GOTO :EOF

:DownloadJar
SET TARGET=%~1
SET ARTIFACT=%~2
IF EXIST "%TARGET%" GOTO :EOF
IF "%WRAPPER_VERSION%"=="" GOTO :EOF

SET URL=%WRAPPER_REPO_BASE%/%ARTIFACT%/%WRAPPER_VERSION%/%ARTIFACT%-%WRAPPER_VERSION%.jar
powershell -NoLogo -NoProfile -Command "try { (New-Object System.Net.WebClient).DownloadFile('%URL%','%TARGET%') } catch { exit 1 }"
GOTO :EOF
