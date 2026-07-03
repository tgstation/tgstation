/datum/round_event_control/processor_overload
	name = "Processor Overload"
	typepath = /datum/round_event/processor_overload
	weight = 15
	min_players = 20
	category = EVENT_CATEGORY_ENGINEERING
	description = "Emps the telecomm processors, scrambling radio speech. Might blow up a few."

/datum/round_event/processor_overload
	announce_when = 1

/datum/round_event/processor_overload/announce(fake)
	var/alert = pick("Приближается экзосферный пузырь. Возможна перегрузка процессора. Пожалуйста, свяжитесь с ваши*%xp25)`6cq-BZZT",
		"Приближается экзосферный пузырь. Возможна перегрузка процl*1eta;c5;'1v¬-BZZZT",
		"Приближается экзосферный пузырь. Возможна пер#MCi46:5.;@63-BZZZZT",
		"Приближается экзосферн'Fz\\k55_@-BZZZZZT",
		"Приближается экз:%£ QCbyj^j</.3-BZZZZZZT",
		"!!hy%;f3l7e,<$^-BZZZZZZZT",
	)

	//AIs are always aware of processor overload
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		to_chat(ai, "<br>[span_warning("<b>[alert]</b>")]<br>")

	// Announce most of the time, but leave a little gap so people don't know
	// whether it's, say, a tesla zapping tcomms, or some selective
	// modification of the tcomms bus
	if(prob(80) || fake)
		priority_announce(alert, "Обнаружена аномалия")

/datum/round_event/processor_overload/start()
	for(var/obj/machinery/telecomms/processor/spinny_thing in GLOB.telecomm_machines)
		if(!prob(10))
			spinny_thing.emp_act(EMP_HEAVY)
			continue
		announce_to_ghosts(spinny_thing)
		// Damage the surrounding area to indicate that it popped
		explosion(spinny_thing, light_impact_range = 2, explosion_cause = src)
		// Only a level 1 explosion actually damages the machine
		// at all
		SSexplosions.high_mov_atom += spinny_thing
