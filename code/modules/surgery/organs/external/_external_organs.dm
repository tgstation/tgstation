/**
* System for drawing organs with overlays. These overlays are drawn directly on the bodypart, attached to a person or not
* Works in tandem with the /datum/sprite_accessory datum to generate sprites
* Unlike normal organs, we're actually inside a persons limbs at all times
*/
/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."

	///Unremovable is until the features are completely finished
	organ_flags = ORGAN_UNREMOVABLE | ORGAN_EDIBLE
	visual = TRUE

	///Sometimes we need multiple layers, for like the back, middle and front of the person
	var/layers
	///Convert the bitflag define into the actual layer define
	var/static/list/all_layers = list(EXTERNAL_FRONT, EXTERNAL_ADJACENT, EXTERNAL_BEHIND)

	///Defines what kind of 'organ' we're looking at. Sprites have names like 'm_firemoth_mothwings'. 'mothwings' would then be feature_key
	var/feature_key = ""

	/// The savefile_key of the preference this relates to. Used for the preferences UI.
	var/preference

	///Sprite datum we use to draw on the bodypart
	var/datum/sprite_accessory/sprite_datum
	///Key of the icon states of all the sprite_datums for easy caching
	var/cache_key = ""

	///With what DNA block do we mutate in mutate_feature() ? For genetics
	var/dna_block

	///Reference to the limb we're inside of
	var/obj/item/bodypart/ownerlimb

/**mob_sprite is optional if you havent set sprite_datums for the object, and is used mostly to generate sprite_datums from a persons DNA
* For _mob_sprite we make a distinction between "Round Snout" and "round". Round Snout is the name of the sprite datum, while "round" would be part of the sprite
* I'm sorry
*/
/obj/item/organ/external/Initialize(mapload, mob_sprite)
	. = ..()
	if(mob_sprite)
		set_sprite(mob_sprite)

/obj/item/organ/external/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	var/obj/item/bodypart/limb = reciever.get_bodypart(zone)

	if(!limb)
		return FALSE

	limb.external_organs.Add(src)
	ownerlimb = limb

	. = ..()

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

///Add the overlays we need to draw on a person. Called from _bodyparts.dm
/obj/item/organ/external/proc/get_overlays(list/overlay_list, image_dir, image_layer, body_type, image_color)
	if(!sprite_datum)
		return

	var/gender = (body_type == FEMALE) ? "f" : "m"
	var/finished_icon_state = (sprite_datum.gender_specific ? gender : "m") + "_" + feature_key + "_" + sprite_datum.icon_state + mutant_bodyparts_layertext(image_layer)
	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = -image_layer)
	appearance.dir = image_dir

	if(sprite_datum.color_src) //There are multiple flags, but only one is ever used so meh :/
		appearance.color = image_color

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	overlay_list += appearance

/obj/item/organ/external/proc/set_sprite(sprite_name)
	sprite_datum = get_sprite_datum(sprite_name)
	cache_key = generate_icon_cache()

///Generate a unique key based on our sprites. So that if we've aleady drawn these sprites, they can be found in the cache and wont have to be drawn again (blessing and curse)
/obj/item/organ/external/proc/generate_icon_cache()
	return "[sprite_datum.icon_state]_[feature_key]"

/**This exists so sprite accessories can still be per-layer without having to include that layer's
*  number in their sprite name, which causes issues when those numbers change.
*/
/obj/item/organ/external/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "_BEHIND"
		if(BODY_ADJ_LAYER)
			return "_ADJ"
		if(BODY_FRONT_LAYER)
			return "_FRONT"

///Converts a bitflag to the right layer. I'd love to make this a static index list, but byond made an attempt on my life when i did
/obj/item/organ/external/proc/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_BEHIND)
			return BODY_BEHIND_LAYER
		if(EXTERNAL_ADJACENT)
			return BODY_ADJ_LAYER
		if(EXTERNAL_FRONT)
			return BODY_FRONT_LAYER

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

///Update our features after something changed our appearance
/obj/item/organ/external/proc/mutate_feature(features, mob/living/carbon/human/human)
	if(!dna_block || !get_global_feature_list())
		return

	var/list/feature_list = get_global_feature_list()

	set_sprite(feature_list[deconstruct_block(get_uni_feature_block(features, dna_block), feature_list.len)])

///The horns of a lizard!
/obj/item/organ/external/horns
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS
	layers = EXTERNAL_ADJACENT

	feature_key = "horns"
	preference = "feature_lizard_horns"

	dna_block = DNA_HORNS_BLOCK

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
	layers = EXTERNAL_ADJACENT

	feature_key = "frills"
	preference = "feature_lizard_frills"

	dna_block = DNA_FRILLS_BLOCK

/obj/item/organ/external/frills/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEEARS))
		return TRUE
	return FALSE


/obj/item/organ/external/frills/get_global_feature_list()
	return GLOB.frills_list

///Guess what part of the lizard this is?
/obj/item/organ/external/snout
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	layers = EXTERNAL_ADJACENT

	feature_key = "snout"
	preference = "feature_lizard_snout"

	dna_block = DNA_SNOUT_BLOCK

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
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

	feature_key = "moth_antennae"
	preference = "feature_moth_antennae"

	dna_block = DNA_MOTH_ANTENNAE_BLOCK

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
	return TRUE

///check if our antennae can burn off ;_;
/obj/item/organ/external/antennae/proc/try_burn_antennae(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious antennae burn to a crisp!"))

		burn_antennae()
		human.update_body_parts()

/obj/item/organ/external/antennae/proc/burn_antennae()
	burnt = TRUE
	original_sprite = sprite_datum.name
	set_sprite("Burnt Off")

///heal our antennae back up!!
/obj/item/organ/external/antennae/proc/heal_antennae()
	SIGNAL_HANDLER

	if(burnt)
		burnt = FALSE
		set_sprite(original_sprite)
