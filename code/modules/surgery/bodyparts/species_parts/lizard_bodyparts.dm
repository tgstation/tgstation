/obj/item/bodypart/head/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	// lizardshave many teeth
	teeth_count = 72

/obj/item/bodypart/chest/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = TRUE
	wing_types = list(/obj/item/organ/wings/functional/dragon)

/obj/item/bodypart/chest/lizard/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_LIZARD)

/obj/item/bodypart/arm/left/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/obj/item/bodypart/leg/right/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/// Checks if this mob is wearing anything that does not have a valid sprite set for digitigrade legs
/// (In other words, is the mob's digitigrade body squished by its clothing?)
/mob/living/carbon/proc/is_digitigrade_squished()
	return FALSE

/mob/living/carbon/human/is_digitigrade_squished()
	var/obj/item/clothing/shoes/worn_shoes = shoes
	var/obj/item/clothing/under/worn_suit = wear_suit
	var/obj/item/clothing/under/worn_uniform = w_uniform

	var/uniform_compatible = isnull(worn_uniform) \
		|| (worn_uniform.supports_variations_flags & DIGITIGRADE_VARIATIONS) \
		|| !(worn_uniform.body_parts_covered & LEGS) \
		|| (worn_suit?.flags_inv & HIDEJUMPSUIT) // If suit hides our jumpsuit, it doesn't matter if it squishes

	var/suit_compatible = isnull(worn_suit) \
		|| (worn_suit.supports_variations_flags & DIGITIGRADE_VARIATIONS) \
		|| !(worn_suit.body_parts_covered & LEGS)

	var/shoes_compatible = isnull(worn_shoes) \
		|| (worn_shoes.supports_variations_flags & DIGITIGRADE_VARIATIONS)

	return !uniform_compatible || !suit_compatible || !shoes_compatible

/obj/item/bodypart/leg/left/digitigrade
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_LIZARD : BODYPART_ID_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_LIZARD : BODYPART_ID_DIGITIGRADE
