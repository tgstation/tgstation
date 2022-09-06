GLOBAL_DATUM(tower_of_babel, /datum/tower_of_babel)

/datum/tower_of_babel

/datum/tower_of_babel/New(mob/badmin)
	if(badmin)
		to_chat(badmin, span_warning("You have stricken the station with the Tower of Babel!"))
		message_admins("[ADMIN_LOOKUPFLW(badmin)] has stricken the station with the Tower of Babel!")
		log_admin("[key_name(badmin)] used the Tower of Babel.")
		badmin.log_message("has stricken the station with the Tower of Babel!", LOG_GAME)

	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/handle_new_player)
	deadchat_broadcast("The [span_name("Tower of Babel")] has stricken the station, people will struggle to communicate.", message_type=DEADCHAT_ANNOUNCEMENT)

	for(var/mob/living/carbon/target in GLOB.player_list)
		if(IS_WIZARD(target) && !badmin)
			// wizards are not only immune but can speak all languages to taunt their victims over the radio
			target.grant_all_languages(source=LANGUAGE_BABEL)
			ADD_TRAIT(target, TRAIT_TOWER_OF_BABEL, MAGIC_TRAIT)
			to_chat(target, span_reallybig(span_hypnophrase("You feel a magical force improving your speech patterns!")))
			continue

		if(target.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(target)
		if(curse_turf && !is_station_level(curse_turf.z) && !badmin) // badmin magic affects everyone
			continue

		curse_of_babel(target)

/datum/tower_of_babel/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

	for(var/mob/living/carbon/target in GLOB.player_list)
		// some players might be off the z-level or dead but we still need to cure them
		cure_curse_of_babel(target)

/proc/handle_new_player(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	curse_of_babel(new_crewmember)

/proc/curse_of_babel(mob/living/carbon/to_curse)
	if(!istype(to_curse))
		return

	if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND) || HAS_TRAIT(to_curse, TRAIT_TOWER_OF_BABEL))
		to_chat(to_curse, span_notice("You have a strange feeling for a moment, but then it passes."))
		return

	var/random_language = pick(GLOB.all_languages)
	to_curse.grant_language(random_language, source = LANGUAGE_BABEL)
	// block every language except the randomized one
	to_curse.add_blocked_language(GLOB.all_languages - random_language, source = LANGUAGE_BABEL)
	// this lets us bypass tongue language restrictions except for people who have stuff like mute,
	// no tongue, tongue tied, etc. curse of babel shouldn't let people who have a tongue disability speak
	ADD_TRAIT(to_curse, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT)

	to_curse.playsound_local(get_turf(to_curse), 'sound/magic/magic_block_mind.ogg', 75, vary = TRUE) // sound of creepy whispers
	to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))
	return TRUE

/// Mainly so admin triggered tower of babel can be undone
/proc/cure_curse_of_babel(mob/living/carbon/to_cure)
	if(!istype(to_cure))
		return

	if(!HAS_TRAIT_FROM(to_cure, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT))
		return

	// if user is affected by tower of babel, we remove the blocked languages
	// but the randomized language they learned from curse of babel is kept
	to_cure.remove_blocked_language(GLOB.all_languages, source = LANGUAGE_BABEL)
	REMOVE_TRAIT(to_cure, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT)
	to_chat(to_cure, span_reallybig(span_hypnophrase("You feel the magical force affecting your speech patterns fade away...")))

/client/proc/tower_of_babel()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"The game hasn't started yet!")
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] has stricken the station with the Tower of Babel!"))
	log_admin("[key_name(usr)] used the Tower of Babel.")

	GLOB.tower_of_babel = new /datum/tower_of_babel(usr)

/client/proc/tower_of_babel_undo()
	if(GLOB.tower_of_babel)
		if(usr)
			to_chat(usr, span_warning("You have cured the station from the effects of Tower of Babel!"))
			message_admins("[ADMIN_LOOKUPFLW(usr)] has cured the station from the effects of Tower of Babel!")
			log_admin("[key_name(usr)] has cured the station from the effects of Tower of Babel.")
			usr.log_message("has cured the station from the effects of Tower of Babel!", LOG_GAME)

		deadchat_broadcast("The [span_name("Tower of Babel")] has been cured, people will now communicate normally.", message_type=DEADCHAT_ANNOUNCEMENT)

		QDEL_NULL(GLOB.tower_of_babel)
