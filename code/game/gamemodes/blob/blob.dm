//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Few global vars to track the blob
var/list/blobs = list()
var/list/blob_cores = list()
var/list/blob_nodes = list()


/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

	required_players = 0
	required_enemies = 0

	restricted_jobs = list("Cyborg", "AI")

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/declared = 0

	var/cores_to_spawn = 1
	var/players_per_core = 26

	var/blob_count = 0
	var/blobnukecount = 300//Might be a bit low
	var/blobwincount = 600//Still needs testing

	var/list/infected_crew = list()

/datum/game_mode/blob/pre_setup()

	var/list/possible_blobs = get_players_for_role(BE_ALIEN)

	// stop setup if no possible traitors
	if(!possible_blobs.len)
		return 0

	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

	blobnukecount = initial(blobnukecount) * cores_to_spawn
	blobwincount = initial(blobwincount) * cores_to_spawn


	for(var/j = 0, j < cores_to_spawn, j++)
		if (!possible_blobs.len)
			break
		var/datum/mind/blob = pick(possible_blobs)
		infected_crew += blob
		blob.special_role = "Blob"
		log_game("[blob.key] (ckey) has been selected as a Blob")
		possible_blobs -= blob

	if(!infected_crew.len)
		return 0

	return 1


/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."


/datum/game_mode/blob/proc/greet_blob(var/datum/mind/blob)
	blob.current << "<B>\red You are infected by the Blob!</B>"
	blob.current << "<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>"
	blob.current << "<b>Find a good location to spawn the core and then take control and overwhelm the station!</b>"
	blob.current << "<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>"
	blob.current << "<b>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</b>"
	return

/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in infected_crew)
		greet_blob(blob)

	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1

	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()

	spawn(0)

		sleep(rand(waittime_l, waittime_h))

		send_intercept(0)


		sleep(rand(waittime_l, waittime_h))

		for(var/datum/mind/blob in infected_crew)
			blob.current << "<span class='alert'>You feel like you are about to burst.</span>"

		sleep(rand(waittime_l, waittime_h))

		for(var/datum/mind/blob in infected_crew)

			var/client/blob_client = null
			var/turf/location = null

			if(iscarbon(blob.current))
				var/mob/living/carbon/C = blob.current
				if(directory[ckey(blob.key)])
					blob_client = directory[ckey(blob.key)]
					location = get_turf(C)
					if(location.z != 1 || istype(location, /turf/space))
						location = null
					C.gib()


			if(blob_client && location)
				new /obj/effect/blob/core(location, 200, blob_client)

		// Stage 0
		sleep(40)
		stage(0)

		// Stage 1
		sleep(4000)
		stage(1)

	..()

/datum/game_mode/blob/proc/stage(var/stage)

	switch(stage)
		if (0)
			send_intercept(1)
			for (var/mob/living/silicon/ai/aiPlayer in living_mob_list)
				if (aiPlayer.client)
					var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving. NanoTrasen will not send an emergency shuttle under any circumstances."
					//var/law = "The station is under quarantine. The biohazard must be destroyed at all costs and must not be allowed to spread. Anyone using a space suit for any reason other than to destroy the biohazard is to be terminated. NanoTrasen will not send an emergency shuttle under any circumstances."
					aiPlayer.set_zeroth_law(law)
					aiPlayer << "Laws Updated: [law]"
			declared = 1
			return

		if (1)
			command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << sound('sound/AI/outbreak5.ogg')
			return

	return

