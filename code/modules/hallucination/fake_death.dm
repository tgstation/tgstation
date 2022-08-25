/datum/hallucination/death
	random_hallucination_weight = 1

/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, type)

	return ..()

/datum/hallucination/death/start()
	hallucinator.Paralyze(30 SECONDS)
	hallucinator.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, type)

	if(iscarbon(hallucinator))
		var/mob/living/carbon/carbon_hallucinator = hallucinator
		carbon_hallucinator.silent += 10

	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> has died at <b>[get_area_name(hallucinator)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/who_is_salting
		if(length(GLOB.dead_player_list))
			who_is_salting = pick(GLOB.dead_mob_list)

		if(who_is_salting)
			delay = rand(2 SECONDS, 5 SECONDS)

			var/static/list/things_to_hate = list(
				"blood cult",
				"heretics",
				"revs",
				"batons",
				"revenants",
				"this round",
				"this",
				"sec",
				"myself",
				"admins",
				"ss13",
				"you",
			)

			var/list/dead_chat_salt = list(
				"rip",
				"why did i just drop dead?",
				"shitsec",
				"hey [hallucinator.first_name()]",
				"git gud",
				"you too?",
				"is the AI rogue?",
				"i[prob(50)?" fucking":""] hate [pick(things_to_hate)]",
			)

			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, hallucinator, span_deadsay("<b>DEAD: [who_is_salting.name]</b> says, \"[pick(dead_chat_salt)]\"")), delay)

	addtimer(CALLBACK(src, .proc/wake_up), delay + rand(7 SECONDS, 9 SECONDS))
	return TRUE

/datum/hallucination/death/proc/wake_up()
	if(!QDELETED(hallucinator))
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, type)

		if(iscarbon(hallucinator))
			var/mob/living/carbon/carbon_hallucinator = hallucinator
			carbon_hallucinator.silent = 0

		hallucinator.SetParalyzed(0 SECONDS)

	if(!QDELETED(src))
		qdel(src)
