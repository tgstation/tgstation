/**
 * Makes anything that is attaches to incapable of producing light
 */
/datum/element/light_eaten
	element_flags = ELEMENT_DETACH

/datum/element/light_eaten/Attach(atom/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	target.set_light(0, 0, null, FALSE)
	RegisterSignal(target, COMSIG_ATOM_UPDATE_LIGHT, .proc/block_light_update)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/element/light_eaten/Detach(datum/source, force)
	UnregisterSignal(source, list(COMSIG_ATOM_UPDATE_LIGHT, COMSIG_PARENT_EXAMINE))
	return ..()

/// Prevents the atom from ever having positive light
/datum/element/light_eaten/proc/block_light_update(atom/eaten_light)
	SIGNAL_HANDLER
	if(eaten_light.light_power <= 0)
		return NONE

	eaten_light.light_power = 0
	if(eaten_light.light_range > 0)
		eaten_light.light_range = 0
	if(eaten_light.light_on)
		eaten_light.light_on = FALSE
	return NONE

/// Signal handler for light eater flavortext
/datum/element/light_eaten/proc/on_examine(atom/eaten_light, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='warning'>It's dark and empty...</span>"
	if(isliving(examiner) && prob(20))
		var/mob/living/target = examiner
		examine_text += "<span class='danger'>You can feel something in [eaten_light.p_them()] gnash at your eyes!</span>"
		target.blind_eyes(5)
		target.blur_eyes(10)
	return NONE
