/datum/sprite_accessory/tajaran_limb_markings
	icon = 'icons/bandastation/mob/species/tajaran/sprite_accessories/limb_markings.dmi'
	color_src = TRUE

/datum/sprite_accessory/tajaran_limb_markings/patch
	name = "Patch"
	icon_state = "patch"

/datum/sprite_accessory/tajaran_limb_markings/points
	name = "Points"
	icon_state = "points"

/datum/sprite_accessory/tajaran_limb_markings/tiger
	name = "Tiger"
	icon_state = "tiger"

/datum/sprite_accessory/tajaran_limb_markings/cheetah
	name = "Cheetah"
	icon_state = "cheetah"

// MARK: bodypart_overlay
/datum/bodypart_overlay/simple/body_marking/tajaran_limb
	dna_feature_key = FEATURE_TAJARAN_LIMB_MARKINGS
	dna_color_feature_key = FEATURE_TAJARAN_BODY_MARKINGS_COLOR
	applies_to = list(
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left/digitigrade,
		/obj/item/bodypart/leg/right/digitigrade
	)

/datum/bodypart_overlay/simple/body_marking/tajaran_limb/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	. = ..()
	if(!.)
		return
	return CHECK_DIGI_LEGS(bodypart_owner.owner)
