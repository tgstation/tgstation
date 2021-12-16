/// An element to unconditonally add a FOV trait to the wearer, removing it when an item is unequipped
/datum/element/item_fov
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	/// Angle of the FoV we will apply when someone wears the clothing this element is attached to.
	var/fov_angle

/datum/element/item_fov/Attach(datum/target, fov_angle)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.fov_angle = fov_angle

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/element/item_fov/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	return ..()

/// On dropping the item, remove the FoV trait.
/datum/element/item_fov/proc/on_drop(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	dropper.remove_fov_trait(source.type, fov_angle)
	dropper.update_fov()

/// On equipping the item, add the FoV trait.
/datum/element/item_fov/proc/on_equip(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot)) //If EQUIPPED TO HANDS FOR EXAMPLE
		return

	equipper.add_fov_trait(source.type, fov_angle)
	equipper.update_fov()
