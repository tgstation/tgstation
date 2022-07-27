/datum/storage/bag_of_holding/attempt_insert(datum/source, obj/item/to_insert, mob/user, override, force)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(to_insert.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= resolve_parent

	if(istype(to_insert, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, .proc/recursive_insertion, to_insert, user)
		return

	return ..()

/datum/storage/bag_of_holding/proc/recursive_insertion(obj/item/to_insert, mob/living/user)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/safety = tgui_alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [to_insert.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" || QDELETED(to_insert) || QDELETED(resolve_parent) || QDELETED(user) || !user.canUseTopic(resolve_parent, BE_CLOSE, iscarbon(user)))
		return

	var/turf/loccheck = get_turf(resolve_parent)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(to_insert)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")

	user.gib(TRUE, TRUE, TRUE)
	new/obj/boh_tear(loccheck)
	qdel(resolve_parent)
