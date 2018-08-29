/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W)		//don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.GetAllContents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Abort", "Proceed")
		if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)))
			return
		var/turf/loccheck = get_turf(A)
		if(is_reebe(loccheck.z))
			user.visible_message("<span class='warning'>An unseen force knocks [user] to the ground!</span>", "<span class='big_brass'>\"I think not!\"</span>")
			user.Knockdown(60)
			return
		if(istype(loccheck.loc, /area/fabric_of_reality))
			to_chat(user, "<span class='danger'>You can't do that here!</span>")
		to_chat(user, "<span class='danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)
		user.gib(TRUE, TRUE, TRUE)
		for(var/turf/T in range(6,loccheck))
			if(istype(T, /turf/open/space/transit))
				continue
			for(var/mob/living/M in T)
				if(M.movement_type & FLYING)
					M.visible_message("<span class='danger'>The bluespace collapse crushes the air towards it, pulling [M] towards the ground...</span>")
					M.Knockdown(5, TRUE, TRUE)		//Overrides stun absorbs.
			T.TerraformTurf(/turf/open/chasm/magic, /turf/open/chasm/magic)
		for (var/obj/structure/ladder/unbreakable/binary/ladder in GLOB.ladders)
			ladder.ActivateAlmonds()
		message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
		log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")
		qdel(A)
		return
	. = ..()
