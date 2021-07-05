/**
* System for drawing organs with overlays. These overlays are drawn directly on the bodypart, attached to a person or not
* Works in tandem with the /datum/sprite_accessory datum to generate sprites
* Unlike normal organs, we're actually inside a persons limbs at all times
*/

/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."

	///Sometimes we need multiple layers, for like the back, middle and front of the person
	var/layers = list()

	///Defines what kind of 'organ' we're looking at. Sprites have names like 'm_firemoth_mothwings'. 'mothwings' would then be preference
	var/preference = ""
	///Sprite datums we use to draw on the bodypart
	var/list/sprite_datums = list()
	///Key of the icon states of all the sprite_datums for easy caching
	var/cache_key = ""

	///Reference to the limb we're inside of
	var/obj/item/bodypart/ownerlimb

/**_mob_sprite is optional if you havent set sprite_datums for the object, and is used mostly to generate sprite_datums from a persons DNA
* For _mob_sprite we make a distinction between "Round Snout" and "round". Round Snout is the name of the sprite datum, while "round" would be part of the sprite
* I'm sorry
*/
/obj/item/organ/external/Initialize(mapload, mob_sprite)
	. = ..()

	if(mob_sprite)
		add_sprite_datum(mob_sprite)

	cache_key = generate_icon_cache()

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
		ownerlimb = null

	organ_owner.update_body_parts()

/obj/item/organ/external/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	. = ..()

	bodypart.external_organs.Add(src)
	bodypart.contents.Add(src)

///Use a sprite NAME (Beautiful Moth Butt Wings) and find the appropriate sprite_accessory datum
/obj/item/organ/external/proc/add_sprite_datum(base_icon, clear_all=FALSE)
	if(clear_all)
		sprite_datums.Cut()
	var/sprite_datum = get_sprite_datum(base_icon)
	if(!sprite_datum)
		CRASH("[type] could not find a sprite accessory datum with the display name '[base_icon]")

	sprite_datums.Add(sprite_datum)

///Add the overlays we need to draw on a person. Called from _bodyparts.dm
/obj/item/organ/external/proc/get_overlays(list/overlay_list, image_dir, image_layer, body_type, image_color)
	generate_icon_cache()
	for(var/datum/sprite_accessory/sprite_datum as anything in sprite_datums)
		var/gender = (body_type == FEMALE) ? "f" : "m"
		var/finished_icon_state = (sprite_datum.gender_specific ? gender : "m") + "_" + preference + "_" + sprite_datum.icon_state + mutant_bodyparts_layertext(image_layer)
		var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = -image_layer)
		appearance.dir = image_dir

		if(sprite_datum.color_src) //There are multiple flags, but only one is ever used so meh :/
			appearance.color = image_color

		if(sprite_datum.center)
			center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

		overlay_list += appearance

///Generate a unique key based on our sprites. So that if we've aleady drawn these sprites, they can be found in the cache and wont have to be drawn again (blessing and curse)
/obj/item/organ/external/proc/generate_icon_cache()
	. = ""
	for(var/datum/sprite_accessory/sprite as anything in sprite_datums)
		. += "[sprite.icon_state]_[preference]"

/**This exists so sprite accessories can still be per-layer without having to include that layer's
*  number in their sprite name, which causes issues when those numbers change.
*/
/obj/item/organ/external/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(EXTERNAL_BEHIND)
			return "_BEHIND"
		if(EXTERNAL_ADJACENT)
			return "_ADJ"
		if(EXTERNAL_FRONT)
			return "_FRONT"

///Because all the preferences have names like "Beautiful Sharp Snout" we need to get the sprite datum with the actual important info
/obj/item/organ/external/proc/get_sprite_datum(sprite)
	var/list/feature_list = get_global_feature_list()
	return feature_list[sprite]

///Return a dumb glob list for this specific feature (called from parse_sprite)
/obj/item/organ/external/proc/get_global_feature_list()
	return null

///Check whether we can draw the overlays. You generally don't want lizard snouts to draw over an EVA suit
/obj/item/organ/external/proc/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

///The horns of a lizard!
/obj/item/organ/external/horns
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS
	layers = list(EXTERNAL_ADJACENT)

	preference = "horns"

/obj/item/organ/external/horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return TRUE
	return FALSE

/obj/item/organ/external/horns/get_global_feature_list()
	return GLOB.horns_list

///The frills of a lizard (like weird fin ears)
/obj/item/organ/external/frills
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS
	layers = list(EXTERNAL_ADJACENT)

	preference = "frills"

/obj/item/organ/external/frills/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEEARS))
		return TRUE

/obj/item/organ/external/frills/get_global_feature_list()
	return GLOB.frills_list

///Guess what part of the lizard this is?
/obj/item/organ/external/snout
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	layers = list(EXTERNAL_ADJACENT)

	preference = "snout"

/obj/item/organ/external/snout/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
		return TRUE
	return FALSE

/obj/item/organ/external/snout/get_global_feature_list()
	return GLOB.snouts_list

///A moth's antennae
/obj/item/organ/external/antennae
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE
	layers = list(EXTERNAL_FRONT, EXTERNAL_BEHIND)

	preference = "moth_antennae"

	///Are we burned?
	var/burnt = FALSE
	///Store our old sprite here for if our antennae wings are healed
	var/original_sprite = ""

/obj/item/organ/external/antennae/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()

	RegisterSignal(reciever, COMSIG_HUMAN_BURNING, .proc/try_burn_antennae)
	RegisterSignal(reciever, COMSIG_LIVING_POST_FULLY_HEAL, .proc/heal_antennae)

/obj/item/organ/external/antennae/Remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL))

/obj/item/organ/external/antennae/get_global_feature_list()
	return GLOB.moth_antennae_list

/obj/item/organ/external/antennae/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return TRUE
	return FALSE

///check if our antennae can burn off ;_;
/obj/item/organ/external/antennae/proc/try_burn_antennae(mob/living/carbon/human/human)
	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious antennae burn to a crisp!"))

		burn_antennae()
		human.update_body_parts()

/obj/item/organ/external/antennae/proc/burn_antennae()
	burnt = TRUE
	var/datum/sprite_accessory/antennae = sprite_datums[1]
	original_sprite = antennae.name
	add_sprite_datum("Burnt Off", TRUE)

///heal our antennae back up!!
/obj/item/organ/external/antennae/proc/heal_antennae()
	if(burnt)
		burnt = FALSE
		add_sprite_datum(original_sprite, TRUE)
