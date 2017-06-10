del gamecode\a\updater.temp >nul 2>nul
del gamecode\b\updater.temp >nul 2>nul

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
		if exist gamecode\b\%PROJECTNAME%.rsc.lk (
			rem we attempt to delete the lock file to see if the server is currently running.
			del /q gamecode\b\%PROJECTNAME%.rsc.lk >nul 2>nul
			if exist gamecode\b\%PROJECTNAME%.rsc.lk set RUNNING=1
			rmdir /q gamefolder
			mklink /d gamefolder gamecode\b >nul
			echo Game is in actually currently running on the "B" folder, Resetting current folder to the "B" folder first
		)
		set AB=a
	)
) else if exist gamecode\b\updater.temp (
	if defined RUNNING (
		echo Current folder detected to be the "B" folder. Game is currently running, Updating to the "A" folder.
		set AB=a
	) else (
		echo Current folder detected to be the "B" folder. Game is not currently running, Updating to the "B" folder.
		if exist gamecode\a\%PROJECTNAME%.rsc.lk (
			rem we attempt to delete the lock file to see if the server is currently running.
			del /q gamecode\a\%PROJECTNAME%.rsc.lk >nul 2>nul
			if exist gamecode\a\%PROJECTNAME%.rsc.lk set RUNNING=1
			rmdir /q gamefolder
			mklink /d gamefolder gamecode\a >nul
			echo Game is in actually currently running on the "A" folder, Resetting current folder to the "A" folder first
		)
		set AB=b
	)
)
del gamefolder\updater.temp >nul 2>nul