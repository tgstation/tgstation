<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Few global vars to track the blob
var/list/blobs = list() //complete list of all blobs made.
var/list/blob_cores = list()
var/list/overminds = list()
var/list/blob_nodes = list()
var/list/blobs_legit = list() //used for win-score calculations, contains only blobs counted for win condition

#define BLOB_NO_PLACE_TIME 1800 //time, in deciseconds, blobs are prevented from bursting in the gamemode

/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"
	antag_flag = ROLE_BLOB

	required_players = 25
	required_enemies = 1
	recommended_enemies = 1

	round_ends_with_antag_death = 1

	announce_span = "green"
	announce_text = "Dangerous gelatinous organisms are spreading throughout the station!\n\
	<span class='green'>Blobs</span>: Consume the station and spread as far as you can.\n\
	<span class='notice'>Crew</span>: Fight back the blobs and minimize station damage."

	var/burst = 0

	var/cores_to_spawn = 1
	var/players_per_core = 25
	var/blob_point_rate = 3

	var/blobwincount = 350

	var/messagedelay_low = 2400 //in deciseconds
	var/messagedelay_high = 3600 //blob report will be sent after a random value between these (minimum 4 minutes, maximum 6 minutes)

	var/list/blob_overminds = list()

/datum/game_mode/blob/pre_setup()
	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

	blobwincount = initial(blobwincount) * cores_to_spawn

	for(var/j = 0, j < cores_to_spawn, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/blob = pick(antag_candidates)
		blob_overminds += blob
		blob.assigned_role = "Blob"
		blob.special_role = "Blob"
		log_game("[blob.key] (ckey) has been selected as a Blob")
		antag_candidates -= blob

	if(!blob_overminds.len)
		return 0

	return 1

/datum/game_mode/blob/proc/get_blob_candidates()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!player.stat && player.mind && !player.mind.special_role && !jobban_isbanned(player, "Syndicate") && (ROLE_BLOB in player.client.prefs.be_special))
			if(age_check(player.client))
				candidates += player
	return candidates

/datum/game_mode/blob/proc/show_message(message)
	for(var/datum/mind/blob in blob_overminds)
		blob.current << message

/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in blob_overminds)
		var/mob/camera/blob/B = blob.current.become_overmind(1)
		var/turf/T = pick(blobstart)
		B.loc = T
		B.base_point_rate = blob_point_rate

	SSshuttle.registerHostileEnvironment(src)

	// Disable the blob event for this round.
	var/datum/round_event_control/blob/B = locate() in SSevent.control
	if(B)
		B.max_occurrences = 0 // disable the event

	spawn(0)
		var/message_delay = rand(messagedelay_low, messagedelay_high) //between 4 and 6 minutes with 2400 low and 3600 high.

		sleep(message_delay)

		send_intercept(1)

		sleep(24000) //40 minutes, plus burst_delay*3(minimum of 6 minutes, maximum of 8)

		send_intercept(2) //if the blob has been alive this long, it's time to bomb it

	return ..()
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Few global vars to track the blob
var/list/blobs = list()
var/list/blob_cores = list()
var/list/blob_nodes = list()
var/list/blob_resources = list()
var/list/blob_overminds = list()


/datum/game_mode/blob
	name = "Blob"
	config_tag = "Blob"

	required_players = 15
	required_players_secret = 25
	restricted_jobs = list("Cyborg", "AI", "Mobile MMI", "Trader")

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/declared = 0
	var/outbreak = 0
	var/nuclear = 0

	var/cores_to_spawn = 15
	var/players_per_core = BLOB_CORE_PROPORTION
	var/blob_point_rate = 3

	var/blobwincount = 750 // WAS: 500
	var/blobnukeposs = 650 // At this point the nuke has a chance of being authorized by Centcomm

	var/list/infected_crew = list()
	var/list/pre_escapees = list()

/datum/game_mode/blob/pre_setup()

	var/list/possible_blobs = get_players_for_role(ROLE_BLOB)

	// stop setup if no possible traitors
	if(!possible_blobs.len)
		log_admin("Failed to set-up a round of blob. Couldn't find any volunteers to be blob.")
		message_admins("Failed to set-up a round of blob. Couldn't find any volunteers to be blob.")
		return 0

	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

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
		log_admin("Failed to set-up a round of blob. Couldn't select any crew members to infect.")
		message_admins("Failed to set-up a round of blob. Couldn't select any crew members to infect.")
		return 0

	log_admin("Starting a round of blob with [infected_crew.len] starting blobs.")
	message_admins("Starting a round of blob with [infected_crew.len] starting blobs.")
	return 1


/datum/game_mode/blob/announce()
	to_chat(world, {"<B>The current game mode is - <span class='blob'>Blob!</span></B>
<B>A dangerous alien organism is rapidly spreading throughout the station!</B>
You must kill it all while minimizing the damage to the station."})


/datum/game_mode/blob/proc/greet_blob(var/datum/mind/blob)
	to_chat(blob.current, {"<B><span class='warning'>You are infected by the Blob!</B>
<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>
<b>Find a good location to spawn the core and then take control and overwhelm the station! Make sure you are ON the station when you burst!</b>
<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>
<b>If you go outside of the station level, or in space, then you will die; make sure your location has plenty of space to expand.</b></span>"})
	return

/datum/game_mode/blob/proc/show_message(var/message)
	for(var/datum/mind/blob in infected_crew)
		to_chat(blob.current, message)

/datum/game_mode/blob/proc/burst_blobs()
	for(var/datum/mind/blob in infected_crew)

		var/client/blob_client = null
		var/turf/location = null

		if(iscarbon(blob.current))
			var/mob/living/carbon/C = blob.current

			for(var/obj/item/W in C)
				C.drop_from_inventory(W)

			if(directory[ckey(blob.key)])
				blob_client = directory[ckey(blob.key)]
				location = get_turf(C)
				if(location.z != 1 || istype(location, /turf/space))
					location = null
				qdel(C)


		if(blob_client && location)
			var/obj/effect/blob/core/core = new(location, 200, blob_client, blob_point_rate)
			if(core.overmind && core.overmind.mind)
				core.overmind.mind.name = blob.name
				infected_crew -= blob
				infected_crew += core.overmind.mind


/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in infected_crew)
		greet_blob(blob)

	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1

	/*// Disable the blob event for this round.
	if(events)
		var/datum/round_event_control/blob/B = locate() in events.control
		if(B)
			B.max_occurrences = 0 // disable the event
	else
		error("Events variable is null in blob gamemode post setup.")*/

	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()

	spawn(0)

		var/wait_time = rand(waittime_l, waittime_h)

		sleep(wait_time)

		if(!mixed) send_intercept(0)

		sleep(100)

		show_message("<span class='alert'>You feel tired and bloated.</span>")

		sleep(wait_time)

		show_message("<span class='alert'>You feel like you are about to burst.</span>")

		sleep(wait_time / 2)

		burst_blobs()

		// Stage 0
		sleep(rand(600,1200))
		stage(0)

		// Stage 1
		sleep(rand(2000,2400))
		stage(1)
	..()

/datum/game_mode/blob/proc/stage(var/stage)


	switch(stage)
		if (0)
			biohazard_alert()
			declared = 1
			return

		if (1)
			command_alert("Biohazard outbreak alert status upgraded to level 9.  [station_name()] is now locked down, under Directive 7-10, until further notice.", "Directive 7-10 Initiated",1,alert='sound/AI/blob_confirmed.ogg')
			for(var/mob/M in player_list)
				var/T = M.loc
				if((istype(T, /turf/space)) || ((istype(T, /turf)) && (M.z!=1)))
					pre_escapees += M
			if(!mixed) send_intercept(1)
			outbreak = 1

			research_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice." //LOCKDOWN THESE SHUTTLES
			mining_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice."
		if (2)
			command_alert("Biohazard outbreak containment status reaching critical mass, total quarantine failure is now possibile. As such, Directive 7-12 has now been authorized for [station_name()].", "Final Measure",1)
			for(var/mob/camera/blob/B in player_list)
				to_chat(B, "<span class='blob'>The beings intend to eliminate you with a final suicidal attack, you must stop them quickly or consume the station before this occurs!</span>")
			if(!mixed) send_intercept(2)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
