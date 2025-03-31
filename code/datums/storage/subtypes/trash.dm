/datum/storage/trash

/datum/storage/trash/remove_single(mob/removing, obj/item/thing, atom/remove_to_loc, silent)
	real_location.visible_message(
		span_notice("[removing] starts fishing around inside [parent]."),
		span_notice("You start digging around in [parent] to try and pull something out."),
	)
	if(!do_after(removing, 1.5 SECONDS, parent))
		return FALSE

	return ..()
