@echo off

SET TARGET_PLATFORM=x86_64-unknown-linux-gnu
SET UE_CXXLIB=F:\UnrealEngine\Engine\SourceThirdParty\Linux\LibCxx\include
SET CLANG_TOOLCHAIN=C:\UnrealToolchains\v13_clang-7.0.1-centos7\%TARGET_PLATFORM%
SET CLANG_BIN=%CLANG_TOOLCHAIN%\bin


SET HIREDIS_SRC=.

SET TEMP_PATH=build\obj
MKDIR %TEMP_PATH%
SET TEMP_PATH=%TEMP_PATH:\=/%

SET LIB_OUTPUT_PATH=build\lib\linux\%TARGET_PLATFORM%
MKDIR %LIB_OUTPUT_PATH%
SET LIB_OUTPUT_PATH=./%LIB_OUTPUT_PATH:\=/%

SET RESPONSE_FILE=build\hiredis.a.response
DEL /Q %RESPONSE_FILE%

SET COMPILE_INCLUDE=-I"%UE_CXXLIB:\=/%" -I"%UE_CXXLIB:\=/%/c++/5.2.0" -I"%HIREDIS_SRC:\=/%" -I"%HIREDIS_SRC:\=/%/adapters"
SET WNO_PARAMS=-Wno-unused-private-field -Wno-unused-local-typedef -Wno-tautological-compare -Wno-undefined-bool-conversion
SET WNO_PARAMS=%WNO_PARAMS% -Wno-inconsistent-missing-override -Wno-undefined-var-template -Wno-unused-lambda-capture -Wno-unused-variable
SET WNO_PARAMS=%WNO_PARAMS% -Wno-unused-function -Wno-switch -Wno-unknown-pragmas -Wno-invalid-offsetof -Wno-gnu-string-literal-operator-template 

SET COMPILE_PARAMS=-fPIC -c -pipe -nostdinc++ -Wall -Werror -funwind-tables -Wsequence-point -Wdelete-non-virtual-dtor -fno-math-errno
SET COMPILE_PARAMS=%COMPILE_PARAMS% -fno-rtti -fdiagnostics-format=msvc %WNO_PARAMS% -gdwarf-3 -O2 -fno-exceptions
SET COMPILE_PARAMS=%COMPILE_PARAMS% -DPLATFORM_EXCEPTIONS_DISABLED=1 -D_LINUX64 -target %TARGET_PLATFORM%
SET COMPILE_PARAMS=%COMPILE_PARAMS% %COMPILE_INCLUDE% --sysroot="%CLANG_TOOLCHAIN:\=/%" -x c++


call:COMPILE_TO_OBJECT "sds.c" "%TEMP_PATH%/sds.c.o"
call:COMPILE_TO_OBJECT "read.c" "%TEMP_PATH%/read.c.o"
call:COMPILE_TO_OBJECT "net.c" "%TEMP_PATH%/net.c.o"
call:COMPILE_TO_OBJECT "hiredis.c" "%TEMP_PATH%/hiredis.c.o" 
call:COMPILE_TO_OBJECT "dict.c" "%TEMP_PATH%/dict.c.o"
call:COMPILE_TO_OBJECT "async.c" "%TEMP_PATH%/async.c.o"
call:COMPILE_TO_OBJECT "sds.c" "%TEMP_PATH%/sds.c.o"

%CLANG_BIN%\x86_64-unknown-linux-gnu-ar.exe rc "%LIB_OUTPUT_PATH%/lhiredis.a" @"%RESPONSE_FILE%"
%CLANG_BIN%\x86_64-unknown-linux-gnu-ranlib.exe "%LIB_OUTPUT_PATH%/lhiredis.a"


pause
goto:eof

rem code, out
:COMPILE_TO_OBJECT
	SET SRC=%~1
	SET OUT=%~2
	echo. ...%SRC:~-13% ----^> %OUT%
	echo %~2 >> %RESPONSE_FILE%
	%CLANG_BIN%\clang++.exe %COMPILE_PARAMS% -o %~2 %~1
	goto:eof