/datum/bodypart_overlay/simple
	var/icon_state
	var/icon

/datum/bodypart_overlay/simple/get_image(layer, obj/item/bodypart/limb)
	return image(icon, icon_state)
