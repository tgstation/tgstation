/mob/living/carbon/human/lobby/proc/create_character(late_joiner = FALSE)
	var/mob/living/carbon/human/H = new(locate(1, 1, 1))    //TODO: Make some designated area for this

	if(CONFIG_GET(flag/force_random_names) || jobban_isbanned(src, "appearance"))
		client.prefs.random_character()
		client.prefs.real_name = client.prefs.pref_species.random_name(gender,1)
	client.prefs.copy_to(H)
	H.dna.update_dna_identity()
	if(mind)
		if(late_joiner)
			mind.late_joiner = TRUE
		mind.active = FALSE					//we wish to transfer the key manually
		mind.transfer_to(H)					//won't transfer key since the mind is not active

	//maybe unneccesary?
	H.name = H.real_name

	//Ughhhh
	H.should_abandon_siliconization_due_to_no_transform = FALSE

	. = H
	new_character = H
	new_character.notransform = !late_joiner

/mob/living/carbon/human/lobby/proc/transfer_character()
	. = new_character
	if(.)
		new_character.key = key		//Manually transfer the key to log them in
		new_character.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/mob/living/carbon/human/lobby/proc/AttemptJoin(obj/structure/lobby_teleporter/tele_to_tele)
	if(!SSticker.HasRoundStarted())
		to_chat(src, "<span class='danger'>The round is not ready!</span>")
		return
	
	if(!SSticker.IsRoundInProgress())
		to_chat(src, "<span class='danger'>The round has already finished!</span>")
		return

	var/relevant_cap = GetRelevantCap()

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums)))
		to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

		var/queue_position = SSticker.queued_players.Find(usr)
		if(queue_position == 1)
			to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
		else if(queue_position)
			to_chat(usr, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
		else
			SSticker.queued_players += usr
			to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
		return

	LateChoices(tele_to_tele)

/mob/living/carbon/human/lobby/proc/GetRelevantCap()
	//Determines Relevent Population Cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		return min(hpc, epc)
	return max(hpc, epc)

/mob/living/carbon/human/lobby/proc/AttemptLateSpawn(rank)
	if(!IsJobAvailable(rank))
		alert(src, "[rank] is not available. Please try another.")
		return FALSE

	if(SSticker.late_join_disabled)
		alert(src, "An administrator has disabled late join spawning.")
		return FALSE

	//Remove the player from the join queue if he was in one and reset the timer
	SSticker.queued_players -= src
	SSticker.queue_delay = 4

	var/arrivals_docked = TRUE
	if(SSshuttle.arrivals)
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			alert(src, "The arrivals shuttle is currently malfunctioning! You cannot join.")
			return FALSE

		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.RequireUndocked(src)
		arrivals_docked = SSshuttle.arrivals.mode != SHUTTLE_CALL

	SSjob.AssignRole(src, rank, 1)

	var/mob/living/character = create_character(TRUE)	//creates the human and transfers vars and mind
	late_picker.close()
	UNTIL(phase_in_complete)
	transfer_character()
	var/equip = SSjob.EquipRank(character, rank, 1)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	SSjob.SendToLateJoin(character)

	if(!arrivals_docked)
		//use a new splash scren here, the other is already dead
		PhaseOutSplashScreen(character)
		character.playsound_local(get_turf(character), 'sound/voice/ApproachingTG.ogg', 25)

	new_character = null
	qdel(src)

	character.update_parallax_teleport()

	SSticker.minds += character.mind

	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character	//Let's retypecast the var to be human,

	if(humanc)	//These procs all expect humans
		GLOB.data_core.manifest_inject(humanc)
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			AnnounceArrival(humanc, rank)
		AddEmploymentContract(humanc)
		if(GLOB.highlander)
			to_chat(humanc, "<span class='userdanger'><i>THERE CAN BE ONLY ONE!!!</i></span>")
			humanc.make_scottish()

		if(GLOB.summon_guns_triggered)
			give_guns(humanc)
		if(GLOB.summon_magic_triggered)
			give_magic(humanc)

	GLOB.joined_player_list += character.ckey

	if(CONFIG_GET(flag/allow_latejoin_antagonists) && humanc)	//Borgs aren't allowed to be antags. Will need to be tweaked if we get true latejoin ais.
		if(SSshuttle.emergency)
			switch(SSshuttle.emergency.mode)
				if(SHUTTLE_RECALL, SHUTTLE_IDLE)
					SSticker.mode.make_antag_chance(humanc)
				if(SHUTTLE_CALL)
					if(SSshuttle.emergency.timeLeft(1) > initial(SSshuttle.emergencyCallTime)*0.5)
						SSticker.mode.make_antag_chance(humanc)

	log_manifest(character.mind.key,character.mind,character,latejoin = TRUE)

/mob/living/carbon/human/lobby/proc/make_me_an_observer()
	if(SSticker.current_state < GAME_STATE_PREGAME)
		return FALSE

	var/this_is_like_playing_right = alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No")

	if(QDELETED(src) || this_is_like_playing_right != "Yes")
		instant_observer = FALSE
		return FALSE

	var/mob/dead/observer/observer = new
	spawning = TRUE
	observer.started_as_observer = TRUE
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	to_chat(src, "<span class='notice'>Now teleporting.</span>")
	if (O)
		observer.forceMove(O.loc)
	else
		to_chat(src, "<span class='notice'>Teleporting failed. Ahelp an admin please</span>")
		stack_trace("There's no freaking observer landmark available on this map!")
		qdel(observer)
		return FALSE

	QDEL_NULL(mind)
	observer.key = key  //Logout handles phaseout
	observer.set_ghost_appearance()
	if(observer.client && observer.client.prefs)
		observer.real_name = observer.client.prefs.real_name
		observer.name = observer.real_name
	observer.update_icon()
	observer.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	return TRUE

/mob/living/carbon/human/lobby/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	//TODO:  figure out a way to exclude wizards/nukeops/demons from this.
	for(var/C in GLOB.employmentCabinets)
		var/obj/structure/filingcabinet/employment/employmentCabinet = C
		if(!employmentCabinet.virgin)
			employmentCabinet.addFile(employee)

/mob/living/carbon/human/lobby/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		if(job.title == "Assistant")
			if(isnum(client.player_age) && client.player_age <= 14) //Newbies can always be assistants
				return TRUE
			for(var/datum/job/J in SSjob.occupations)
				if(J && J.current_positions < J.total_positions && J.title != job.title)
					return FALSE
		else
			return FALSE
	if(jobban_isbanned(src,rank))
		return FALSE
	if(!job.player_old_enough(src.client))
		return FALSE
	if(job.required_playtime_remaining(client))
		return FALSE
	return TRUE
