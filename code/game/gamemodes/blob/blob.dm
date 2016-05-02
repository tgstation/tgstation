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

	var/burst = 0

	var/cores_to_spawn = 1
	var/players_per_core = 20
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

/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."

/datum/game_mode/blob/proc/show_message(message)
	for(var/datum/mind/blob in blob_overminds)
		blob.current << message

/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in blob_overminds)
		var/mob/camera/blob/B = blob.current.become_overmind(1)
		var/turf/T = pick(blobstart)
		B.loc = T
		B.base_point_rate = blob_point_rate

	SSshuttle.emergencyNoEscape = 1

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
