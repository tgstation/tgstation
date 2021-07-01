/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."
	icon = 'icons/mob/mutant_bodyparts.dmi'


	var/mob_sprite = ""
	var/layers = list()
	var/gender_specific = FALSE

	var/obj/item/bodypart/ownerlimb

/obj/item/organ/external/Initialize(mapload, _mob_sprite, body_type)
	. = ..()

	prepare_sprite(_mob_sprite ? _mob_sprite : mob_sprite, body_type)

/obj/item/organ/external/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	var/obj/item/bodypart/limb = reciever.get_bodypart(zone)

	if(!limb)
		return FALSE

	limb.external_organs.Add(src)
	ownerlimb = limb

	. =  ..()

	limb.contents.Add(src)

/obj/item/organ/external/Remove(mob/living/carbon/organ_owner, special)
	. = ..()

	if(ownerlimb)
		ownerlimb.external_organs.Remove(src)
		ownerlimb.contents.Remove(src)


/obj/item/organ/external/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	. = ..()

	bodypart.external_organs.Add(src)
	bodypart.contents.Add(src)

/obj/item/organ/external/attach_limb

/obj/item/organ/external/proc/prepare_sprite(base_icon, body_type)
	if(!base_icon)
		return

	var/g = (body_type == FEMALE) ? "f" : "m"

	mob_sprite = (gender_specific ? g : "m") + "_" + slot + "_" + base_icon

/obj/item/organ/external/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/horns
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS
	layers = list(BODY_ADJ_LAYER)

/obj/item/organ/external/horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(head.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return TRUE

/obj/item/organ/external/frills
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS
	layers = list(BODY_ADJ_LAYER)

/obj/item/organ/external/frills/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(head.flags_inv & HIDEEARS))
		return TRUE

/obj/item/organ/external/snout
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	layers = list(BODY_ADJ_LAYER)

/obj/item/organ/external/snout/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(head.flags_inv & HIDESNOUT))
		return TRUE

/obj/item/organ/external/antennae
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE
	layers = list(BODY_ADJ_LAYER)


