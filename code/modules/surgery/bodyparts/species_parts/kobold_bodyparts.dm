/obj/item/bodypart/head/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_head"
	limb_id = SPECIES_KOBOLD
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = TRUE
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	teeth_count = 72

/obj/item/bodypart/chest/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_chest"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	is_dimorphic = FALSE
	wound_resistance = -10
	bodyshape = BODYSHAPE_MONKEY
	acceptable_bodyshape = BODYSHAPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY
	wing_types = list(/obj/item/organ/wings/functional/dragon)

/obj/item/bodypart/chest/kobold/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_LIZARD)

/obj/item/bodypart/arm/left/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_l_arm"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 5
	appendage_noun = "claw"

/obj/item/bodypart/arm/right/kobold
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_r_arm"
	limb_id = SPECIES_KOBOLD
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = TRUE
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 0
	appendage_noun = "claw"

/obj/item/bodypart/leg/left/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_l_leg"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/right/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_kobold_r_leg"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
