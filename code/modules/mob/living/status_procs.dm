//Here are the procs used to modify status effects of a mob.
//The effects include: paralysis, knockdown, unconscious, sleeping, resting, jitteriness, dizziness,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.


//////////////////////////////PARALYSE ////////////////////////////////////

/mob/living/proc/add_paralyse_absorption(key, duration, priority, message, self_message, examine_message)
//adds a paralyse absorption with a key, a duration in deciseconds, its priority, and the messages it makes when you're paralysis/examined, if any
	if(!islist(paralyse_absorption))
		paralyse_absorption = list()
	if(paralyse_absorption[key])
		paralyse_absorption[key]["end_time"] = world.time + duration
		paralyse_absorption[key]["priority"] = priority
		paralyse_absorption[key]["paralyses_absorbed"] = 0
	else
		paralyse_absorption[key] = list("end_time" = world.time + duration, "priority" = priority, "paralyses_absorbed" = 0, \
		"visible_message" = message, "self_message" = self_message, "examine_message" = examine_message)

/mob/living/Paralyse(amount, updating = 1, ignore_canparalyse = 0)
	if(!stat && islist(paralyse_absorption) && (status_flags & CANPARALYSE || ignore_canparalyse))
		if(absorb_paralyse(amount))
			return 0
	return ..()

///////////////////////////////// KNOCKDOWN /////////////////////////////////////

/mob/living/Knockdown(amount, updating = TRUE, ignore_canknockdown = FALSE)
	if(!stat && islist(paralyse_absorption) && (status_flags & CANKNOCKDOWN || ignore_canknockdown))
		if(absorb_paralyse(amount))
			return 0
	return ..()

/mob/living/proc/absorb_paralyse(amount)
	var/priority_absorb_key
	var/highest_priority
	for(var/i in paralyse_absorption)
		if(paralyse_absorption[i]["end_time"] > world.time && (!priority_absorb_key || paralyse_absorption[i]["priority"] > highest_priority))
			priority_absorb_key = paralyse_absorption[i]
			highest_priority = priority_absorb_key["priority"]
	if(priority_absorb_key)
		if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
			if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
				visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>", "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
			else if(priority_absorb_key["visible_message"])
				visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>")
			else if(priority_absorb_key["self_message"])
				to_chat(src, "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
		priority_absorb_key["paralyses_absorbed"] += amount
		return TRUE
