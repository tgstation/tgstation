//Variant of detective spyglass sunglasses
/obj/item/clothing/glasses/sunglasses/spy/overwatch
	name = "overwatch HUD"
	desc = "A fancy-shmancy set of glasses that let you view multiple camera feeds at once. \
		You can reposition the feeds by motioning with your hands, but your co-workers will think you're a complete tool."
	///A list of huds we will give upon being equipped.
	var/list/hudlist = list(DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED, DATA_HUD_SECURITY_ADVANCED)

/obj/item/clothing/glasses/sunglasses/spy/overwatch/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_EYES))
		return
	if(ishuman(user))
		for(var/hud in hudlist)
			var/datum/atom_hud/our_hud = GLOB.huds[hud]
			our_hud.show_to(user)
		user.add_traits(list(TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD), GLASSES_TRAIT)

/obj/item/clothing/glasses/sunglasses/spy/overwatch/dropped(mob/user)
	. = ..()
	user.remove_traits(list(TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD), GLASSES_TRAIT)
	if(ishuman(user))
		for(var/hud in hudlist)
			var/datum/atom_hud/our_hud = GLOB.huds[hud]
			our_hud.hide_from(user)

/obj/item/clothing/glasses/sunglasses/spy/overwatch/display_camera(mob/viewer, obj/item/clothing/accessory/spy_bug/our_bug)
	viewer.client?.setup_popup("spypopup", 5, 5, 1, "OVERWATCH")
	our_bug.cam_screen.display_to(viewer)
	our_bug.update_view()

/obj/item/clothing/accessory/spy_bug/overwatch
	name = "overwatch camera"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector" //Change me!!
	desc = "A camera streaming a live feed of YOU back to the Syndicate Overwatch agent back at base. \
		Particularly impressive footage will be edited with fitting music and posted to Syndicate propaganda outlets."
	cam_range = 3 //Make sure to change the window size here too!
