/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"
	required_players = 0

	var/const/waittime_l = 2000 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 3000 //upper bound on time before intercept arrives (in tenths of seconds)

	var
		declared = 0
		stage = 0
		next_stage = 0
		autoexpand = 0


/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."


/datum/game_mode/blob/post_setup()
	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()

	spawn(rand(waittime_l, waittime_h))
		message_admins("Blob spawned and expanding, report created")

		blobs = list()
		active_blobs = list()
		for(var/i = 1 to 3)
			var/turf/location = pick(blobstart)
			if(location)
				if(!locate(/obj/blob in location))
					var/obj/blob/blob = new/obj/blob(location)
					spawn(200)
						if(blob)
							if(blob.blobtype == "Blob")
								blob.blobdebug = 1
		spawn(40)
			autoexpand = 1
			declared = 1
	..()


/datum/game_mode/blob/process()
	if(declared)
		stage()
		if(autoexpand)
			spawn(0)
				life()
	return


/datum/game_mode/blob/proc/life()
	if (blobs.len > 0)
		for(var/i = 1 to 10)
			sleep(-1)
			if (blobs.len == 0)
				break

			var/obj/blob/B = pick(active_blobs)
			if(B.z != 1)
				continue

//			spawn(0)
			B.Life()


/datum/game_mode/blob/proc/stage()//Still needs worrrrrk
	if (world.timeofday < next_stage)
		return

	switch(stage)
		if (0)
			send_intercept(1)
			for (var/mob/living/silicon/ai/aiPlayer in world)
				if (aiPlayer.client)
					var/law = "The station is under a quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving."
					aiPlayer.set_zeroth_law(law)
					aiPlayer << "Laws Updated: [law]"
			stage = 1
			// next stage 3-6 minutes later
			next_stage = world.timeofday + 600*rand(3,6)

		if (1)
			command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
			world << sound('outbreak5.ogg')
			autoexpand = 0//The blob now has to live on its own
			stage = 2
			// now check every minute
			next_stage = world.timeofday + 600

		if (2)
			if((blobs.len > 500) && (declared == 1))
				command_alert("Uncontrolled spread of the biohazard onboard the station. We have issued directive 7-12 for [station_name()].  Any living Heads of Staff are ordered to enact directive 7-12 at any cost, a print out with detailed instructions has been sent to your communications computers.", "Biohazard Alert")
				send_intercept(2)
				declared = 2
			if(blobs.len > 700)
				stage = 3
			next_stage = world.timeofday + 600


/datum/game_mode/blob/check_finished()
	if(!declared)
		return 0
	if(stage >= 3)
		return 1
	if(station_was_nuked)
		return 1
	for(var/obj/blob/B in blobs)
		if(B.z == 1)
			return 0
	return 1


/datum/game_mode/blob/declare_completion()
	if(stage >= 3)
		world << "<FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		world << "<B>The entire station was eaten by the Blob</B>"
		check_quarantine()

	else if(station_was_nuked)
		world << "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		world << "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>"

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


/datum/game_mode/blob/send_intercept(var/orders = 1)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(orders)
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
			intercepttext += "Nuclear Authentication Code: [nukecode]"
			intercepttext += "Message ends."

	for(var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext

			comm.messagetitle.Add(interceptname)
			comm.messagetext.Add(intercepttext)




//	world << sound('outbreak5.ogg')Quiet printout for now

//	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
//	world << sound('intercept.ogg')
/datum/game_mode/blob/proc/check_quarantine()
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