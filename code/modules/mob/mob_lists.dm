/mob/proc/add_to_mob_list()
	GLOB.mob_list += src
	GLOB.mob_directory[tag] = src

/mob/proc/remove_from_mob_list()
	GLOB.mob_list -= src
	GLOB.mob_directory -= tag


/mob/proc/add_to_alive_mob_list()
	GLOB.alive_mob_list += src
	if(client)
		add_to_current_living_players()

/mob/proc/remove_from_alive_mob_list()
	GLOB.alive_mob_list -= src
	if(client)
		remove_from_current_living_players()


/mob/proc/add_to_dead_mob_list()
	GLOB.dead_mob_list += src
	if(client)
		add_to_current_dead_players()

/mob/proc/remove_from_dead_mob_list()
	GLOB.dead_mob_list -= src
	if(client)
		remove_from_current_dead_players()


/mob/proc/add_to_player_list()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.player_list |= src
	if(!SSticker?.mode)
		return
	if(stat == DEAD)
		add_to_current_dead_players()
	else
		add_to_current_living_players()

/mob/dead/observer/add_to_player_list()
	. = ..()
	if(!SSticker?.mode)
		return
	if(started_as_observer)
		SSticker.mode.current_players[CURRENT_OBSERVERS] |= src

/mob/proc/remove_from_player_list()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.player_list -= src
	if(!SSticker?.mode)
		return
	if(stat == DEAD)
		remove_from_current_dead_players()
	else
		remove_from_current_living_players()

/mob/dead/observer/remove_from_player_list()
	. = ..()
	if(!SSticker?.mode)
		return
	if(started_as_observer)
		SSticker.mode.current_players[CURRENT_OBSERVERS] -= src


/mob/proc/add_to_current_dead_players()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_DEAD_PLAYERS] |= src

/mob/dead/observer/add_to_current_dead_players()
	if(!SSticker?.mode)
		return
	if(started_as_observer)
		SSticker.mode.current_players[CURRENT_OBSERVERS] |= src
		return
	return ..()

/mob/dead/new_player/add_to_current_dead_players()
	return

/mob/proc/remove_from_current_dead_players()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_DEAD_PLAYERS] -= src

/mob/dead/observer/remove_from_current_dead_players()
	if(!SSticker?.mode)
		return
	if(started_as_observer)
		SSticker.mode.current_players[CURRENT_OBSERVERS] -= src
		return
	return ..()


/mob/proc/add_to_current_living_players()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_LIVING_PLAYERS] |= src
	if(mind && (mind.special_role || length(mind.antag_datums)))
		add_to_current_living_antags()

/mob/proc/remove_from_current_living_players()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_LIVING_PLAYERS] -= src
	if(LAZYLEN(mind?.antag_datums))
		remove_from_current_living_antags()


/mob/proc/add_to_current_living_antags()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_LIVING_ANTAGS] |= src

/mob/proc/remove_from_current_living_antags()
	if(!SSticker?.mode)
		return
	SSticker.mode.current_players[CURRENT_LIVING_ANTAGS] -= src
