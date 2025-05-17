/// This atom can be touched by a hot item to warm up its reagents
/datum/element/reagents_item_heatable

/datum/element/reagents_item_heatable/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interact))

/datum/element/reagents_item_heatable/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_ITEM_INTERACTION)
	return ..()

/datum/element/reagents_item_heatable/proc/on_item_interact(atom/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if(isnull(source.reagents) || source.reagents.total_volume <= 0)
		return NONE

	var/hotness = tool.get_temperature()
	if(hotness)
		source.reagents.expose_temperature(hotness)
		source.balloon_alert(user, "heated [source]")
		return ITEM_INTERACT_SUCCESS

	//Cooling method
	if(istype(tool, /obj/item/extinguisher))
		var/obj/item/extinguisher/extinguisher = tool
		if(extinguisher.safety)
			return NONE
		if (extinguisher.reagents?.total_volume < 1)
			extinguisher.balloon_alert(user, "extinguisher is empty!") // being a bit more verbose to clarify the extinguisher - not source - is empty
			return ITEM_INTERACT_BLOCKING
		var/cooling = (0 - source.reagents.chem_temp) * extinguisher.cooling_power * 2
		source.reagents.expose_temperature(cooling)
		source.balloon_alert(user, "cooled [source]")
		playsound(source, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
		extinguisher.reagents.remove_all(1)
		return ITEM_INTERACT_SUCCESS

	return NONE
