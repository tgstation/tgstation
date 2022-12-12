/obj/item/bodypart/head/monkey
	name = "monkey head"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE

/obj/item/bodypart/chest/monkey
	name = "monkey chest"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	wound_resistance = -10
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE

/obj/item/bodypart/arm/left/monkey
	name = "monkey left arm"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 1 /// monkey punches must be really weak, considering they bite people instead and their bites are weak as hell.
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3

/obj/item/bodypart/arm/right/monkey
	name = "monkey right arm"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 1
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3

/obj/item/bodypart/leg/left/monkey
	name = "monkey left leg"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4

/obj/item/bodypart/leg/right/monkey
	name = "monkey right leg"
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
