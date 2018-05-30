/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if((istype(W, /obj/item/storage/backpack/holding) || count_by_type(W.GetAllContents(), /obj/item/storage/backpack/holding)))
		var/turf/loccheck = get_turf(A)
		if(istype(loccheck.loc, /area/fabric_of_reality))
			to_chat(user, "<span class='danger'>You can't do that here!</span>")
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Abort", "Proceed")
		if(safety == "Abort" || !in_range(A, user) || !A || !W || user.incapacitated())
			return
		to_chat(user, "<span class='danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)
		for(var/turf/T in range(6,loccheck))
			if(istype(T, /turf/open/space/transit))
				continue
			T.TerraformTurf(/turf/open/chasm/magic, /turf/open/chasm/magic)
		message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [get_area_name(loccheck, TRUE)] [ADMIN_COORDJMP(loccheck)].")
		log_game("[key_name(user)] detonated a bag of holding at [get_area_name(loccheck, TRUE)] [COORD(loccheck)].")
		qdel(A)
		return
	. = ..()
