@echo off
SETLOCAL EnableDelayedExpansion
goto :main

:main
SETLOCAL

rem Configuration
rem Change these values to reflect your environment
SET AWS_PROFILE=cloud9
SET AWS_REGION=us-east-1
SET MAX_ITERATION=5
SET SLEEP_DURATION=5

rem # For debug
echo "Host %HOST%"
echo "PORT %PORT%"
echo %AWS_PROFILE%

@echo on
aws ssm describe-instance-information ^
	--filters Key=InstanceIds,Values=%HOST% ^
	--output text ^
	--query InstanceInformationList[0].PingStatus ^
	--profile %AWS_PROFILE% ^
	--region %AWS_REGION% > %USERPROFILE%\.ssh\status.temp
@echo off
SET /p STATUS=<%USERPROFILE%\.ssh\status.temp

rem If the instance is online, start the session

IF "%STATUS%" == "Online" (
	aws ssm start-session --target %HOST% ^
	--document-name AWS-StartSSHSession ^
	--parameters portNumber=%PORT% ^
	--profile %AWS_PROFILE% ^
	--region %AWS_REGION%
) ELSE (
	aws ec2 start-instances --instance-ids %HOST% --profile %AWS_PROFILE% --region %AWS_REGION%
	sleep %SLEEP_DURATION%  

	SET /a COUNT=1
	SET /a MAX_ITERATION=5

	:loop
	if !COUNT! LEQ !MAX_ITERATION! (
		@echo on
		aws ssm describe-instance-information ^
			--filters Key=InstanceIds,Values=%HOST% ^
			--output text ^
			--query InstanceInformationList[0].PingStatus ^
			--profile %AWS_PROFILE% ^
			--region %AWS_REGION% > %USERPROFILE%\.ssh\status.temp
		@echo off
		SET /p STATUS=<%USERPROFILE%\.ssh\status.temp
		
		IF "%STATUS%" == "Online" (
			GOTO :start_session
		)
		echo RETRY !COUNT!
		set /a COUNT=!COUNT!+1
		TIMEOUT /t %SLEEP_DURATION% > NUL

		GOTO :loop
	)

	EXIT /b 1
	echo.
	echo Outside of loop^^!

	:start_session
	rem Instance is online now - start the session
	aws ssm start-session --target %HOST% ^
	--document-name AWS-StartSSHSession ^
	--parameters portNumber=%PORT% ^
	--profile %AWS_PROFILE% ^
	--region %AWS_REGION%
)

ENDLOCAL

EXIT /b 0

rem Host HOSTNAME_ALIAS
rem   HostName i-asdfgxcvb98ubcxbv
rem   IdentityFile C:\Users\{user}\.ssh\id_rsa
rem   User ec2-user
rem   Port 22
rem   ProxyCommand  C:\Users\{user}\.ssh\ssm-proxy.bat %h %p

rem  !!! %USERPROFILE% not working
