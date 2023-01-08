/datum/bodypart_overlay
	///Sometimes we need multiple layers, for like the back, middle and front of the person
	var/layers
	///Convert the bitflag define into the actual layer define
	var/static/list/all_layers = list(EXTERNAL_FRONT, EXTERNAL_ADJACENT, EXTERNAL_BEHIND)

	///Key of the icon states of all the sprite_datums for easy caching
	var/cache_key = ""

/datum/bodypart_overlay/proc/get_overlay(layer, obj/item/bodypart/limb)
	SHOULD_BE_PURE(TRUE)

	layer = bitflag_to_layer(layer)
	. = get_image(layer, limb)
	color_image(., layer, limb)

/datum/bodypart_overlay/proc/get_image(layer, obj/item/bodypart/limb)
	CRASH("Get image needs to be overridden")

/datum/bodypart_overlay/proc/color_image(image/overlay, layer)
	return

/datum/bodypart_overlay/proc/add_to_limb(obj/item/bodypart/limb)
	limb.bodypart_overlays += src

/datum/bodypart_overlay/proc/remove_from_limb(obj/item/bodypart/limb)
	limb.bodypart_overlays -= src

/datum/bodypart_overlay/proc/set_appearance()
	CRASH("Update appearance needs to be overridden")

/**This exists so sprite accessories can still be per-layer without having to include that layer's
*  number in their sprite name, which causes issues when those numbers change.
*/
/datum/bodypart_overlay/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"

///Converts a bitflag to the right layer. I'd love to make this a static index list, but byond made an attempt on my life when i did
/datum/bodypart_overlay/proc/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_BEHIND)
			return BODY_BEHIND_LAYER
		if(EXTERNAL_ADJACENT)
			return BODY_ADJ_LAYER
		if(EXTERNAL_FRONT)
			return BODY_FRONT_LAYER

///Check whether we can draw the overlays. You generally don't want lizard snouts to draw over an EVA suit
/datum/bodypart_overlay/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

///Colorizes the limb it's inserted to, if required.
/datum/bodypart_overlay/proc/override_color(rgb_value)
	CRASH("External organ color set to override with no override proc.")

/datum/bodypart_overlay/proc/generate_icon_cache()
	return render_key

