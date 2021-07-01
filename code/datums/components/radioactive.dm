#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/source
	var/hl3_release_date //the half-life measured in ticks
	var/strength
	var/can_contaminate

/datum/component/radioactive/Initialize(_strength=0, _source, _half_life=RAD_HALF_LIFE, _can_contaminate=TRUE)
	strength = _strength
	source = _source
	hl3_release_date = _half_life
	can_contaminate = _can_contaminate
	if(istype(parent, /atom))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/rad_examine)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/rad_clean)
		if(istype(parent, /obj/item))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/rad_attack)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, .proc/rad_attack)
	else
		return COMPONENT_INCOMPATIBLE
	if(strength > RAD_MINIMUM_CONTAMINATION)
		SSradiation.warn(src)
	//Let's make er glow
	//This relies on parent not being a turf or something. IF YOU CHANGE THAT, CHANGE THIS
	var/atom/movable/master = parent
	master.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, .proc/glow_loop, master), rand(1,19))//Things should look uneven
	START_PROCESSING(SSradiation, src)

/datum/component/radioactive/Destroy()
	STOP_PROCESSING(SSradiation, src)
	var/atom/movable/master = parent
	master.remove_filter("rad_glow")
	return ..()

/datum/component/radioactive/process(delta_time)
	if(!DT_PROB(50, delta_time))
		return
	radiation_pulse(parent, strength, RAD_DISTANCE_COEFFICIENT*2, FALSE, can_contaminate)
	if(!hl3_release_date)
		return
	strength -= strength / hl3_release_date
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(src)
		return PROCESS_KILL

/datum/component/radioactive/proc/glow_loop(atom/movable/master)
	var/filter = master.get_filter("rad_glow")
	if(filter)
		animate(filter, alpha = 110, time = 15, loop = -1)
		animate(alpha = 40, time = 25)

/datum/component/radioactive/InheritComponent(datum/component/C, i_am_original, _strength, _source, _half_life, _can_contaminate)
	if(!i_am_original)
		return
	if(!hl3_release_date) // Permanently radioactive things don't get to grow stronger
		return
	if(C)
		var/datum/component/radioactive/other = C
		strength = max(strength, other.strength)
	else
		strength = max(strength, _strength)

/datum/component/radioactive/proc/rad_examine(datum/source, mob/user, list/out)
	SIGNAL_HANDLER

	var/atom/master = parent

	var/list/fragments = list()
	if(get_dist(master, user) <= 1)
		fragments += "The air around [master] feels warm"
	switch(strength)
		if(0 to RAD_AMOUNT_LOW)
			if(length(fragments))
				fragments += "."
		if(RAD_AMOUNT_LOW to RAD_AMOUNT_MEDIUM)
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]feel[master.p_s()] weird to look at."
		if(RAD_AMOUNT_MEDIUM to RAD_AMOUNT_HIGH)
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]seem[master.p_s()] to be glowing a bit."
		if(RAD_AMOUNT_HIGH to INFINITY) //At this level the object can contaminate other objects
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]hurt[master.p_s()] to look at."

	if(length(fragments))
		out += "<span class='warning'>[fragments.Join()]</span>"

/datum/component/radioactive/proc/rad_attack(datum/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER

	radiation_pulse(parent, strength/20)
	target.rad_act(strength/2)
	if(!hl3_release_date)
		return
	strength -= strength / hl3_release_date

/datum/component/radioactive/proc/rad_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return COMPONENT_CLEANED

	if(!(clean_types & CLEAN_TYPE_RADIATION))
		return COMPONENT_CLEANED

	if(!(clean_types & CLEAN_TYPE_WEAK))
		qdel(src)
		return COMPONENT_CLEANED

	strength = max(0, (strength - (RAD_BACKGROUND_RADIATION * 2)))
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(src)
		return COMPONENT_CLEANED

#undef RAD_AMOUNT_LOW
#undef RAD_AMOUNT_MEDIUM
#undef RAD_AMOUNT_HIGH
#undef RAD_AMOUNT_EXTREME
