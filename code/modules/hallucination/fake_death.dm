/datum/hallucination/death
	random_hallucination_weight = 1

/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		// Really make sure these go away, would be bad if they stuck around
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	return ..()

/datum/hallucination/death/start()
	hallucinator.Paralyze(30 SECONDS)
	hallucinator.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
	ADD_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
	ADD_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> has died at <b>[get_area_name(hallucinator)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/who_is_salting
		if(length(GLOB.dead_player_list))
			who_is_salting = pick(GLOB.dead_mob_list)

		if(who_is_salting)
			delay = rand(2 SECONDS, 5 SECONDS)

			var/static/list/things_to_hate = list(
				"admins",
				"batons",
				"blood cult",
				"coders",
				"heretics",
				"myself",
				"revenants",
				"revs",
				"sec",
				"ss13",
				"this game",
				"this round",
				"this shift",
				"this shit",
				"this",
				"wizards",
				"you",
			)

			var/list/dead_chat_salt = list(
				"...",
				"FUCK",
				"git gud",
				"god damn it",
				"hey [hallucinator.first_name()]",
				"i[prob(50) ? " fucking" : ""] hate [pick(things_to_hate)]",
				"is the AI rogue?",
				"rip",
				"shitsec",
				"why did i just drop dead?",
				"why was i gibbed",
				"wizard?",
				"you too?",
			)

			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, hallucinator, span_deadsay("<b>DEAD: [who_is_salting.name]</b> says, \"[pick(dead_chat_salt)]\"")), delay)

	addtimer(CALLBACK(src, .proc/wake_up), delay + rand(7 SECONDS, 9 SECONDS))
	return TRUE

/datum/hallucination/death/proc/wake_up()
	if(!QDELETED(hallucinator))
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
		hallucinator.SetParalyzed(0 SECONDS)
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	if(!QDELETED(src))
		qdel(src)
