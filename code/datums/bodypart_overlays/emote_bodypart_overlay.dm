///Variant of bodypart_overlay for displaying emote overlays. See [/datum/emote/living/blush/run_emote] for an example on how to use one of these.
/datum/bodypart_overlay/simple/emote
	icon = 'icons/mob/species/human/emote_visuals.dmi'
	///The body zone to attach the overlay to, overlay won't be added if no bodypart can be found with this
	var/attached_body_zone = BODY_ZONE_CHEST
	///The offset define to use with the overlay (none by default), should correspond with a list(0,0) in a species' offset_features
	var/offset
	///X offset of the overlay image, stored here so we can access this even after bodypart we're on gets severed
	var/offset_x = 0
	///Y offset of the overlay image, stored here so we can access this even after bodypart we're on gets severed
	var/offset_y = 0
	///The bodypart that the overlay is currently applied to
	var/datum/weakref/attached_bodypart

/datum/bodypart_overlay/simple/emote/get_image(layer, obj/item/bodypart/limb)
	var/image/image = ..()
	image.pixel_x = offset_x
	image.pixel_y = offset_y
	return image

/datum/bodypart_overlay/simple/emote/added_to_limb(obj/item/bodypart/limb)
	attached_bodypart = WEAKREF(limb)
	if(offset in limb.owner?.dna?.species.offset_features)
		offset_x = limb.owner.dna.species.offset_features[offset][1]
		offset_y = limb.owner.dna.species.offset_features[offset][2]

/datum/bodypart_overlay/simple/emote/removed_from_limb(obj/item/bodypart/limb)
	attached_bodypart = null

///Removes the overlay from the attached bodypart and updates the necessary sprites
/datum/bodypart_overlay/simple/emote/Destroy()
	var/obj/item/bodypart/referenced_bodypart = attached_bodypart.resolve()
	if(!referenced_bodypart)
		return ..()
	referenced_bodypart.remove_bodypart_overlay(src)
	if(referenced_bodypart.owner) //Keep in mind that the bodypart could have been severed from the owner by now
		referenced_bodypart.owner.update_body_parts()
	else
		referenced_bodypart.update_icon_dropped()
	return ..()

/**
 * Creates a new emote bodypart overlay and applies it to the human. The overlay can be removed by simply deleting the returned overlay.
 *
 * * Arguments:
 * * overlay_typepath - Typepath to the overlay that should be applied. Should be a subtype of datum/bodypart_overlay/simple/emote.
 *
 * Returns the given overlay, which can be deleted to stop displaying it. Will return null if no bodypart matching the overlay's attached_body_zone field can be found.
 */
/mob/living/carbon/human/proc/give_emote_overlay(overlay_typepath)
	var/datum/bodypart_overlay/simple/emote/overlay = new overlay_typepath()
	var/obj/item/bodypart/bodypart = src.get_bodypart(overlay.attached_body_zone)
	if(!bodypart)
		return null
	bodypart.add_bodypart_overlay(overlay)
	src.update_body_parts()
	return overlay

/datum/bodypart_overlay/simple/emote/blush
	icon_state = "blush"
	draw_color = COLOR_BLUSH_PINK
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD

/datum/bodypart_overlay/simple/emote/cry
	icon_state = "tears"
	draw_color = COLOR_DARK_CYAN
	layers = EXTERNAL_ADJACENT
	offset = OFFSET_FACE
	attached_body_zone = BODY_ZONE_HEAD
