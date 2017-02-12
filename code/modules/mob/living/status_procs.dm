//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////

//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(damage, deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(damage, deaf)
	if(damage >= 0)
		ear_damage = damage
	if(deaf >= 0)
		ear_deaf = deaf


//////////////////////////////STUN ////////////////////////////////////

/mob/living/proc/add_stun_absorption(key, duration, priority, message, self_message, examine_message)
//adds a stun absorption with a key, a duration in deciseconds, its priority, and the messages it makes when you're stunned/examined, if any
	if(!islist(stun_absorption))
		stun_absorption = list()
	if(stun_absorption[key])
		stun_absorption[key]["end_time"] = world.time + duration
		stun_absorption[key]["priority"] = priority
		stun_absorption[key]["stuns_absorbed"] = 0
	else
		stun_absorption[key] = list("end_time" = world.time + duration, "priority" = priority, "stuns_absorbed" = 0, \
		"visible_message" = message, "self_message" = self_message, "examine_message" = examine_message)

/mob/living/Stun(amount, updating = 1, ignore_canstun = 0)
	if(!stat && islist(stun_absorption))
		var/priority_absorb_key
		var/highest_priority
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && (!priority_absorb_key || stun_absorption[i]["priority"] > highest_priority))
				priority_absorb_key = stun_absorption[i]
				highest_priority = stun_absorption[i]["priority"]
		if(priority_absorb_key)
			if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
				if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>", "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
				else if(priority_absorb_key["visible_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>")
				else if(priority_absorb_key["self_message"])
					src << "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>"
			priority_absorb_key["stuns_absorbed"] += amount
			return 0
	..()

///////////////////////////////// WEAKEN /////////////////////////////////////

/mob/living/Weaken(amount, updating = 1, ignore_canweaken = 0)
	if(!stat && islist(stun_absorption))
		var/priority_absorb_key
		var/highest_priority
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && (!priority_absorb_key || stun_absorption[i]["priority"] > highest_priority))
				priority_absorb_key = stun_absorption[i]
				highest_priority = priority_absorb_key["priority"]
		if(priority_absorb_key)
			if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
				if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>", "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
				else if(priority_absorb_key["visible_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>")
				else if(priority_absorb_key["self_message"])
					src << "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>"
			priority_absorb_key["stuns_absorbed"] += amount
			return 0
	..()