/// When this atom is exposed to fire, that will propagate to its reagents
/datum/element/reagents_exposed_on_fire

/datum/element/reagents_exposed_on_fire/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_FIRE_ACT, PROC_REF(on_fire))
	RegisterSignal(target, COMSIG_ITEM_MICROWAVE_ACT, PROC_REF(on_microwave))

/datum/element/reagents_exposed_on_fire/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(source, COMSIG_ITEM_MICROWAVE_ACT)
	return ..()

/datum/element/reagents_exposed_on_fire/proc/on_fire(atom/source, exposed_temp, exposed_vol)
	SIGNAL_HANDLER

	source.reagents?.expose_temperature(exposed_temp)

/datum/element/reagents_exposed_on_fire/proc/on_microwave(atom/source, obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	SIGNAL_HANDLER

	source.reagents?.expose_temperature(1000)
	return COMPONENT_MICROWAVE_SUCCESS
