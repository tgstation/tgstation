/obj/item/bodypart/head/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_state = "kobold_head"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	teeth_count = 72

/obj/item/bodypart/chest/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_state = "kobold_chest"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	wing_types = list(/obj/item/organ/wings/functional/dragon)

/obj/item/bodypart/chest/monkey/kobold/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_LIZARD)

/obj/item/bodypart/arm/left/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_state = "kobold_l_arm"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	unarmed_attack_verbs = list("slashed", "scratched", "clawed")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	appendage_noun = "claw"

/obj/item/bodypart/arm/right/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_r_arm"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	unarmed_attack_verbs = list("slashed", "scratched", "clawed")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	appendage_noun = "claw"

/obj/item/bodypart/leg/left/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_l_leg"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE

/obj/item/bodypart/leg/right/monkey/kobold
	icon = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/kobold/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "kobold_r_leg"
	limb_id = SPECIES_KOBOLD
	should_draw_greyscale = TRUE
	bodyshape = BODYSHAPE_MONKEY
