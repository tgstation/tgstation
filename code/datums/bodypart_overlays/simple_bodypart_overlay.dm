///For simple overlays that really dont need to be complicated. Sometimes icon_state and icon is enough
///Remember to set the layers or shit wont work
/datum/bodypart_overlay/simple
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon
	///Color we apply to our overlay (none by default)
	var/draw_color

/datum/bodypart_overlay/simple/get_image(layer, obj/item/bodypart/limb)
	return image(icon, icon_state, layer = layer)

/datum/bodypart_overlay/simple/color_image(image/overlay, layer)
	overlay.color = draw_color
