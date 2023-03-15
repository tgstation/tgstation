/datum/storage/trash

/datum/storage/trash/remove_single(mob/removing, obj/item/thing, atom/newLoc, silent)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	resolve_location.visible_message(span_notice("[removing] starts fishing around inside \the [resolve_location]."),
		span_notice("You start digging around in \the [resolve_location] to try and pull something out."))
	if(!do_after(removing, 1.5 SECONDS, resolve_location))
		return

	return ..()

