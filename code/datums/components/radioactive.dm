/datum/component/radioactive
	var/hl3_release_date //the half-life measured in ticks
	var/strength
	var/can_glow

/datum/component/radioactive/Initialize(_strength=0, _half_life=RAD_HALF_LIFE)
	strength = _strength
	hl3_release_date = _half_life

	if(istype(parent, /atom))
		RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/rad_examine)
		if(istype(parent, /obj/item))
			RegisterSignal(COMSIG_ITEM_ATTACK, .proc/rad_attack)
			RegisterSignal(COMSIG_ITEM_ATTACK_OBJ, .proc/rad_attack)

	START_PROCESSING(SSradiation, src)

/datum/component/radioactive/process()
	if(prob(50))
		radiation_pulse(get_turf(parent),strength)

		if(hl3_release_date)
			var/reduction = strength / hl3_release_date
			strength -= reduction
			if(strength <= 0.1)
				STOP_PROCESSING(SSradiation, src)
				qdel(src)

/datum/component/radioactive/proc/rad_examine(mob/user, atom/thing)
	var/out
	if(get_dist(parent, user) <= 1)
		out = "The air around [parent] feels warm"
	switch(strength)
		if(5 to 20)
			out += " and it feels weird to look at."
		if(21 to 40)
			out += " and it seems to be glowing a bit."
		if(41 to INFINITY)
			out += " and it hurts to look at."
		else
			out += "."
	to_chat(user, out)

/datum/component/radioactive/proc/rad_attack(atom/movable/target, mob/living/user)
	radiation_pulse(get_turf(target), strength/20)
	//rad_act or send signal to target

/proc/radiation_pulse(turf/epicenter, intensity, range_modifier, log=0)
	for(var/dir in GLOB.cardinals)
		new /datum/radiation_wave(epicenter, dir, intensity, range_modifier)

	var/list/things = epicenter.GetAllContents() //copypasta because I don't want to put special code in waves to handle their origin
	for(var/k in 1 to things.len)
		var/atom/thing = things[k]
		if(!thing)
			continue
		thing.rad_act(intensity)

	if(log)
		log_game("Radiation pulse with intensity:[intensity] and range modifier:[range_modifier] in area [epicenter.loc.name] ")
	return TRUE