/datum/sprite_accessory/vulpkanin_limb_markings
	icon = 'icons/bandastation/mob/species/vulpkanin/sprite_accessories/limb_markings.dmi'
	color_src = TRUE
	em_block = TRUE

/datum/sprite_accessory/vulpkanin_limb_markings/points_fade
	name = "Pointsfade"
	icon_state = "pointsfade"

/datum/sprite_accessory/vulpkanin_limb_markings/points_sharp
	name = "Sharp points"
	icon_state = "sharppoints"

/datum/sprite_accessory/vulpkanin_limb_markings/points_crest
	name = "Points and crest"
	icon_state = "crestpoints"

/datum/bodypart_overlay/simple/body_marking/vulpkanin_limb
	dna_feature_key = FEATURE_VULPKANIN_LIMB_MARKINGS
	dna_color_feature_key = FEATURE_VULPKANIN_BODY_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/leg/right/digitigrade,
		/obj/item/bodypart/leg/left/digitigrade,
	)

/datum/bodypart_overlay/simple/body_marking/vulpkanin_limb/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	. = ..()
	if(!.)
		return
	return CHECK_DIGI_LEGS(bodypart_owner.owner)
