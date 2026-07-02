///Bodypart ovarlay datum. These can be added to any limb to give them a proper overlay, that'll even stay if the limb gets removed
///This is the abstract parent, don't use it!!
/datum/bodypart_overlay
	/// Sometimes we need multiple layers, for like the back, middle and front of the person (EXTERNAL_FRONT, EXTERNAL_ADJACENT, EXTERNAL_BEHIND)
	var/layers
	/// List of all possible layers to their real layer. Used for looping through in drawing
	var/static/alist/all_layers = alist(
		EXTERNAL_FRONT = -BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = -BODY_ADJ_LAYER,
		EXTERNAL_BEHIND = -BODY_BEHIND_LAYER,
	)
	/// Key of the icon states of all the sprite_datums for easy caching
	var/cache_key = ""
	/// Whether the overlay blocks emissive light
	var/blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	/// Can this overlay be drawn on husked mobs?
	var/draw_on_husks = HUSK_OVERLAY_NONE
	/// Determines body area of the overlay for height offsets
	var/offset_location = NO_MODIFY

///Wrapper for getting the proper image, colored and everything
/datum/bodypart_overlay/proc/get_overlay(layer, obj/item/bodypart/limb)
	var/image/main_image = get_image(layer, limb)

	if (limb?.is_husked && draw_on_husks != HUSK_OVERLAY_NORMAL)
		main_image = huskify_image(main_image)
		main_image.color = limb.husk_color
	else
		color_image(main_image, layer, limb)

	var/list/created_overlays = list(main_image)
	if(blocks_emissive != EMISSIVE_BLOCK_NONE && !isnull(limb))
		created_overlays += emissive_blocker(main_image.icon, main_image.icon_state, limb, layer = main_image.layer, alpha = main_image.alpha)

	return created_overlays

/datum/bodypart_overlay/proc/huskify_image(image/main_image)
	var/icon/husk_icon = new(main_image.icon)
	husk_icon.ColorTone(HUSK_COLOR_TONE)
	main_image.icon = husk_icon
	return main_image

///Generate the image. Needs to be overridden
/datum/bodypart_overlay/proc/get_image(layer, obj/item/bodypart/limb)
	CRASH("Get image needs to be overridden")

///Color the image
/datum/bodypart_overlay/proc/color_image(image/overlay, layer, obj/item/bodypart/limb)
	return

///Called on being added to a limb
/datum/bodypart_overlay/proc/added_to_limb(obj/item/bodypart/limb)
	return

///Called on being removed from a limb
/datum/bodypart_overlay/proc/removed_from_limb(obj/item/bodypart/limb)
	return

///Use this to change the appearance (and yes you must overwrite hahahahahah) (or don't use this, I just don't want people directly changing the image)
/datum/bodypart_overlay/proc/set_appearance()
	CRASH("Update appearance needs to be overridden")

/**This exists so sprite accessories can still be per-layer without having to include that layer's
*  number in their sprite name, which causes issues when those numbers change.
*/
/datum/bodypart_overlay/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(-BODY_BEHIND_LAYER)
			return "BEHIND"
		if(-BODY_ADJ_LAYER)
			return "ADJ"
		if(-BODY_FRONT_LAYER)
			return "FRONT"

///Check whether we can draw the overlays. You generally don't want lizard snouts to draw over an EVA suit
/datum/bodypart_overlay/proc/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	SHOULD_CALL_PARENT(TRUE)
	return !bodypart_owner.is_husked || draw_on_husks

///Colorizes the limb it's inserted to, if required.
/datum/bodypart_overlay/proc/override_color(obj/item/bodypart/bodypart_owner)
	CRASH("External organ color set to override with no override proc.")

///Generate a unique identifier to cache with. If you change something about the image, but the icon cache stays the same, it'll simply pull the unchanged image out of the cache
/datum/bodypart_overlay/proc/icon_render_key(obj/item/bodypart/limb)
	return list()
