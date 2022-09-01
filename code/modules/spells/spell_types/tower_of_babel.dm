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
		if(target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			to_chat(target, span_notice("You have a strange feeling for a moment, but then it passes."))
			continue

		curse_of_babel(target)

// it would be cool to make this into a spell or staff in the future
/proc/curse_of_babel(mob/living/carbon/to_curse)
	if(!istype(to_curse))
		return

	to_curse.playsound_local(get_turf(to_curse), 'sound/magic/curse.ogg', 40, 1)
	to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))
	to_curse.remove_all_languages()
	var/random_language = pick(GLOB.all_languages)
	to_curse.grant_language(random_language)
	to_curse.remove_blocked_language(random_language, LANGUAGE_ALL)
	//to_curse.update_atom_languages() // double check if this is neccessary
