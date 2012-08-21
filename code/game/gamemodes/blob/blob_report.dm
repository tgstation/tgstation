//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode/blob/send_intercept(var/report = 1)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(1)
			interceptname = "Biohazard Alert"
			intercepttext += "<FONT size = 3><B>NanoTrasen Update</B>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.<BR>"
			intercepttext += "Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.<BR>"
			intercepttext += "NanoTrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.<BR>"
			intercepttext += "Orders for all [station_name()] personnel follows:<BR>"
			intercepttext += " 1. Do not leave the quarantine area.<BR>"
			intercepttext += " 2. Locate any outbreaks of the organism on the station.<BR>"
			intercepttext += " 3. If found, use any neccesary means to contain the organism.<BR>"
			intercepttext += " 4. Avoid damage to the capital infrastructure of the station.<BR>"
			intercepttext += "<BR>Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.<BR>"
			intercepttext += "Message ends."
		if(2)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in world)
				if(bomb && bomb.r_code)
					if(bomb.z == 1)
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext += "<FONT size = 3><B>NanoTrasen Update</B>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Directive 7-12 has been issued for [station_name()].<BR>"
			intercepttext += "The biohazard has grown out of control and will soon reach critical mass.<BR>"
			intercepttext += "Your orders are as follows:<BR>"
			intercepttext += "1. Secure the Nuclear Authentication Disk.<BR>"
			intercepttext += "2. Detonate the Nuke located in the Station's Vault.<BR>"
			intercepttext += "Nuclear Authentication Code: [nukecode] <BR>"
			intercepttext += "Message ends."

			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				if (aiPlayer.client)
					var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
					aiPlayer.set_zeroth_law(law)
					aiPlayer << "Laws Updated: [law]"

	for(var/obj/machinery/computer/communications/comm in world)
		comm.messagetitle.Add(interceptname)
		comm.messagetext.Add(intercepttext)
		if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
	return



/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0


	proc/count()
		for(var/turf/T in world)
			if(T.z != 1)
				continue

			if(istype(T,/turf/simulated/floor))
				if(!(T:burnt))
					src.floor += 12
				else
					src.floor += 1

			if(istype(T, /turf/simulated/wall))
				if(T:intact)
					src.wall += 2
				else
					src.wall += 1

			if(istype(T, /turf/simulated/wall/r_wall))
				if(T:intact)
					src.r_wall += 2
				else
					src.r_wall += 1

		for(var/obj/O in world)
			if(O.z != 1)
				continue

			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille) && (!O:destroyed))
				src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1
		return


	proc/score(var/datum/station_state/result)
		if(!result)	return 0
		var/output = 0
		output += (result.floor / max(floor,1))
		output += (result.r_wall/ max(r_wall,1))
		output += (result.wall / max(wall,1))
		output += (result.window / max(window,1))
		output += (result.door / max(door,1))
		output += (result.grille / max(grille,1))
		output += (result.mach / max(mach,1))
		return (output/7)
