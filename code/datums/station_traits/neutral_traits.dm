/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/unnatural_atmosphere
	name = "Unnatural atmospherical properties"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "System's local planet has irregular atmospherical properties"
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/simple_animal/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/simple_animal/pet/dog/corgi/ian) || istype(dog, /mob/living/simple_animal/pet/dog/corgi/puppy/ian)))
			continue

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)


/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Please be nice to him."
	blacklist = list(/datum/station_trait/announcement_medbot)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/protagonist
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 0
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	report_message = "This station has received an esteemed guest! They will most likely be a high value target for any Syndicate invasions. Be sure to keep them safe!"
	blacklist = list()
	///What role to give to the picked player
	var/datum/antagonist/role_to_give
	//The mind of the player that was picked
	var/datum/mind/picked_mind
	//The antag datum instance for the protagonist we are creating
	var/datum/antagonist/antag_datum_instance


/datum/station_trait/protagonist/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_PRE_GAMEMODE_SETUP, .proc/on_gamemode_setup)
	RegisterSignal(SSdcs, COMSIG_GLOB_POST_GAMEMODE_SETUP, .proc/after_gamemode_setup)
	antag_datum_instance = new role_to_give() //Create this early for things such as family name to be setup

/// Checks if candidates are connected and if they are banned or don't want to be the antagonist.
/datum/station_trait/protagonist/proc/trim_candidates(list/candidates)
	for(var/mob/dead/new_player/candidate_player as anything in candidates)
		var/client/candidate_client = GET_CLIENT(candidate_player)
		if (!candidate_client || !candidate_player.mind) // Are they connected?
			candidates.Remove(candidate_player)
			continue

		if(candidate_player.mind.special_role) // No double antags!
			candidates.Remove(candidate_player)
			continue

		if(!(ROLE_PROTAGONIST in candidate_client.prefs.be_special) || is_banned_from(candidate_player.ckey, list(ROLE_PROTAGONIST, ROLE_SYNDICATE)))
			candidates.Remove(candidate_player)
			continue

/datum/station_trait/protagonist/proc/on_gamemode_setup(datum/gamemode/gamemode_ref)
	SIGNAL_HANDLER
	var/list/candidates = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && player.check_preferences())
			candidates.Add(player)
	trim_candidates(candidates)
	if(!candidates)
		return null
	var/mob/dead/new_player/picked_player = pick(candidates)
	picked_mind = picked_player.mind

	picked_mind.assigned_role = ROLE_PROTAGONIST
	picked_mind.special_role = ROLE_PROTAGONIST
	SSstation.protagonists += picked_mind


/datum/station_trait/protagonist/proc/after_gamemode_setup(datum/gamemode/gamemode_ref)
	SSjob.SendToLateJoin(picked_mind.current)
	picked_mind.add_antag_datum(antag_datum_instance)

/datum/station_trait/protagonist/scaredy_prince
	name = "Royal Visit"
	report_message = "This station has received an esteemed guest! They will most likely be a high value target for any Syndicate invasions. Be sure to keep them safe! It seems this guest is a royal prince or princess! Although they are of royal blood, they don't seem to be the most brave person."
	role_to_give = /datum/antagonist/protagonist/scaredy_prince
	weight = 4
	trait_flags = NONE

///Pick a family name and put it in the title!
/datum/station_trait/protagonist/scaredy_prince/New()
	. = ..()
	var/datum/antagonist/protagonist/scaredy_prince/prince_antag_datum = antag_datum_instance
	name = "Royalty from house [prince_antag_datum.family_name]"

/datum/station_trait/protagonist/nanotrasen_superweapon
	name = "Superweapon"
	report_message = "Central Command is sending the only surviving test subject in a superweapon project. You should be careful, they are incredibly frail and Syndicate Agents will see them as an easy target to cripple Nanotrasen."
	role_to_give = /datum/antagonist/protagonist/nanotrasen_superweapon
	weight = 4
	trait_flags = NONE
