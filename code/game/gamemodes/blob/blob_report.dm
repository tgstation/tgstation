

/datum/game_mode/blob/send_intercept(report = 0)
	var/intercepttext = ""
	switch(report)
		if(1)
			intercepttext += "<FONT size = 3><b>NanoTrasen Update</b>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.<BR>"
			intercepttext += "Preliminary analysis of the organism classifies it as a level 5 biohazard. The origin of the biohazard is unknown.<BR>"
			intercepttext += "<b>Biohazard Response Procedure 5-6</b> has been issued for [station_name()].<BR>"
			intercepttext += "Orders for all [station_name()] personnel are as follows:<BR>"
			intercepttext += " 1. Locate any outbreaks of the organism on the station.<BR>"
			intercepttext += " 2. If found, use any neccesary means to contain and destroy the organism.<BR>"
			intercepttext += " 3. Avoid damage to the capital infrastructure of the station.<BR>"
			intercepttext += "<BR>Note in the event of a quarantine breach or uncontrolled spread of the biohazard, <b>Biohazard Response Procedure 5-12</b> may be issued.<BR>"
			print_command_report(intercepttext,"Level 5-6 Biohazard Response Procedures")
			priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')
		if(2)
			var/nukecode = random_nukecode()
			for(var/obj/machinery/nuclearbomb/bomb in machines)
				if(bomb && bomb.r_code)
					if(bomb.z == ZLEVEL_STATION)
						bomb.r_code = nukecode

			intercepttext += "<FONT size = 3><b>NanoTrasen Update</b>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Reports indicate that the biohazard has grown out of control and will soon reach critical mass.<BR>"
			intercepttext += "<b>Biohazard Response Procedure 5-12</b> has been issued for [station_name()].<BR>"
			intercepttext += "Orders for all [station_name()] personnel are as follows:<BR>"
			intercepttext += "1. Secure the Nuclear Authentication Disk.<BR>"
			intercepttext += "2. Detonate the Nuke located in the vault.<BR>"
			intercepttext += "Nuclear Authentication Code: [nukecode] <BR>"
			print_command_report(intercepttext,"Classified [command_name()] Update")
			priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

			for(var/mob/living/silicon/ai/aiPlayer in player_list)
				if (aiPlayer.client)
					var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
					aiPlayer.set_zeroth_law(law)
					to_chat(aiPlayer, "Laws Updated: [law]")
		else
			..()
	return



/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0
	var/num_territories = 1//Number of total valid territories for gang mode


/datum/station_state/proc/count(count_territories)
	for(var/turf/T in block(locate(1,1,1), locate(world.maxx,world.maxy,1)))

		if(isfloorturf(T))
			var/turf/open/floor/TF = T
			if(!(TF.burnt))
				src.floor += 12
			else
				src.floor += 1

		if(iswallturf(T))
			var/turf/closed/wall/TW = T
			if(TW.intact)
				src.wall += 2
			else
				src.wall += 1

		if(istype(T, /turf/closed/wall/r_wall))
			var/turf/closed/wall/r_wall/TRW = T
			if(TRW.intact)
				src.r_wall += 2
			else
				src.r_wall += 1


		for(var/obj/O in T.contents)
			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/GR = O
				if(!GR.broken)
					src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1

	if(count_territories)
		var/list/valid_territories = list()
		for(var/area/A in world) //First, collect all area types on the station zlevel
			if(A.z == ZLEVEL_STATION)
				if(!(A.type in valid_territories) && A.valid_territory)
					valid_territories |= A.type
		if(valid_territories.len)
			num_territories = valid_territories.len //Add them all up to make the total number of area types
		else
			to_chat(world, "ERROR: NO VALID TERRITORIES")

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)
		return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall/ max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)
