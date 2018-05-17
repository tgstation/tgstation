/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if((istype(W, /obj/item/storage/backpack/holding) || count_by_type(W.GetAllContents(), /obj/item/storage/backpack/holding)))
		var/turf/loccheck = get_turf(A)
		if(is_reebe(loccheck.z))
			user.visible_message("<span class='warning'>An unseen force knocks [user] to the ground!</span>", "<span class='big_brass'>\"I think not!\"</span>")
			user.Knockdown(60)
			return
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Proceed", "Abort")
		if(safety == "Abort" || !in_range(A, user) || !A || !W || user.incapacitated())
			return
		A.investigate_log("has become a singularity. Caused by [user.key]", INVESTIGATE_SINGULO)
		to_chat(user, "<span class='danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		var/obj/singularity/singulo = new /obj/singularity (get_turf(A))
		singulo.energy = 300 //should make it a bit bigger~
		message_admins("[key_name_admin(user)] detonated a bag of holding")
		log_game("[key_name(user)] detonated a bag of holding")
		qdel(A)
		singulo.process()
		return
	. = ..()
