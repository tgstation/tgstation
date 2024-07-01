///Adds the mob reference to the list and directory of all mobs. Called on Initialize().
/mob/proc/add_to_mob_list()
	GLOB.mob_list |= src

///Removes the mob reference from the list and directory of all mobs. Called on Destroy().
/mob/proc/remove_from_mob_list()
	GLOB.mob_list -= src

///Adds the mob reference to the list of all mobs alive. If mob is cliented, it adds it to the list of all living player-mobs.
/mob/proc/add_to_alive_mob_list()
	if(QDELETED(src))
		return
	GLOB.alive_mob_list |= src
	if(client)
		add_to_current_living_players()

///Removes the mob reference from the list of all mobs alive. If mob is cliented, it removes it from the list of all living player-mobs.
/mob/proc/remove_from_alive_mob_list()
	GLOB.alive_mob_list -= src
	if(client)
		remove_from_current_living_players()

///Adds a mob reference to the list of all suicided mobs
/mob/proc/add_to_mob_suicide_list()
	GLOB.suicided_mob_list += src

///Removes a mob references from the list of all suicided mobs
/mob/proc/remove_from_mob_suicide_list()
	GLOB.suicided_mob_list -= src

///Adds the mob reference to the list of all the dead mobs. If mob is cliented, it adds it to the list of all dead player-mobs.
/mob/proc/add_to_dead_mob_list()
	if(QDELETED(src))
		return
	GLOB.dead_mob_list |= src
	if(client)
		add_to_current_dead_players()

///Remvoes the mob reference from list of all the dead mobs. If mob is cliented, it adds it to the list of all dead player-mobs.
/mob/proc/remove_from_dead_mob_list()
	GLOB.dead_mob_list -= src
	if(client)
		remove_from_current_dead_players()


///Adds the cliented mob reference to the list of all player-mobs, besides to either the of dead or alive player-mob lists, as appropriate. Called on Login().
/mob/proc/add_to_player_list()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.player_list |= src
	if(client.holder)
		GLOB.keyloop_list |= src
	else if(stat != DEAD || !SSlag_switch?.measures[DISABLE_DEAD_KEYLOOP])
		GLOB.keyloop_list |= src
	if(stat == DEAD)
		add_to_current_dead_players()
	else
		add_to_current_living_players()

///Removes the mob reference from the list of all player-mobs, besides from either the of dead or alive player-mob lists, as appropriate. Called on Logout().
/mob/proc/remove_from_player_list()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.player_list -= src
	GLOB.keyloop_list -= src
	if(stat == DEAD)
		remove_from_current_dead_players()
	else
		remove_from_current_living_players()


///Adds the cliented mob reference to either the list of dead player-mobs or to the list of observers, depending on how they joined the game.
/mob/proc/add_to_current_dead_players()
	GLOB.dead_player_list |= src

/mob/dead/observer/add_to_current_dead_players()
	if(started_as_observer)
		GLOB.current_observers_list |= src
		return
	return ..()

/mob/dead/new_player/add_to_current_dead_players()
	return

///Removes the mob reference from either the list of dead player-mobs or from the list of observers, depending on how they joined the game.
/mob/proc/remove_from_current_dead_players()
	GLOB.dead_player_list -= src

/mob/dead/observer/remove_from_current_dead_players()
	if(started_as_observer)
		GLOB.current_observers_list -= src
		return
	return ..()


///Adds the cliented mob reference to the list of living player-mobs. If the mob is an antag, it adds it to the list of living antag player-mobs.
/mob/proc/add_to_current_living_players()
	GLOB.alive_player_list |= src
	if(mind && (mind.special_role || length(mind.antag_datums)))
		add_to_current_living_antags()

///Removes the mob reference from the list of living player-mobs. If the mob is an antag, it removes it from the list of living antag player-mobs.
/mob/proc/remove_from_current_living_players()
	GLOB.alive_player_list -= src
	if(LAZYLEN(mind?.antag_datums))
		remove_from_current_living_antags()


///Adds the cliented mob reference to the list of living antag player-mobs.
/mob/proc/add_to_current_living_antags()
	if (length(mind.antag_datums) == 0)
		return

	for (var/datum/antagonist/antagonist in mind.antag_datums)
		if (antagonist.count_against_dynamic_roll_chance)
			GLOB.current_living_antags |= src
			return

///Removes the mob reference from the list of living antag player-mobs.
/mob/proc/remove_from_current_living_antags()
	GLOB.current_living_antags -= src
