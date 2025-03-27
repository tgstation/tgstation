///A simple element for basic mobs that prints out a custom damaged state message
/datum/element/basic_health_examine
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Light amount of damage
	var/light_damage_message
	///Heavy amount of damage
	var/heavy_damage_message
	///Heavy damage threshold percentage
	var/heavy_threshold

/datum/element/basic_health_examine/Attach(datum/target, light_damage_message, heavy_damage_message, heavy_threshold)
	. = ..()
	if(!isbasicmob(target))
		return ELEMENT_INCOMPATIBLE

	src.light_damage_message = light_damage_message
	src.heavy_damage_message = heavy_damage_message
	src.heavy_threshold = heavy_threshold

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/basic_health_examine/Detach(atom/movable/source)
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	return ..()

/datum/element/basic_health_examine/proc/on_examine(mob/living/basic/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(source.health == source.maxHealth)
		return

	if(source.health < source.maxHealth * heavy_threshold)
		examine_list += span_danger(heavy_damage_message)
		return

	examine_list += span_danger(light_damage_message)
