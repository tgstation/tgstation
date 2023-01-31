///Emote bodypart overlay to keep whatever dumb stuff I do here seperate for now
///Don't forget to go over this again later
/datum/bodypart_overlay/emote
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon = 'icons/mob/species/human/human_face.dmi'
	///Color we apply to our overlay (none by default)
	var/draw_color
	///The offset define to use with the overlay (none by default), should correspond with a list(0,0) in a species' offset_features
	var/offset
	///X offset of the overlay image, stored here so we can know this even after the owner loses the bodypart we're on
	var/offset_x = 0
	///Y offset of the overlay image, stored here so we can know this even after the owner loses the bodypart we're on
	var/offset_y = 0

	///The time it should take for the overlay to be removed after emoting
	var/emote_duration = 5.2 SECONDS
	///The body zone to attach the overlay to
	var/attached_body_zone = BODY_ZONE_CHEST

/datum/bodypart_overlay/emote/get_image(layer, obj/item/bodypart/limb)
	var/image/overlay = image(icon, icon_state, layer = layer)
	overlay.pixel_x = offset_x
	overlay.pixel_y = offset_y
	return overlay

/datum/bodypart_overlay/emote/color_image(mutable_appearance/overlay, layer)
	overlay.color = draw_color

/datum/bodypart_overlay/emote/added_to_limb(obj/item/bodypart/limb)
	if(offset in limb.owner?.dna?.species.offset_features)
		offset_x = limb.owner.dna.species.offset_features[offset][1]
		offset_y = limb.owner.dna.species.offset_features[offset][2]

/datum/bodypart_overlay/emote/blush
	icon_state = "blush"
	draw_color = COLOR_BLUSH_PINK
	emote_duration = 5.2 SECONDS
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD

/datum/bodypart_overlay/emote/cry
	icon_state = "tears"
	draw_color = COLOR_DARK_CYAN
	emote_duration = 12.8 SECONDS
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD
