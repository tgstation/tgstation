GLOBAL_VAR_INIT(tower_of_babel_triggered, FALSE)

/proc/tower_of_babel(mob/user)
	if(user) // badmin
		to_chat(user, span_warning("You have stricken the station with the Tower of Babel!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] has stricken the station with the Tower of Babel!")
		user.log_message("has stricken the station with the Tower of Babel!", LOG_GAME)

	deadchat_broadcast("The [span_name("Tower of Babel")] has stricken the station, people will struggle to communicate.", message_type=DEADCHAT_ANNOUNCEMENT)

	for(var/mob/living/carbon/to_curse in GLOB.player_list)
		// wizards are not only immune but can speak all languages to taunt their victims over the radio
		if(IS_WIZARD(to_curse))
			to_curse.grant_all_languages()
			to_curse.update_atom_languages() // double check if this is neccessary
			to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force improving your speech patterns!")))
			continue

		if(to_curse.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(to_curse)
		if(curse_turf && !is_station_level(curse_turf.z))
			continue
		if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			to_chat(to_curse, span_notice("You have a strange feeling for a moment, but then it passes."))
			continue

		// it would be cool to make this into a spell or staff in the future
		to_curse.playsound_local(get_turf(to_curse), 'sound/magic/curse.ogg', 40, 1)
		to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))
		to_curse.remove_all_languages()
		to_curse.grant_language(pick(GLOB.all_languages))
		to_curse.update_atom_languages() // double check if this is neccessary
