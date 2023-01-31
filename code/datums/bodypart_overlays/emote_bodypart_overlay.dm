///Variant of bodypart_overlay for displaying emote overlays. Emotes can use a path to one of these for their emote_visual field to display it after emoting.
/datum/bodypart_overlay/simple/emote
	icon = 'icons/mob/species/human/human_face.dmi'
	///The offset define to use with the overlay (none by default), should correspond with a list(0,0) in a species' offset_features
	var/offset
	///X offset of the overlay image, stored here so we can know this even after the owner loses the bodypart we're on
	var/offset_x = 0
	///Y offset of the overlay image, stored here so we can know this even after the owner loses the bodypart we're on
	var/offset_y = 0

	///The time it should take for the overlay to be removed after emoting
	var/emote_duration = 5.2 SECONDS
	///The body zone to attach the overlay to, overlay won't be added if no bodypart can be found with this
	var/attached_body_zone = BODY_ZONE_CHEST

/datum/bodypart_overlay/simple/emote/get_image(layer, obj/item/bodypart/limb)
	var/image/image = ..()
	image.pixel_x = offset_x
	image.pixel_y = offset_y
	return image

/datum/bodypart_overlay/simple/emote/added_to_limb(obj/item/bodypart/limb)
	if(offset in limb.owner?.dna?.species.offset_features)
		offset_x = limb.owner.dna.species.offset_features[offset][1]
		offset_y = limb.owner.dna.species.offset_features[offset][2]

/datum/bodypart_overlay/simple/emote/blush
	icon_state = "blush"
	draw_color = COLOR_BLUSH_PINK
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD

/datum/bodypart_overlay/simple/emote/cry
	icon_state = "tears"
	draw_color = COLOR_DARK_CYAN
	emote_duration = 12.8 SECONDS
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD
