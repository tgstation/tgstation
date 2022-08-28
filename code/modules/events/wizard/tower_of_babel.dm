GLOBAL_VAR_INIT(tower_of_babel_triggered, FALSE)

/datum/round_event_control/wizard/tower_of_babel
	name = "Tower of Babel"
	weight = 3
	typepath = /datum/round_event/wizard/tower_of_babel
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Everyone forgets their current languages and gains a randomized one"

/datum/round_event/wizard/tower_of_babel/start()
	GLOB.tower_of_babel_triggered = TRUE // So latejoiners are also afflicted.

	deadchat_broadcast("The [span_name("Tower of Babel")] has stricken the station, people will struggle to communicate.", message_type=DEADCHAT_ANNOUNCEMENT)

	for(var/mob/living/carbon/to_curse in GLOB.player_list)
		if(IS_WIZARD(to_curse)) // wizards are not only immune but they also can now speak to anyone
			to_curse.grant_all_languages()
			to_curse.update_atom_languages() // double check if this is neccessary
			continue

		if(to_curse.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(to_curse)
		if(curse_turf && !is_station_level(curse_turf.z))
			continue
		if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			to_chat(to_curse, span_notice("You have a strange feeling for a moment, but then it passes."))
			continue

		to_curse.playsound_local(get_turf(to_curse), 'sound/magic/curse.ogg', 40, 1)
		to_chat(to_curse, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))
		to_curse.remove_all_languages()
		to_curse.grant_language(pick(GLOB.all_languages))
		to_curse.update_atom_languages() // double check if this is neccessary
