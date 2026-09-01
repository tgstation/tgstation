///For simple overlays that really dont need to be complicated. Sometimes icon_state and icon is enough
///Remember to set the layers or shit wont work
/datum/bodypart_overlay/simple
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon = 'icons/mob/human/species/misc/bodypart_overlay_simple.dmi'
	///Color we apply to our overlay (none by default)
	var/draw_color

/datum/bodypart_overlay/simple/get_image(obj/item/bodypart/limb, layer_index, layer_real)
	return mutable_appearance(icon, icon_state, layer = layer_real)

/datum/bodypart_overlay/simple/color_image(image/overlay, obj/item/bodypart/limb, layer_index)
	overlay.color = draw_color

/datum/bodypart_overlay/simple/icon_render_key(obj/item/bodypart/limb)
	. = ..()
	. += icon_state

///A sixpack drawn on the chest
/datum/bodypart_overlay/simple/sixpack
	icon_state = "sixpack"
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE
	offset_location = ENTIRE_BODY

///bags drawn beneath the eyes
/datum/bodypart_overlay/simple/bags
	icon_state = "bags"
	draw_color = COLOR_WEBSAFE_DARK_GRAY
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	offset_location = UPPER_BODY

///PENDING eyes drawn on the face
/datum/bodypart_overlay/simple/soul_pending_eyes
	icon_state = "soul_pending_eyes"
	layers = list(EXTERNAL_FRONT = BODY_FRONT_LAYER)
	offset_location = UPPER_BODY
