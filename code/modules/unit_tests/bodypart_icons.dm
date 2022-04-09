///Makes sure all bodyparts render
/datum/unit_test/bodypart_icons
	var/list/ignored_types(
			/obj/item/bodypart/l_arm/mushroom = TRUE, //Doesn't have hands for some reason
			/obj/item/bodypart/r_arm/mushroom = TRUE, //Doesn't have hands for some reason
		)

/datum/unit_test/bodypart_icons/Run()
	for(var/obj/item/bodypart/bodypart_path as anything in subtypesof(/obj/item/bodypart))
		if(ignored_types[bodypart_path])
			continue

		var/obj/item/bodypart/new_bodypart = new bodypart_path
		var/list/bodypart_overlays = new_bodypart.get_limb_icon()
		for(var/image/overlay as anything in bodypart_overlays)
			if(!icon_exists(overlay.icon, overlay.icon_state))
				Fail("Bodypart of type [bodypart_path] failed to generate an icon. File: [overlay.icon] | State: [overlay.icon_state]")
		qdel(new_bodypart)
