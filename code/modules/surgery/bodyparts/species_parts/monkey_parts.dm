/obj/item/bodypart/head/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = FALSE
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_DEBRAIN

/obj/item/bodypart/head/monkey/Initialize(mapload)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_y = list("south" = 1),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_y = list("south" = 1),
	)
	return ..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	wound_resistance = -10
	bodyshape = BODYSHAPE_MONKEY
	acceptable_bodyshape = BODYSHAPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/chest/monkey/Initialize(mapload)
	worn_neck_offset = new(
		attached_part = src,
		feature_key = OFFSET_NECK,
		offset_y = list("south" = 1),
	)
	return ..()

/obj/item/bodypart/arm/left/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 5
	appendage_noun = "paw"

/obj/item/bodypart/arm/right/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = FALSE
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 0
	appendage_noun = "paw"

/obj/item/bodypart/leg/left/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/right/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
