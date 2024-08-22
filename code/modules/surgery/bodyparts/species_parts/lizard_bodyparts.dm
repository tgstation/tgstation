/obj/item/bodypart/head/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE
	head_flags = HEAD_HAIR| HEAD_EYESPRITES | HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_EYECOLOR

/obj/item/bodypart/chest/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE

/obj/item/bodypart/arm/left/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	can_be_digitigrade = TRUE
	digitigrade_id = "digitigrade"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS

/obj/item/bodypart/leg/right/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	can_be_digitigrade = TRUE
	digitigrade_id = "digitigrade"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
