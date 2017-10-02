/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/hl3_release_date //the half-life measured in ticks
	var/strength
	var/can_contaminate

/datum/component/radioactive/Initialize(_strength=0, _half_life=RAD_HALF_LIFE, _can_glow=TRUE, _can_contaminate=TRUE)
	. = ..()
	strength = _strength
	hl3_release_date = _half_life
	can_contaminate = _can_contaminate

	if(istype(parent, /atom)) 
		RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/rad_examine)
		if(istype(parent, /obj/item))
			RegisterSignal(COMSIG_ITEM_ATTACK, .proc/rad_attack)
			RegisterSignal(COMSIG_ITEM_ATTACK_OBJ, .proc/rad_attack)
	else
		warning("Something that wasn't an atom was given /datum/component/radioactive")
		qdel(src)
		return

	START_PROCESSING(SSradiation, src)

/datum/component/radioactive/Destroy()
	STOP_PROCESSING(SSradiation, src)
	return ..()

/datum/component/radioactive/process()
	if(QDELETED(parent))
		return
	if(prob(1))
		radiation_pulse(get_turf(parent),strength,1,FALSE,can_contaminate)

	if(hl3_release_date && prob(50))
		strength -= strength / hl3_release_date
		if(strength <= 1)
			qdel(src)

/datum/component/radioactive/InheritComponent(datum/component/C, i_am_original)
	if(!i_am_original)
		return ..()
	if(!hl3_release_date) // Permanently radioactive things don't get to grow stronger
		return ..()
	var/datum/component/radioactive/other = C
	strength = max(strength, other.strength)
	return ..()

/datum/component/radioactive/proc/rad_examine(mob/user, atom/thing)
	var/out = ""
	if(get_dist(parent, user) <= 1)
		out += "The air around [parent] feels warm"
	switch(strength)
		if(50 to 200)
			out += "[out ? " and it " : "[parent] "]feels weird to look at."
		if(201 to 500)
			out += "[out ? " and it " : "[parent] "]seems to be glowing a bit."
		if(501 to INFINITY) //At this level the object can contaminate other objects
			out += "[out ? " and it " : "[parent] "]hurts to look at."
		else
			out += "."
	to_chat(user, out)

/datum/component/radioactive/proc/rad_attack(atom/movable/target, mob/living/user)
	radiation_pulse(get_turf(target), strength/20)
	target.rad_act(strength/2)