/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W) //don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, .proc/recursive_insertion, W, user)
		return
	. = ..()

/datum/component/storage/concrete/bluespace/bag_of_holding/proc/recursive_insertion(obj/item/W, mob/living/user)
	var/atom/A = parent
	var/safety = tgui_alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)))
		return
	var/turf/loccheck = get_turf(A)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(W)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")

	user.gib(TRUE, TRUE, TRUE)
	new/obj/boh_tear(loccheck)
	qdel(A)
