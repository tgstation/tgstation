/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."
	icon = 'icons/mob/mutant_bodyparts.dmi'


	var/mob_sprite = ""
	var/layers = list()
	var/gender_specific = FALSE

/obj/item/organ/external/Initialize(mapload, _mob_sprite, body_type)
	. = ..()

	prepare_sprite(_mob_sprite ? _mob_sprite : mob_sprite, body_type)

/obj/item/organ/external/proc/prepare_sprite(base_icon, body_type)
	if(!base_icon)
		return

	var/g = (body_type == FEMALE) ? "f" : "m"

	mob_sprite = (gender_specific ? g : 'm') + '_' + base_icon

/obj/item/organ/external/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/horns
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS
	layer = list(BODY_ADJ_LAYER)

/obj/item/organ/external/horns/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR)))
		return TRUE

/obj/item/organ/external/frills
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS
	layer = list(BODY_ADJ_LAYER)

/obj/item/organ/external/frills/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(source.head.flags_inv & HIDEEARS))
		return TRUE

/obj/item/organ/external/snout
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	layer = list(BODY_ADJ_LAYER)

/obj/item/organ/external/snout/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
		return TRUE

/obj/item/organ/external/antennae
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE
	layer = list(BODY_ADJ_LAYER)


