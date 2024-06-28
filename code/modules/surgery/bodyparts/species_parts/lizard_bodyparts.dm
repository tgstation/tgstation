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
	wing_types = list(/obj/item/organ/external/wings/functional/dragon)

/obj/item/bodypart/chest/lizard/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_LIZARD)

/obj/item/bodypart/arm/left/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

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

/obj/item/bodypart/leg/left/digitigrade
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE

/obj/item/bodypart/leg/left/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/clothing/shoes/worn_shoes = human_owner.get_item_by_slot(ITEM_SLOT_FEET)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		var/shoes_compatible = FALSE
		if(!(human_owner.w_uniform) || (human_owner.w_uniform.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON))) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!human_owner.wear_suit) || (human_owner.wear_suit.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
			suit_compatible = TRUE
		if((worn_shoes == null) || (worn_shoes.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)))
			shoes_compatible = TRUE

		if((uniform_compatible && suit_compatible && shoes_compatible) || (suit_compatible && shoes_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			limb_id = BODYPART_ID_DIGITIGRADE

		else
			limb_id = SPECIES_LIZARD

/obj/item/bodypart/leg/right/digitigrade
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/clothing/shoes/worn_shoes = human_owner.get_item_by_slot(ITEM_SLOT_FEET)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		var/shoes_compatible = FALSE
		if(!(human_owner.w_uniform) || (human_owner.w_uniform.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON))) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!human_owner.wear_suit) || (human_owner.wear_suit.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
			suit_compatible = TRUE
		if((worn_shoes == null) || (worn_shoes.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)))
			shoes_compatible = TRUE

		if((uniform_compatible && suit_compatible && shoes_compatible) || (suit_compatible && shoes_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			limb_id = BODYPART_ID_DIGITIGRADE

		else
			limb_id = SPECIES_LIZARD
