/// An element to add a FOV trait to the wearer, removing it when an item is unequipped, but only as long as the visor is up.
/datum/component/clothing_fov_visor
	/// What's the FOV angle of the trait we're applying to the wearer
	var/fov_angle
	/// Keeping track of the visor of our clothing.
	var/visor_up = FALSE
	/// Because of clothing code not being too good, we need keep track whether we are worn.
	var/is_worn = FALSE
	/// The current wearer
	var/mob/living/wearer

/datum/component/clothing_fov_visor/Initialize(fov_angle)
	. = ..()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/clothing/clothing_parent = parent
	src.fov_angle = fov_angle
	src.visor_up = clothing_parent.up //Initial values could vary, so we need to get it.

/datum/component/clothing_fov_visor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_CLOTHING_VISOR_TOGGLE, PROC_REF(on_visor_toggle))

/datum/component/clothing_fov_visor/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_CLOTHING_VISOR_TOGGLE))
	if(wearer)
		wearer.remove_fov_trait(src, fov_angle)
		UnregisterSignal(wearer, COMSIG_PARENT_QDELETING)
		wearer = null
	return ..()

/// On dropping the item, remove the FoV trait if visor was down.
/datum/component/clothing_fov_visor/proc/on_drop(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	is_worn = FALSE
	if(wearer) // Prevent any edge cases where on_drop is called with a different dropper to the one who equipped the visor.
		UnregisterSignal(wearer, COMSIG_PARENT_QDELETING)
		wearer.remove_fov_trait(src, fov_angle)
		wearer = null
	if(visor_up)
		return
	dropper.remove_fov_trait(src, fov_angle)
	dropper.update_fov()

/// On equipping the item, add the FoV trait if visor isn't up.
/datum/component/clothing_fov_visor/proc/on_equip(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot)) //If EQUIPPED TO HANDS FOR EXAMPLE
		return
	is_worn = TRUE
	if(wearer && wearer != equipper)
		UnregisterSignal(wearer, COMSIG_PARENT_QDELETING)
		wearer.remove_fov_trait(src, fov_angle)
	wearer = equipper
	RegisterSignal(wearer, COMSIG_PARENT_QDELETING, PROC_REF(on_wearer_deleted))
	if(visor_up)
		return
	equipper.add_fov_trait(src, fov_angle)
	equipper.update_fov()

/datum/component/clothing_fov_visor/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	wearer.remove_fov_trait(src, fov_angle)
	wearer = null

/// On toggling the visor, we may want to add or remove FOV trait from the wearer.
/datum/component/clothing_fov_visor/proc/on_visor_toggle(datum/source, visor_state)
	SIGNAL_HANDLER
	visor_up = visor_state
	if(!is_worn)
		return
	var/obj/item/clothing/clothing_parent = parent
	var/mob/living/current_wearer = clothing_parent.loc //This has to be the case due to equip/dropped keeping track.
	if(visor_up)
		current_wearer.remove_fov_trait(src, fov_angle)
		current_wearer.update_fov()
	else
		current_wearer.add_fov_trait(src, fov_angle)
		current_wearer.update_fov()
