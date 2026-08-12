/// Indicates this item can be cracked onto a surface to produce a different item
/// For example, cracking an egg producing an egg yolk
/datum/component/grill_crackable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Result atom type of baking this object
	var/atom/crack_result

/datum/component/grill_crackable/Initialize(crack_result)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.crack_result = crack_result

/datum/component/grill_crackable/InheritComponent(datum/component/bakeable/new_comp, original, crack_result)
	if(!original)
		return
	if(crack_result)
		src.crack_result = crack_result

/datum/component/grill_crackable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(on_attempt_crack))

/datum/component/grill_crackable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY))

/datum/component/grill_crackable/proc/on_attempt_crack(obj/item/source, mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(istype(target, /obj/machinery/griddle))
		return interact_with_griddle(source, target, user, modifiers)
	if(istype(target, /obj/item/frying_pan))
		return interact_with_pan(source, target, user, modifiers)

	return NONE

/datum/component/grill_crackable/proc/interact_with_griddle(obj/item/source, obj/machinery/griddle/hit_griddle, mob/living/user, list/modifiers)
	if(length(hit_griddle.griddled_objects) >= hit_griddle.max_items)
		hit_griddle.balloon_alert(user, "no room!")
		return ITEM_INTERACT_BLOCKING
	var/atom/broken_egg = new crack_result(hit_griddle.loc)
	if(LAZYACCESS(modifiers, ICON_X))
		broken_egg.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X/2), ICON_SIZE_X/2)
	if(LAZYACCESS(modifiers, ICON_Y))
		broken_egg.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y/2), ICON_SIZE_Y/2)
	playsound(user, 'sound/items/sheath.ogg', 40, TRUE)
	source.reagents.trans_to(broken_egg, source.reagents.total_volume, copy_only = TRUE)

	hit_griddle.AddToGrill(broken_egg, user)
	hit_griddle.balloon_alert(user, "cracks [source] open")

	qdel(source)
	return ITEM_INTERACT_BLOCKING


/datum/component/grill_crackable/proc/interact_with_pan(obj/item/source, obj/item/frying_pan/hit_pan, mob/living/user, list/modifiers)
	if(length(hit_pan.contents) >= hit_pan.max_items)
		hit_pan.balloon_alert(user, "no room!")
		return ITEM_INTERACT_BLOCKING
	var/atom/broken_egg = new crack_result(hit_pan) // Spawn it directly in its contents. This is on purpose.
	if(LAZYACCESS(modifiers, ICON_X))
		broken_egg.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -hit_pan.max_x_offset, hit_pan.max_x_offset)
	if(LAZYACCESS(modifiers, ICON_Y))
		broken_egg.pixel_y = min(text2num(LAZYACCESS(modifiers, ICON_Y)) + hit_pan.placement_offset, hit_pan.max_height_offset)

	playsound(user, 'sound/items/sheath.ogg', 40, TRUE)
	source.reagents.trans_to(broken_egg, source.reagents.total_volume, copy_only = TRUE)

	hit_pan.AddToPan(broken_egg, user)
	hit_pan.balloon_alert(user, "cracks [source] open")

	qdel(source)
	return ITEM_INTERACT_BLOCKING
