/// Tucking element, for things that can be tucked into bed.
/datum/element/bed_tuckable
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	/// our pixel_x offset - how much the item moves x when in bed (+x is closer to the pillow)
	var/x_offset = 0
	/// our pixel_y offset - how much the item move y when in bed (-y is closer to the middle)
	var/y_offset = 0
	/// our rotation degree - how much the item turns when in bed (+degrees turns it more parallel)
	var/rotation_degree = 0

/datum/element/bed_tuckable/Attach(obj/target, x = 0, y = 0, rotation = 0)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	x_offset = x
	y_offset = y
	rotation_degree = rotation
	RegisterSignal(target, COMSIG_ITEM_ATTACK_OBJ, .proc/tuck_into_bed)

/datum/element/bed_tuckable/Detach(obj/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_PICKUP))

/**
 * Tuck our object into bed.
 *
 * tucked - the object being tucked
 * target_bed - the bed we're tucking them into
 * tucker - the guy doing the tucking
 */
/datum/element/bed_tuckable/proc/tuck_into_bed(obj/item/tucked, obj/structure/bed/target_bed, mob/living/tucker)
	SIGNAL_HANDLER

	if(!istype(target_bed))
		return

	if(!tucker.transferItemToLoc(tucked, target_bed.drop_location()))
		return

	to_chat(tucker, "<span class='notice'>You lay [tucked] out on [target_bed].</span>")
	tucked.pixel_x = x_offset
	tucked.pixel_y = y_offset
	if(rotation_degree)
		tucked.transform = turn(tucked.transform, rotation_degree)
		RegisterSignal(tucked, COMSIG_ITEM_PICKUP, .proc/untuck)

	return COMPONENT_NO_AFTERATTACK

/**
 * If we rotate our object, then we need to un-rotate it when it's picked up
 *
 * tucked - the object that is tucked
 */
/datum/element/bed_tuckable/proc/untuck(obj/item/tucked)
	SIGNAL_HANDLER

	tucked.transform = turn(tucked.transform, -rotation_degree)
	UnregisterSignal(tucked, COMSIG_ITEM_PICKUP)
