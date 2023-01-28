///Emote bodypart overlay to keep whatever dumb stuff I do here seperate for now
///Don't forget to go over this again later
/datum/bodypart_overlay/emote
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon
	///Color we apply to our overlay (none by default)
	var/draw_color
	///X offset of the overlay image
	var/offset_x = 0
	///Y offset of the overlay image
	var/offset_y = 0

/datum/bodypart_overlay/emote/get_image(layer, obj/item/bodypart/limb)
	var/image/overlay = image(icon, icon_state, layer = layer)
	overlay.pixel_x = offset_x
	overlay.pixel_y = offset_y
	return overlay

/datum/bodypart_overlay/emote/color_image(mutable_appearance/overlay, layer)
	overlay.color = draw_color
