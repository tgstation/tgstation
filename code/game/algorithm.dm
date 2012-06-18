//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/world/New()
	..()

	diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	diary << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------
"}

	diaryofmeanpeople = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")] Attack.log")
	diaryofmeanpeople << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------
"}

	href_logfile = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")] hrefs.html")

	jobban_loadbanfile()
	jobban_updatelegacybans()
	LoadBans()
	process_teleport_locs() //Sets up the wizard teleport locations
	process_ghost_teleport_locs() //Sets up ghost teleport locations.
	sleep_offline = 1

	if (config.kick_inactive)
		spawn(30)
			KickInactiveClients()

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	for(var/client/C)
		if( !C.holder && (C.inactivity >= INACTIVITY_KICK) )
			if(C.mob)
				if(!istype(C.mob, /mob/dead/))
					log_access("AFK: [key_name(C)]")
					C << "\red You have been inactive for more than 10 minutes and have been disconnected."
			del(C)
	spawn(3000) KickInactiveClients()//more or less five minutes

/// EXPERIMENTAL STUFF

// This function counts a passed job.
proc/countJob(rank)
	var/jobCount = 0
	for(var/mob/H in world)
		if(H.mind && H.mind.assigned_role == rank)
			jobCount++
	return jobCount

/proc/AutoUpdateAI(obj/subject)
	if (subject!=null)
		for(var/mob/living/silicon/ai/M in world)
			if ((M.client && M.machine == subject))
				subject.attack_ai(M)

/proc/AutoUpdateTK(obj/subject)
	if (subject!=null)
		for(var/obj/item/tk_grab/T in world)
			if (T.host)
				var/mob/M = T.host
				if(M.client && M.machine == subject)
					subject.attack_hand(M)
