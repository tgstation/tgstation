/obj/item/organ/external/satyr_fluff
	name = "satyr fluff"
	desc = "You shouldn't see this"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_fluff"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FLUFF

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_fluff

/datum/bodypart_overlay/mutant/satyr_fluff
	layers = EXTERNAL_ADJACENT //| EXTERNAL_FRONT
	feature_key = "satyr_fluff"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/satyr_fluff/get_global_feature_list()
	return GLOB.satyr_fluff_list

/datum/bodypart_overlay/mutant/satyr_fluff/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_fluff/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE


/obj/item/organ/external/satyr_horns
	name = "satyr horns"
	desc = "You shouldn't see this"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_horns"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_horns

/datum/bodypart_overlay/mutant/satyr_horns
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	feature_key = "satyr_horns"

/datum/bodypart_overlay/mutant/satyr_horns/get_global_feature_list()
	return GLOB.satyr_horns_list

/datum/bodypart_overlay/mutant/satyr_horns/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE


/obj/item/organ/external/satyr_tail
	name = "satyr tail"
	desc = "You shouldn't see this"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_tail"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_TAIL

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_tail

/datum/bodypart_overlay/mutant/satyr_tail
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT
	feature_key = "satyr_tail"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/satyr_tail/get_global_feature_list()
	return GLOB.satyr_tail_list

/datum/bodypart_overlay/mutant/satyr_tail/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE
