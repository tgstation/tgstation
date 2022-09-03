GLOBAL_VAR_INIT(tower_of_babel_triggered, FALSE)

/proc/tower_of_babel(mob/user)
	if(user) // badmin
		to_chat(user, span_warning("You have stricken the station with the Tower of Babel!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] has stricken the station with the Tower of Babel!")
		user.log_message("has stricken the station with the Tower of Babel!", LOG_GAME)

	deadchat_broadcast("The [span_name("Tower of Babel")] has stricken the station, people will struggle to communicate.", message_type=DEADCHAT_ANNOUNCEMENT)
	GLOB.tower_of_babel_triggered = TRUE // So latejoiners are also afflicted

	for(var/mob/living/carbon/target in GLOB.player_list)
		// wizards are not only immune but can speak all languages to taunt their victims over the radio
		if(IS_WIZARD(target))
			target.grant_all_languages()
			//target.update_atom_languages() // double check if this is neccessary
			to_chat(target, span_reallybig(span_hypnophrase("You feel a magical force improving your speech patterns!")))
			continue

		if(target.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(target)
		if(curse_turf && !is_station_level(curse_turf.z))
			continue
		if(target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND) || HAS_TRAIT(target, TRAIT_CURSE_OF_BABEL_IMMUNITY))
			to_chat(target, span_notidce("You have a strange feeling for a moment, but then it passes."))
			continue

		curse_of_babel(target)

/proc/curse_of_babel(mob/living/carbon/to_curse)
	if(!istype(to_curse))
		return

	var/random_language = pick(GLOB.all_languages)
	to_curse.grant_language(random_language, source=LANGUAGE_CURSE_OF_BABEL)
	// block every language except the randomized one
	to_curse.add_blocked_language(GLOB.all_languages - random_language, LANGUAGE_CURSE_OF_BABEL)

	// this lets us bypass tongue language restrictions except for people who have stuff like mute,
	// no tongue, tongue tied, etc. curse of babel shouldn't let people who have a tongue disability speak
	ADD_TRAIT(to_curse, TRAIT_CURSE_OF_BABEL, MAGIC_TRAIT)

	to_curse.playsound_local(get_turf(to_curse), 'sound/magic/curse.ogg', 40, 1)
	to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))

/// Mainly so admin triggered tower of babel can be undone
/proc/cure_curse_of_babel(mob/living/carbon/to_cure)
	if(!istype(to_cure))
		return



	var/random_language = pick(GLOB.all_languages)
	to_cure.grant_language(random_language, source=LANGUAGE_CURSE_OF_BABEL)
	// block every language except the randomized one
	to_cure.add_blocked_language(GLOB.all_languages - random_language, LANGUAGE_CURSE_OF_BABEL)

	// this lets us bypass tongue language restrictions except for people who have stuff like mute,
	// no tongue, tongue tied, etc. curse of babel shouldn't let people who have a tongue disability speak
	ADD_TRAIT(to_cure, TRAIT_CURSE_OF_BABEL, MAGIC_TRAIT)


	//to_cure.remove_all_languages()
	to_cure.remove_blocked_language(random_language, LANGUAGE_ALL)
	//to_cure.update_atom_languages() // double check if this is neccessary

	to_cure.playsound_local(get_turf(to_cure), 'sound/magic/curse.ogg', 40, 1)
	to_chat(to_cure, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))
