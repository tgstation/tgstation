/obj/item/organ/external/floran_leaves
	name = "floran leaves"
	desc = "you shouldn't see this"
	organ_flags = ORGAN_UNREMOVABLE
	icon_state = "floran_leaves"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_floran_leaves"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_FLORAN_LEAVES

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/floran_leaves

/datum/bodypart_overlay/mutant/floran_leaves
	layers = EXTERNAL_ADJACENT
	feature_key = "floran_leaves"
	// color_source = ORGAN_COLOR_MUTSECONDARY

	var/color_swapped_layer = EXTERNAL_ADJACENT//Remove when MUTCOLORS_SECONDARY works
	var/color_inverse_base = 255//Remove when MUTCOLORS_SECONDARY works

/datum/bodypart_overlay/mutant/floran_leaves/get_global_feature_list()
	return GLOB.floran_leaves_list

/datum/bodypart_overlay/mutant/floran_leaves/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)//Remove when MUTCOLORS_SECONDARY works
	if(draw_layer != bitflag_to_layer(color_swapped_layer))
		return ..()

	if(draw_color)
		var/list/rgb_list = rgb2num(draw_color)
		overlay.color = rgb(color_inverse_base - rgb_list[1], color_inverse_base - rgb_list[2], color_inverse_base - rgb_list[3])
	else
		overlay.color = null

/datum/bodypart_overlay/mutant/floran_leaves/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/floran_leaves/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
