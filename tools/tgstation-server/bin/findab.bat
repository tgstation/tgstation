@del gamecode\a\updater.temp >nul 2>nul
@del gamecode\b\updater.temp >nul 2>nul

echo test >gamefolder\updater.temp

if exist gamefolder\%PROJECTNAME%.rsc.lk (
	rem we attempt to delete the lock file to see if the server is currently running.
	del /q gamefolder\%PROJECTNAME%.rsc.lk >nul 2>nul
	if exist gamefolder\%PROJECTNAME%.rsc.lk set RUNNING=1
)

if exist gamecode\a\updater.temp (
	if defined RUNNING (
		echo Current folder detected to be the "A" folder. Game is currently running. Updating to the "B" folder.
		set AB=b
	) else (
		echo Current folder detected to be the "A" folder. Game is not currently running, Updating to the "A" folder.
		set AB=a
	)
) else if exist gamecode\b\updater.temp (
	if defined RUNNING (
		echo Current folder detected to be the "B" folder. Game is currently running, Updating to the "A" folder.
		set AB=a
	) else (
		echo Current folder detected to be the "B" folder. Game is not currently running, Updating to the "B" folder.
		set AB=b
	)
)
@del gamefolder\updater.temp >nul 2>nul