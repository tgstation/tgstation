/obj/item/bodypart/head/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE

/obj/item/bodypart/chest/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = TRUE

/obj/item/bodypart/l_arm/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/obj/item/bodypart/r_arm/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/obj/item/bodypart/l_leg/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/obj/item/bodypart/r_leg/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD

/obj/item/bodypart/l_leg/digitigrade
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_TYPE_DIGITIGRADE
	bodytype = list(BODYTYPE_HUMANOID, BODYTYPE_ORGANIC, BODYTYPE_DIGITIGRADE)

/obj/item/bodypart/l_leg/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/clothing/shoes/worn_shoes = human_owner.get_item_by_slot(ITEM_SLOT_FEET)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		var/shoes_compatible = FALSE
		if(!(human_owner.w_uniform) || (human_owner.w_uniform.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE])) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!human_owner.wear_suit) || (human_owner.wear_suit.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE]) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
			suit_compatible = TRUE
		if((worn_shoes == null) || (worn_shoes.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE]))
			shoes_compatible = TRUE

		if((uniform_compatible && suit_compatible && shoes_compatible) || (suit_compatible && shoes_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			limb_id = BODYPART_TYPE_DIGITIGRADE

		else
			limb_id = SPECIES_LIZARD

/obj/item/bodypart/r_leg/digitigrade
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = BODYPART_TYPE_DIGITIGRADE
	bodytype = list(BODYTYPE_HUMANOID, BODYTYPE_ORGANIC, BODYTYPE_DIGITIGRADE)

/obj/item/bodypart/r_leg/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/clothing/shoes/worn_shoes = human_owner.get_item_by_slot(ITEM_SLOT_FEET)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		var/shoes_compatible = FALSE
		if(!(human_owner.w_uniform) || (human_owner.w_uniform.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE])) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!human_owner.wear_suit) || (human_owner.wear_suit.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE]) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
			suit_compatible = TRUE
		if((worn_shoes == null) || (worn_shoes.alt_appearances_by_bodytype?[BODYTYPE_DIGITIGRADE]))
			shoes_compatible = TRUE

		if((uniform_compatible && suit_compatible && shoes_compatible) || (suit_compatible && shoes_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			limb_id = BODYPART_TYPE_DIGITIGRADE

		else
			limb_id = SPECIES_LIZARD
