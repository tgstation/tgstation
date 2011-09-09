/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"
	required_players = 0

	var/stage = 0
	var/next_stage = 0


/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."


/datum/game_mode/blob/post_setup()
	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()
	spawn (20)
		var/turf/location = pick(blobstart)

		blobs = list()
		new /obj/blob(location)
	..()


/datum/game_mode/blob/process()
	if (prob(2))
		spawn_meteors()

	life()

	stage()


/datum/game_mode/blob/proc/life()
	if (blobs.len > 0)
		for (var/i = 1 to 25)
			if (blobs.len == 0)
				break

			var/obj/blob/B = pick(blobs)
			if(B.z != 1)
				continue

			for (var/atom/A in B.loc)
				A.blob_act()

			B.Life()


/datum/game_mode/blob/proc/stage()
	// initial stage timing
	if (!next_stage)
		// sometime between 20s to 1m30s after round start
		next_stage = world.timeofday + rand(200, 900)

	if (world.timeofday < next_stage)
		return

	switch (stage)
		if (0)
			var/dat = ""
			dat += "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT><HR>"
			dat += "Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.<BR>"
			dat += "Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.<BR>"
			dat += "Cent. Com. has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.<BR>"
			dat += "Orders for all [station_name()] personnel follows:<BR>"
			dat += " 1. Do not leave the quarantine area.<BR>"
			dat += " 2. Locate any outbreaks of the organism on the station.<BR>"
			dat += " 3. If found, use any neccesary means to contain the organism.<BR>"
			dat += " 4. Avoid damage to the capital infrastructure of the station.<BR>"
			dat += "<BR>Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12 without further notice.<BR>"
			dat += "Message ends."

			for (var/obj/machinery/computer/communications/C in machines)
				if(! (C.stat & (BROKEN|NOPOWER) ) )
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
					P.name = "paper- 'Cent. Com. Biohazard Alert.'"
					P.info = dat
					C.messagetitle.Add("Cent. Com. Biohazard Alert")
					C.messagetext.Add(P.info)

			world << "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT>"
			world << "\red Summary downloaded and printed out at all communications consoles."
			for (var/mob/living/silicon/ai/aiPlayer in world)
				if (aiPlayer.client)
					var/law = "The station is under a quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving."
					aiPlayer.set_zeroth_law(law)
					aiPlayer << "An additional law has been added by CentCom: [law]"

			stage = 1
			// next stage 5-10 minutes later
			next_stage = world.timeofday + 600*rand(5,10)

		if (1)
			command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")

			stage = 2
			// now check every minute
			next_stage = world.timeofday + 600

		if (2)
			if (blobs.len > 500)
				command_alert("Uncontrolled spread of the biohazard onboard the station. We have issued directive 7-12 for [station_name()]. Estimated time until directive implementation: 60 seconds.", "Biohazard Alert")
				stage = 3
				next_stage = world.timeofday + 600
			else
				next_stage = world.timeofday + 600

		if (3)
			stage = 4
			var/turf/ground_zero = locate("landmark*blob-directive")

			if (ground_zero)
				ground_zero = get_turf(ground_zero)
			else
				ground_zero = locate(45,45,1)

			explosion(ground_zero, 100, 250, 500, 750)


/datum/game_mode/blob/check_finished()
	if(stage >= 4)
		return 1

	for(var/obj/blob/B in blobs)
		if(B.z == 1)
			return 0
	return 1


/datum/game_mode/blob/declare_completion()
	if (stage == 4)
		world << "<FONT size = 3><B>The staff has lost!</B></FONT>"
		world << "<B>The station was destroyed by Cent. Com.</B>"
		var/numDead = 0
		var/numAlive = 0
		var/numSpace = 0
		var/numOffStation = 0
		for (var/mob/living/silicon/ai/aiPlayer in world)
			for(var/mob/M in world)
				if ((M != aiPlayer && M.client))
					if (M.stat == 2)
						numDead += 1
					else
						var/T = M.loc
						if (istype(T, /turf/space))
							numSpace += 1
						else if(istype(T, /turf))
							if (M.z!=1)
								numOffStation += 1
							else
								numAlive += 1
			if (numSpace==0 && numOffStation==0)
				world << "<FONT size = 3><B>The AI has won!</B></FONT>"
				world << "<B>The AI successfully maintained the quarantine - no players were in space or were off-station (as far as we can tell).</B>"
				log_game("AI won at Blob mode despite overall loss.")
			else
				world << "<FONT size = 3><B>The AI has lost!</B></FONT>"
				world << text("<B>The AI failed to maintain the quarantine - [] were in space and [] were off-station (as far as we can tell).</B>", numSpace, numOffStation)
				log_game("AI lost at Blob mode.")

		log_game("Blob mode was lost.")

		return 1

	else
		world << "<FONT size = 3><B>The staff has won!</B></FONT>"
		world << "<B>The alien organism has been eradicated from the station</B>"

		var/datum/station_state/end_state = new /datum/station_state()
		end_state.count()

		var/percent = round( 100.0 *  start_state.score(end_state), 0.1)

		world << "<B>The station is [percent]% intact.</B>"

		log_game("Blob mode was won with station [percent]% intact.")

		world << "\blue Rebooting in 30s"

	..()
	return 1
