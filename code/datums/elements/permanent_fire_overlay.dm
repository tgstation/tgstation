/// When applied to a mob, they will always have a fire overlay regardless of if they are *actually* on fire.
/datum/element/perma_fire_overlay

/datum/element/perma_fire_overlay/Attach(atom/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_fire_overlay))
	target.update_appearance(UPDATE_OVERLAYS)

/datum/element/perma_fire_overlay/Detach(atom/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS)
	target.update_appearance(UPDATE_OVERLAYS)

/datum/element/perma_fire_overlay/proc/add_fire_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/created_overlay = source.get_fire_overlay(stacks = MAX_FIRE_STACKS, on_fire = TRUE)
	if(isnull(created_overlay))
		return

	overlays |= created_overlay
