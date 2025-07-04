@REM scg-cli launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM SCG_CLI_config.txt found in the SCG_CLI_HOME.
@setlocal enabledelayedexpansion
@setlocal enableextensions

@echo off


if "%SCG_CLI_HOME%"=="" (
  set "APP_HOME=%~dp0\\.."

  rem Also set the old env name for backwards compatibility
  set "SCG_CLI_HOME=%~dp0\\.."
) else (
  set "APP_HOME=%SCG_CLI_HOME%"
)

set "APP_LIB_DIR=%APP_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%APP_HOME%\SCG_CLI_config.txt"
set CFG_OPTS=
call :parse_config "%CFG_FILE%" CFG_OPTS

rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

set "APP_CLASSPATH=%APP_LIB_DIR%\com.virtuslab.semanticgraphs.scg-cli-0.1.10-SNAPSHOT.jar;%APP_LIB_DIR%\javaparser.javaparser-0.1.0-SNAPSHOT.jar;%APP_LIB_DIR%\parsercommons.parsercommons-0.1.0-SNAPSHOT.jar;%APP_LIB_DIR%\commons.commons-0.1.0-SNAPSHOT.jar;%APP_LIB_DIR%\org.scala-lang.scala3-library_3-3.3.1.jar;%APP_LIB_DIR%\com.thesamet.scalapb.scalapb-runtime_3-0.11.13.jar;%APP_LIB_DIR%\com.lihaoyi.os-lib_3-0.9.0.jar;%APP_LIB_DIR%\info.picocli.picocli-4.7.0.jar;%APP_LIB_DIR%\com.github.javaparser.javaparser-core-3.24.0.jar;%APP_LIB_DIR%\com.github.javaparser.javaparser-symbol-solver-core-3.24.0.jar;%APP_LIB_DIR%\org.jgrapht.jgrapht-core-1.5.1.jar;%APP_LIB_DIR%\org.jgrapht.jgrapht-io-1.5.1.jar;%APP_LIB_DIR%\com.lihaoyi.upickle_3-3.1.2.jar;%APP_LIB_DIR%\org.apache.commons.commons-compress-1.23.0.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.13.10.jar;%APP_LIB_DIR%\com.thesamet.scalapb.lenses_3-0.11.13.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-3.19.6.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-collection-compat_3-2.9.0.jar;%APP_LIB_DIR%\com.lihaoyi.geny_3-1.0.0.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.2.10.jar;%APP_LIB_DIR%\com.typesafe.scala-logging.scala-logging_3-3.9.4.jar;%APP_LIB_DIR%\com.typesafe.config-1.4.2.jar;%APP_LIB_DIR%\org.eclipse.jgit.org.eclipse.jgit-6.0.0.202111291000-r.jar;%APP_LIB_DIR%\org.javassist.javassist-3.28.0-GA.jar;%APP_LIB_DIR%\com.google.guava.guava-31.0.1-jre.jar;%APP_LIB_DIR%\org.jheaps.jheaps-0.13.jar;%APP_LIB_DIR%\org.antlr.antlr4-runtime-4.8-1.jar;%APP_LIB_DIR%\org.apache.commons.commons-text-1.8.jar;%APP_LIB_DIR%\com.lihaoyi.ujson_3-3.1.2.jar;%APP_LIB_DIR%\com.lihaoyi.upack_3-3.1.2.jar;%APP_LIB_DIR%\com.lihaoyi.upickle-implicits_3-3.1.2.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.2.10.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.32.jar;%APP_LIB_DIR%\com.googlecode.javaewah.JavaEWAH-1.1.13.jar;%APP_LIB_DIR%\com.google.guava.failureaccess-1.0.1.jar;%APP_LIB_DIR%\com.google.guava.listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.2.jar;%APP_LIB_DIR%\org.checkerframework.checker-qual-3.12.0.jar;%APP_LIB_DIR%\com.google.errorprone.error_prone_annotations-2.7.1.jar;%APP_LIB_DIR%\com.google.j2objc.j2objc-annotations-1.3.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.9.jar;%APP_LIB_DIR%\com.lihaoyi.upickle-core_3-3.1.2.jar"
set "APP_MAIN_CLASS=org.virtuslab.semanticgraphs.analytics.cli.ScgCli"
set "SCRIPT_CONF_FILE=%APP_HOME%\conf\application.ini"

rem Bundled JRE has priority over standard environment variables
if defined BUNDLED_JVM (
  set "_JAVACMD=%BUNDLED_JVM%\bin\java.exe"
) else (
  if "%JAVACMD%" neq "" (
    set "_JAVACMD=%JAVACMD%"
  ) else (
    if "%JAVA_HOME%" neq "" (
      if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
    )
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running scg-cli.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)

rem if configuration files exist, prepend their contents to the script arguments so it can be processed by this runner
call :parse_config "%SCRIPT_CONF_FILE%" SCRIPT_CONF_ARGS

call :process_args %SCRIPT_CONF_ARGS% %%*

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !SCG_CLI_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal

exit /B %ERRORLEVEL%


rem Loads a configuration file full of default command line options for this script.
rem First argument is the path to the config file.
rem Second argument is the name of the environment variable to write to.
:parse_config
  set _PARSE_FILE=%~1
  set _PARSE_OUT=
  if exist "%_PARSE_FILE%" (
    FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%_PARSE_FILE%") DO (
      set _PARSE_OUT=!_PARSE_OUT! %%i
    )
  )
  set %2=!_PARSE_OUT!
exit /B 0


:add_java
  set _JAVA_PARAMS=!_JAVA_PARAMS! %*
exit /B 0


:add_app
  set _APP_ARGS=!_APP_ARGS! %*
exit /B 0


rem Processes incoming arguments and places them in appropriate global variables
:process_args
  :param_loop
  call set _PARAM1=%%1
  set "_TEST_PARAM=%~1"

  if ["!_PARAM1!"]==[""] goto param_afterloop


  rem ignore arguments that do not start with '-'
  if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
  set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  shift
  goto param_loop

  :param_java_check
  if "!_TEST_PARAM:~0,2!"=="-J" (
    rem strip -J prefix
    set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
    shift
    goto param_loop
  )

  if "!_TEST_PARAM:~0,2!"=="-D" (
    rem test if this was double-quoted property "-Dprop=42"
    for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
      if not ["%%H"] == [""] (
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      ) else if [%2] neq [] (
        rem it was a normal property: -Dprop=42 or -Drop="42"
        call set _PARAM1=%%1=%%2
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
        shift
      )
    )
  ) else (
    if "!_TEST_PARAM!"=="-main" (
      call set CUSTOM_MAIN_CLASS=%%2
      shift
    ) else (
      set _APP_ARGS=!_APP_ARGS! !_PARAM1!
    )
  )
  shift
  goto param_loop
  :param_afterloop

exit /B 0
