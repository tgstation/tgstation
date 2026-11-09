GLOBAL_DATUM(tower_of_babel, /datum/tower_of_babel)

/datum/tower_of_babel

/datum/tower_of_babel/New(mob/badmin)
	if(badmin)
		message_admins("[ADMIN_LOOKUPFLW(badmin)] has stricken the station with the Tower of Babel!")
		log_admin("[key_name(badmin)] used the Tower of Babel.")
		badmin.log_message("has stricken the station with the Tower of Babel!", LOG_GAME)

	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(handle_new_player))
	deadchat_broadcast("The [span_name("Tower of Babel")] has stricken the station, people will struggle to communicate.", message_type=DEADCHAT_ANNOUNCEMENT)

	for(var/mob/living/carbon/target in GLOB.player_list)
		if(!target.mind)
			continue
		if(IS_WIZARD(target) && !badmin)
			// wizards are not only immune but can speak all languages to taunt their victims over the radio
			target.grant_all_languages(source = LANGUAGE_BABEL)
			ADD_TRAIT(target.mind, TRAIT_TOWER_OF_BABEL, MAGIC_TRAIT)
			to_chat(target, span_reallybig(span_hypnophrase("You feel a magical force improving your speech patterns!")))
			continue

		if(target.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(target)
		if(curse_turf && !is_station_level(curse_turf.z) && !badmin) // badmin magic affects everyone
			continue

		curse_of_babel(target)

/datum/tower_of_babel/Destroy(force)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

	for(var/mob/living/carbon/target in GLOB.player_list)
		// some players might be off the z-level or dead but we still need to cure them
		cure_curse_of_babel(target)

/datum/tower_of_babel/proc/handle_new_player(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	curse_of_babel(new_crewmember)

/proc/curse_of_babel(mob/living/carbon/to_curse)
	// silicon mobs are immune
	if(!iscarbon(to_curse))
		return
	if(!to_curse.mind)
		return

	if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND) || HAS_MIND_TRAIT(to_curse, TRAIT_TOWER_OF_BABEL))
		to_chat(to_curse, span_notice("You have a strange feeling for a moment, but then it passes."))
		return

	to_curse.apply_status_effect(/datum/status_effect/tower_of_babel/magical, INFINITY)
	return TRUE

/// Mainly so admin triggered tower of babel can be undone
/proc/cure_curse_of_babel(mob/living/carbon/to_cure)
	if(!iscarbon(to_cure))
		return
	if(!to_cure.mind)
		return

	// anyone who has this trait from another source is immune to being cursed by tower of babel
	if(!HAS_TRAIT_FROM(to_cure.mind, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT))
		return

	to_cure.remove_status_effect(/datum/status_effect/tower_of_babel/magical)

/client/proc/tower_of_babel()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"The game hasn't started yet!")
		return

	GLOB.tower_of_babel = new /datum/tower_of_babel(usr)

/client/proc/tower_of_babel_undo()
	if(GLOB.tower_of_babel)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has cured the station from the effects of Tower of Babel!")
		log_admin("[key_name(usr)] has cured the station from the effects of Tower of Babel.")
		usr.log_message("has cured the station from the effects of Tower of Babel!", LOG_GAME)

		deadchat_broadcast("The [span_name("Tower of Babel")] has been cured, people will now communicate normally.", message_type=DEADCHAT_ANNOUNCEMENT)

		QDEL_NULL(GLOB.tower_of_babel)
