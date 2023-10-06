/datum/storage/bag_of_holding
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 35
	max_slots = 30
	allow_big_nesting = TRUE

/datum/storage/bag_of_holding/attempt_insert(obj/item/to_insert, mob/user, override, force)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(to_insert.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= resolve_parent

	if((istype(to_insert, /obj/item/storage/backpack/holding) || matching.len) && can_insert(to_insert, user))
		INVOKE_ASYNC(src, PROC_REF(recursive_insertion), to_insert, user, resolve_parent)
		return

	return ..()

/datum/storage/bag_of_holding/proc/recursive_insertion(obj/item/to_insert, mob/living/user, atom/resolve_parent)
	var/safety = tgui_alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [to_insert.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" || QDELETED(to_insert) || QDELETED(resolve_parent) || QDELETED(user) || !iscarbon(user) || !user.can_perform_action(resolve_parent, NEED_DEXTERITY) || !can_insert(to_insert, user))
		return

	var/turf/loccheck = get_turf(resolve_parent)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(to_insert)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	user.log_message("detonated a bag of holding at [loc_name(loccheck)].", LOG_ATTACK, color="red")

	user.investigate_log("has been gibbed by a bag of holding recursive insertion.", INVESTIGATE_DEATHS)
	user.gib()
	new/obj/boh_tear(loccheck)
	qdel(resolve_parent)
