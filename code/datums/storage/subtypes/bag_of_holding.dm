/datum/storage/bag_of_holding
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 35
	max_slots = 30
	allow_big_nesting = TRUE

/datum/storage/bag_of_holding/attempt_insert(obj/item/to_insert, mob/user, override, force, messages)
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(to_insert.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= parent
	matching -= real_location

	if((istype(to_insert, /obj/item/storage/backpack/holding) || length(matching)) && can_insert(to_insert, user))
		INVOKE_ASYNC(src, PROC_REF(recursive_insertion), to_insert, user)
		return FALSE

	return ..()

/datum/storage/bag_of_holding/proc/recursive_insertion(obj/item/to_insert, mob/living/user)
	var/safety = tgui_alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [to_insert.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" \
		|| QDELETED(to_insert) \
		|| QDELETED(parent) \
		|| QDELETED(real_location) \
		|| QDELETED(user) \
		|| !user.can_perform_action(parent, NEED_DEXTERITY) \
		|| !can_insert(to_insert, user) \
	)
		return

	var/turf/rift_loc = get_turf(parent)
	user.visible_message(
		span_userdanger("The Bluespace interfaces of the two devices catastrophically malfunction!"),
		span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"),
	)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(rift_loc)].")
	user.log_message("detonated a bag of holding at [loc_name(rift_loc)].", LOG_ATTACK, color = "red")

	user.investigate_log("has been gibbed by a bag of holding recursive insertion.", INVESTIGATE_DEATHS)
	user.gib()
	var/obj/boh_tear/tear = new(rift_loc)
	tear.start_disaster()
	qdel(to_insert)
	qdel(parent)
