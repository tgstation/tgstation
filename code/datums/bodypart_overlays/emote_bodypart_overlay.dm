///Emote bodypart overlay to keep whatever dumb stuff I do here seperate for now
///Don't forget to go over this again later
/datum/bodypart_overlay/emote
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon = 'icons/mob/species/human/human_face.dmi'
	///Color we apply to our overlay (none by default)
	var/draw_color
	///X offset of the overlay image
	var/offset_x = 0
	///Y offset of the overlay image
	var/offset_y = 0

/datum/bodypart_overlay/emote/get_image(layer, obj/item/bodypart/limb)
	var/image/overlay = image(icon, icon_state, layer = -layer) //-layer is a temporary fix, don't forget to remove later
	overlay.pixel_x = offset_x
	overlay.pixel_y = offset_y
	return overlay

/datum/bodypart_overlay/emote/color_image(mutable_appearance/overlay, layer)
	overlay.color = draw_color

/datum/bodypart_overlay/emote/added_to_limb(obj/item/bodypart/limb)
	if(OFFSET_FACE in limb.owner?.dna?.species.offset_features)
		var/offset = limb.owner.dna.species.offset_features[OFFSET_FACE]
		offset_x = offset[1]
		offset_y = offset[2]

/datum/bodypart_overlay/emote/blush
	layers = EXTERNAL_ADJACENT
	icon_state = "blush"
	draw_color = COLOR_BLUSH_PINK

/datum/bodypart_overlay/emote/cry
	layers = EXTERNAL_ADJACENT
	icon_state = "tears"
	draw_color = COLOR_DARK_CYAN
