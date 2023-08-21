///list of events eminence can trigger as well as their cost in cogs, most likely gonna have to set limits on these, might do it based on cost, unsure if I should use a .txt for this
#define EMINENCE_EVENTS list(/datum/round_event_control/brand_intelligence = 5, /datum/round_event_control/bureaucratic_error = 3, /datum/round_event_control/gravity_generator_blackout = 3, \
							 /datum/round_event_control/communications_blackout = 5, /datum/round_event_control/electrical_storm = 2, /datum/round_event_control/ion_storm = 5, \
							 /datum/round_event_control/grey_tide = 3, /datum/round_event_control/grid_check = 5, /datum/round_event_control/scrubber_overflow/catastrophic = 4, \
							 /datum/round_event_control/radiation_storm = 7, /datum/round_event_control/scrubber_clog/critical = 3, /datum/round_event_control/carp_migration = 6, \
							 /datum/round_event_control/wormholes = 5, /datum/round_event_control/immovable_rod = 8, /datum/round_event_control/anomaly/anomaly_dimensional = 2, \
							 /datum/round_event_control/anomaly/anomaly_bluespace = 4, /datum/round_event_control/anomaly/anomaly_ectoplasm = 4, \
							 /datum/round_event_control/anomaly/anomaly_flux = 3, /datum/round_event_control/anomaly/anomaly_pyro = 5)

/datum/action/innate/clockcult/space_fold
	name = "Space Fold"
	button_icon_state = "Geis"
	desc = "Fold local space so that certain \"events\" befall the station. The amount you may create depends on how many APCs the cult has cogged. \
			Doing so will also cost charges which will regenerate at a rate of one per minute."
	///list used for tracking what events have been trigged so far, also used for restricting how many times an event can trigger
	var/list/used_event_list = list()
	///instead of a cooldown this has a charge system, one charge regenerates every mintue, each event costs charges equal to its cog cost
	var/charges = 10
	///cooldown declare for charge cooldown
	COOLDOWN_DECLARE(charge_cooldown)

/datum/action/innate/clockcult/space_fold/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, charge_cooldown, 1 SECONDS)

/datum/action/innate/clockcult/space_fold/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/action/innate/clockcult/space_fold/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, charge_cooldown))
		charges++
		COOLDOWN_START(src, charge_cooldown, 1 MINUTES)

	if(charges >= initial(charges))
		STOP_PROCESSING(SSfastprocess, src)
		return

/datum/action/innate/clockcult/space_fold/Activate()
	var/static/list/event_list
	if(!event_list) //build event_list if we dont already have one
		event_list = list()
		for(var/datum/round_event_control/entry as anything in SSevents.control)
			if(entry.type in EMINENCE_EVENTS)
				event_list[entry] = EMINENCE_EVENTS[entry.type]

	var/datum/round_event_control/chosen_event = tgui_input_list(usr, "Choose an event", "[charges] [charges == 1 ? "charge" : "charges"] remaining", event_list)
	if(isnull(chosen_event))
		return
	if(isnull(event_list[chosen_event]))
		return

	if(used_event_list[chosen_event])
		if(event_list[chosen_event] >= 4 && used_event_list[chosen_event] >= 2) //events with 4+ cost can be used 2 times, 3 and below can be used 4 times
			to_chat(usr, span_warning("You have summoned this event too many times to do so again!"))
			return
		else if(used_event_list[chosen_event] >= 4)
			to_chat(usr, span_warning("You have summoned this event too many times to do so again!"))
			return

	switch(tgui_alert(usr, "Are you sure you want to summon this event? It will cost [event_list[chosen_event]] cogs.", "Confirm summon", list("Yes", "No")))
		if("No")
			return
		if("Yes")
			if(istype(usr, /mob/living/eminence)) //if you somehow get this as non-eminence its technically free besides charges
				var/mob/living/eminence/em_user = usr
				if(em_user.cogs < event_list[chosen_event])
					to_chat(em_user, span_warning("You dont have enough cogs to do this!"))
					return
				em_user.cogs -= event_list[chosen_event]
			chosen_event.runEvent()
			charges -= event_list[chosen_event]
			if(charges + event_list[chosen_event] >= initial(charges)) //if charges was full then start processing
				START_PROCESSING(SSfastprocess, src)
				COOLDOWN_START(src, charge_cooldown, 1 MINUTES)
			used_event_list[chosen_event] = used_event_list[chosen_event] + 1

#undef EMINENCE_EVENTS
