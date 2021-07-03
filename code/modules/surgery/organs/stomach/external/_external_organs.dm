/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."

	var/mob_icon_state = ""
	var/mob_icon = 'icons/mob/mutant_bodyparts.dmi'
	var/original_mob_icon_state = ""
	var/layers = list()

	var/preference = ""
	///Sometimes we need to do some extra work on the sprite, so save the sprite datum
	var/datum/sprite_accessory/sprite_datum

	var/obj/item/bodypart/ownerlimb

/obj/item/organ/external/Initialize(mapload, _mob_sprite, body_type)
	. = ..()

	prepare_sprite(_mob_sprite ? _mob_sprite : mob_icon_state, body_type)

/obj/item/organ/external/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	var/obj/item/bodypart/limb = reciever.get_bodypart(zone)

	if(!limb)
		return FALSE

	limb.external_organs.Add(src)
	ownerlimb = limb

	. =  ..()

	limb.contents.Add(src)

	reciever.update_body_parts()


/obj/item/organ/external/Remove(mob/living/carbon/organ_owner, special)
	. = ..()

	if(ownerlimb)
		ownerlimb.external_organs.Remove(src)
		ownerlimb.contents.Remove(src)

	organ_owner.update_body_parts()

/obj/item/organ/external/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	. = ..()

	bodypart.external_organs.Add(src)
	bodypart.contents.Add(src)

/obj/item/organ/external/proc/prepare_sprite(base_icon, body_type)
	if(!base_icon)
		base_icon = original_mob_icon_state ? original_mob_icon_state : mob_icon_state

	var/g = (body_type == FEMALE) ? "f" : "m"

	original_mob_icon_state = base_icon
	base_icon = parse_sprite(base_icon)
	mob_icon_state = (sprite_datum.gender_specific ? g : "m") + "_" + preference + "_" + base_icon

///Because all the preferences have names like "Beautiful Sharp Snout" and the actual icons are called "sharpsnout" we need to translate it with a globally generated list
/obj/item/organ/external/proc/parse_sprite(sprite)
	var/list/feature_list = get_global_feature_list()
	sprite_datum = feature_list[sprite]
	mob_icon = sprite_datum.icon
	return sprite_datum.icon_state

///Return a dumb glob list for this specific feature (called from parse_sprite)
/obj/item/organ/external/proc/get_global_feature_list()
	return null

/obj/item/organ/external/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/proc/prepare_overlay(mutable_appearance/pic)
	if(sprite_datum.center)
		center_image(pic, sprite_datum.dimension_x, sprite_datum.dimension_y)
	return pic

/obj/item/organ/external/horns
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS
	layers = list(EXTERNAL_ADJACENT)

	preference = "horns"

/obj/item/organ/external/horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(head.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return TRUE

/obj/item/organ/external/horns/get_global_feature_list()
	return GLOB.horns_list

/obj/item/organ/external/frills
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS
	layers = list(EXTERNAL_ADJACENT)

	preference = "frills"

/obj/item/organ/external/frills/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(head.flags_inv & HIDEEARS))
		return TRUE

/obj/item/organ/external/frills/get_global_feature_list()
	return GLOB.frills_list

/obj/item/organ/external/snout
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	layers = list(EXTERNAL_ADJACENT)

	preference = "snout"

/obj/item/organ/external/snout/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(head.flags_inv & HIDESNOUT))
		return TRUE

/obj/item/organ/external/snout/get_global_feature_list()
	return GLOB.snouts_list

/obj/item/organ/external/antennae
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE
	layers = list(EXTERNAL_FRONT, EXTERNAL_BEHIND)

	preference = "moth_antennae"

/obj/item/organ/external/antennae/get_global_feature_list()
	return GLOB.moth_antennae_list
