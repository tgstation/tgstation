/**
 * Makes anything that it attaches to incapable of producing light
 */
/datum/element/light_eaten
	element_flags = ELEMENT_DETACH

/datum/element/light_eaten/Attach(atom/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	var/atom/atom_target = target
	RegisterSignal(atom_target, COMSIG_ATOM_SET_LIGHT_POWER, .proc/block_light_power)
	RegisterSignal(atom_target, COMSIG_ATOM_SET_LIGHT_RANGE, .proc/block_light_range)
	RegisterSignal(atom_target, COMSIG_ATOM_SET_LIGHT_ON, .proc/block_light_on)
	RegisterSignal(atom_target, COMSIG_PARENT_EXAMINE, .proc/on_examine)

	/// Because the lighting system does not like movable lights getting set_light() called.
	switch(atom_target.light_system)
		if(STATIC_LIGHT)
			target.set_light(0, 0, null, FALSE)
		else
			target.set_light_power(0)
			target.set_light_range(0)
			target.set_light_on(FALSE)

/datum/element/light_eaten/Detach(datum/source)
	UnregisterSignal(source, list(
		COMSIG_ATOM_SET_LIGHT_POWER,
		COMSIG_ATOM_SET_LIGHT_RANGE,
		COMSIG_ATOM_SET_LIGHT_ON,
		COMSIG_PARENT_EXAMINE,
	))
	return ..()

/// Prevents the light power of the target atom from exceeding 0 or increasing.
/datum/element/light_eaten/proc/block_light_power(atom/eaten_light, new_power)
	SIGNAL_HANDLER
	if(new_power > 0)
		return COMPONENT_BLOCK_LIGHT_UPDATE
	if(new_power > eaten_light.light_power)
		return COMPONENT_BLOCK_LIGHT_UPDATE
	return NONE

/// Prevents the light range of the target atom from exceeding 0 while the light power is greater than 0.
/datum/element/light_eaten/proc/block_light_range(atom/eaten_light, new_range)
	SIGNAL_HANDLER
	if(new_range <= 0)
		return NONE
	if(eaten_light.light_power <= 0)
		return NONE
	return COMPONENT_BLOCK_LIGHT_UPDATE

/// Prevents the light from turning on while the light power is greater than 0.
/datum/element/light_eaten/proc/block_light_on(atom/eaten_light, new_on)
	SIGNAL_HANDLER
	if(!new_on)
		return NONE
	if(eaten_light.light_power <= 0)
		return NONE
	return COMPONENT_BLOCK_LIGHT_UPDATE

/// Signal handler for light eater flavortext
/datum/element/light_eaten/proc/on_examine(atom/eaten_light, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_warning("It's dark and empty...")
	if(isliving(examiner) && prob(20))
		var/mob/living/target = examiner
		examine_text += span_danger("You can feel something in [eaten_light.p_them()] gnash at your eyes!")
		target.blind_eyes(5)
		target.blur_eyes(10)
	return NONE
