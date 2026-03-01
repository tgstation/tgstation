/// Tucking element, for things that can be tucked into bed.
/datum/element/bed_tuckable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	/// our pixel_x offset - how much the item moves x when in bed (+x is closer to the pillow)
	var/x_offset = 0
	/// our pixel_y offset - how much the item move y when in bed (-y is closer to the middle)
	var/y_offset = 0
	/// our rotation degree - how many degrees we need to turn the item to get to the left/right side
	var/rotation_degree = 0
	/// our starting angle for the item
	var/starting_angle = 0

/datum/element/bed_tuckable/Attach(obj/target, mapload = FALSE, x = 0, y = 0, rotation = 0)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	x_offset = x
	y_offset = y
	starting_angle = rotation
	RegisterSignal(target, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(tuck_into_bed))
	if(!mapload)
		return
	var/turf/our_home = get_turf(target)
	var/obj/structure/bed/eepy = locate(/obj/structure/bed) in our_home
	if(isnull(eepy))
		return
	tuck(target, eepy)

/datum/element/bed_tuckable/Detach(obj/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_ATOM, COMSIG_ITEM_PICKUP))

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

	if(!tucker.transfer_item_to_turf(tucked, target_bed.drop_location()))
		return

	to_chat(tucker, span_notice("You lay [tucked] out on [target_bed]."))
	tuck(tucked, target_bed)
	return COMPONENT_NO_AFTERATTACK

/datum/element/bed_tuckable/proc/tuck(obj/item/tucked, obj/structure/bed/target_bed)
	tucked.dir = target_bed.dir & target_bed.left_headrest_dirs ? EAST : WEST
	tucked.pixel_x = target_bed.dir & target_bed.left_headrest_dirs ? -x_offset : x_offset
	tucked.pixel_y = y_offset
	if(starting_angle)
		rotation_degree = target_bed.dir & target_bed.left_headrest_dirs ? starting_angle + 180 : starting_angle
		tucked.transform = turn(tucked.transform, rotation_degree)
		RegisterSignal(tucked, COMSIG_ITEM_PICKUP, PROC_REF(untuck))

/**
 * If we rotate our object, then we need to un-rotate it when it's picked up
 *
 * tucked - the object that is tucked
 */
/datum/element/bed_tuckable/proc/untuck(obj/item/tucked)
	SIGNAL_HANDLER

	tucked.transform = turn(tucked.transform, -rotation_degree)
	UnregisterSignal(tucked, COMSIG_ITEM_PICKUP)
