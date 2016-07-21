/client/proc/cinematic(cinematic as anything in list("explosion",null))
	set name = "cinematic"
	set category = "Fun"
	set desc = "Shows a cinematic."	// Intended for testing but I thought it might be nice for events on the rare occasion Feel free to comment it out if it's not wanted.
	set hidden = 1
	if(!ticker)
		return
	switch(cinematic)
		if("explosion")
			var/parameter = input(src,"station_missed = ?","Enter Parameter",0) as num
			var/override
			switch(parameter)
				if(1)
					override = input(src,"mode = ?","Enter Parameter",null) as anything in list("nuclear emergency","gang war","fake","no override")
				if(0)
					override = input(src,"mode = ?","Enter Parameter",null) as anything in list("blob","nuclear emergency","AI malfunction","no override")
			ticker.station_explosion_cinematic(parameter,override)
	return