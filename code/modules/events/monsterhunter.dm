/datum/round_event_control/bloodsucker_hunters
	name = "Spawn Monster Hunter - Bloodsucker"
	typepath = /datum/round_event/bloodsucker_hunters
	max_occurrences = 1 // We have to see how Bloodsuckers are in game to decide if having more than 1 is beneficial.
	weight = 4
	min_players = 10
	earliest_start = 35 MINUTES
	alert_observers = FALSE

/datum/round_event/bloodsucker_hunters
	fakeable = FALSE
	var/cancel_me = TRUE

/datum/round_event/bloodsucker_hunters/start()
	for(var/mob/living/carbon/human/all_players in GLOB.player_list)
		if(IS_BLOODSUCKER(all_players))
			message_admins("BLOODSUCKER NOTICE: Monster Hunters found a valid Bloodsucker.")
			cancel_me = FALSE
			break
	if(cancel_me)
		kill()
		return
	for(var/mob/living/carbon/human/all_players in shuffle(GLOB.player_list))
		if(!all_players.client || !all_players.mind || !(ROLE_MONSTERHUNTER in all_players.client.prefs.be_special))
			continue
		if(all_players.stat == DEAD)
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.nonhuman_positions)) // Only crewmembers on-station.
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.security_positions))
			continue
		if(IS_BLOODSUCKER(all_players) || IS_VASSAL(all_players) || IS_HERETIC(all_players) || IS_CULTIST(all_players) || IS_WIZARD(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			continue
		if(!all_players.getorgan(/obj/item/organ/brain))
			continue
		all_players.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("BLOODSUCKER NOTICE: [all_players] has awoken as a Monster Hunter.")
		announce_to_ghosts(all_players)
		break

/datum/round_event_control/monster_hunters
	name = "Spawn Monster Hunter"
	typepath = /datum/round_event/monster_hunters
	max_occurrences = 1
	weight = 1
	min_players = 10
	earliest_start = 25 MINUTES
	alert_observers = TRUE

/datum/round_event/monster_hunters
	fakeable = FALSE
	var/cancel_me = TRUE

/datum/round_event/monster_hunters/start()
	for(var/mob/living/carbon/human/all_players in GLOB.player_list)
		if( IS_CULTIST(all_players) || IS_HERETIC(all_players) || IS_WIZARD(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			message_admins("MONSTERHUNTER NOTICE: Monster Hunters found a valid Monster.")
			cancel_me = FALSE
			break
	if(cancel_me)
		kill()
		return
	for(var/mob/living/carbon/human/all_players in shuffle(GLOB.player_list))
		/// From obsessed
		if(!all_players.client || !all_players.mind || !(ROLE_MONSTERHUNTER in all_players.client.prefs.be_special))
			continue
		if(all_players.stat == DEAD)
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.nonhuman_positions)) // Only crewmembers on-station.
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.security_positions))
			continue
		/// Bobux no IS_CHANGELING
		if(IS_HERETIC(all_players) || IS_CULTIST(all_players) || IS_WIZARD(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			continue
		if(!all_players.getorgan(/obj/item/organ/brain))
			continue
		all_players.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("MONSTERHUNTER NOTICE: [all_players] has awoken as a Monster Hunter.")
		announce_to_ghosts(all_players)
		break 
