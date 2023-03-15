/**
* System for drawing organs with overlays. These overlays are drawn directly on the bodypart, attached to a person or not
* Works in tandem with the /datum/sprite_accessory datum to generate sprites
* Unlike normal organs, we're actually inside a persons limbs at all times
*/
/obj/item/organ/external
	name = "external organ"
	desc = "An external organ that is too external."

	organ_flags = ORGAN_EDIBLE
	visual = TRUE

	///The overlay datum that actually draws stuff on the limb
	var/datum/bodypart_overlay/mutant/bodypart_overlay
	///Reference to the limb we're inside of
	var/obj/item/bodypart/ownerlimb
	///If not null, overrides the appearance with this sprite accessory datum
	var/sprite_accessory_override

	/// The savefile_key of the preference this relates to. Used for the preferences UI.
	var/preference
	///With what DNA block do we mutate in mutate_feature() ? For genetics
	var/dna_block

	///Set to EXTERNAL_BEHIND, EXTERNAL_FRONT or EXTERNAL_ADJACENT if you want to draw one of those layers as the object sprite. FALSE to use your own
	///This will not work if it doesn't have a limb to generate it's icon with
	var/use_mob_sprite_as_obj_sprite = FALSE
	///Does this organ have any bodytypes to pass to it's ownerlimb?
	var/external_bodytypes = NONE
	///Which flags does a 'modification tool' need to have to restyle us, if it all possible (located in code/_DEFINES/mobs)
	var/restyle_flags = NONE

/**mob_sprite is optional if you havent set sprite_datums for the object, and is used mostly to generate sprite_datums from a persons DNA
* For _mob_sprite we make a distinction between "Round Snout" and "round". Round Snout is the name of the sprite datum, while "round" would be part of the sprite
* I'm sorry
*/
/obj/item/organ/external/Initialize(mapload, accessory_type)
	. = ..()

	bodypart_overlay = new bodypart_overlay()

	accessory_type = accessory_type ? accessory_type : sprite_accessory_override
	var/update_overlays = TRUE
	if(accessory_type)
		bodypart_overlay.set_appearance(accessory_type)
		bodypart_overlay.imprint_on_next_insertion = FALSE
	else if(loc) //we've been spawned into the world, and not in nullspace to be added to a limb (yes its fucking scuffed)
		bodypart_overlay.randomize_appearance()
	else
		update_overlays = FALSE

	if(use_mob_sprite_as_obj_sprite && update_overlays)
		update_appearance(UPDATE_OVERLAYS)

	if(restyle_flags)
		RegisterSignal(src, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle))

/obj/item/organ/external/Destroy()
	if(owner)
		Remove(owner, special=TRUE)
	else if(ownerlimb)
		remove_from_limb()

	return ..()

/obj/item/organ/external/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	var/obj/item/bodypart/limb = receiver.get_bodypart(deprecise_zone(zone))

	if(!limb)
		return FALSE

	. = ..()

	if(!.)
		return

	if(bodypart_overlay.imprint_on_next_insertion) //We only want this set *once*

		bodypart_overlay.set_appearance_from_name(receiver.dna.features[bodypart_overlay.feature_key])
		bodypart_overlay.imprint_on_next_insertion = FALSE

	ownerlimb = limb
	add_to_limb(ownerlimb)

	if(external_bodytypes)
		limb.synchronize_bodytypes(receiver)

	receiver.update_body_parts()

/obj/item/organ/external/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()

	if(ownerlimb && !moving)
		remove_from_limb()

		if(use_mob_sprite_as_obj_sprite)
			update_appearance(UPDATE_OVERLAYS)

	if(organ_owner)
		organ_owner.update_body_parts()

///Transfers the organ to the limb, and to the limb's owner, if it has one.
/obj/item/organ/external/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	if(owner)
		Remove(owner, moving = TRUE)
	else if(ownerlimb)
		remove_from_limb()

	if(bodypart_owner)
		Insert(bodypart_owner, TRUE)
	else
		add_to_limb(bodypart)

/obj/item/organ/external/add_to_limb(obj/item/bodypart/bodypart)
	bodypart.external_organs += src
	ownerlimb = bodypart
	ownerlimb.add_bodypart_overlay(bodypart_overlay)
	return ..()

/obj/item/organ/external/remove_from_limb()
	ownerlimb.external_organs -= src
	ownerlimb.remove_bodypart_overlay(bodypart_overlay)
	if(ownerlimb.owner && external_bodytypes)
		ownerlimb.synchronize_bodytypes(ownerlimb.owner)
	ownerlimb = null
	return ..()

///Update our features after something changed our appearance
/obj/item/organ/external/proc/mutate_feature(features, mob/living/carbon/human/human)
	if(!dna_block)
		return

	var/list/feature_list = bodypart_overlay.get_global_feature_list()

	bodypart_overlay.set_appearance_from_name(feature_list[deconstruct_block(get_uni_feature_block(features, dna_block), feature_list.len)])

///If you need to change an external_organ for simple one-offs, use this. Pass the accessory type : /datum/accessory/something
/obj/item/organ/external/proc/simple_change_sprite(accessory_type)
	var/datum/sprite_accessory/typed_accessory = accessory_type //we only take types for maintainability

	bodypart_overlay.set_appearance(typed_accessory)

	if(owner) //are we in a person?
		owner.update_body_parts()
	else if(ownerlimb) //are we in a limb?
		ownerlimb.update_icon_dropped()
	//else if(use_mob_sprite_as_obj_sprite) //are we out in the world, unprotected by flesh?

/obj/item/organ/external/on_life(delta_time, times_fired)
	return

/obj/item/organ/external/update_overlays()
	. = ..()

	if(!use_mob_sprite_as_obj_sprite)
		return

	//Build the mob sprite and use it as our overlay
	for(var/external_layer in bodypart_overlay.all_layers)
		if(bodypart_overlay.layers & external_layer)
			. += bodypart_overlay.get_overlay(external_layer, limb = null)

///The horns of a lizard!
/obj/item/organ/external/horns
	name = "horns"
	desc = "Why do lizards even have horns? Well, this one obviously doesn't."
	icon_state = "horns"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	preference = "feature_lizard_horns"
	dna_block = DNA_HORNS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_ENAMEL

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns

/datum/bodypart_overlay/mutant/horns
	layers = EXTERNAL_ADJACENT
	feature_key = "horns"

/datum/bodypart_overlay/mutant/horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE

/datum/bodypart_overlay/mutant/horns/get_global_feature_list()
	return GLOB.horns_list

///The frills of a lizard (like weird fin ears)
/obj/item/organ/external/frills
	name = "frills"
	desc = "Ear-like external organs often seen on aquatic reptillians."
	icon_state = "frills"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS

	preference = "feature_lizard_frills"
	dna_block = DNA_FRILLS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills

/datum/bodypart_overlay/mutant/frills
	layers = EXTERNAL_ADJACENT
	feature_key = "frills"

/datum/bodypart_overlay/mutant/frills/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEEARS))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/frills/get_global_feature_list()
	return GLOB.frills_list

///Guess what part of the lizard this is?
/obj/item/organ/external/snout
	name = "lizard snout"
	desc = "Take a closer look at that snout!"
	icon_state = "snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT

	preference = "feature_lizard_snout"
	external_bodytypes = BODYTYPE_SNOUTED

	dna_block = DNA_SNOUT_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout

/datum/bodypart_overlay/mutant/snout
	layers = EXTERNAL_ADJACENT
	feature_key = "snout"

/datum/bodypart_overlay/mutant/snout/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/snout/get_global_feature_list()
	return GLOB.snouts_list

///A moth's antennae
/obj/item/organ/external/antennae
	name = "moth antennae"
	desc = "A moths antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	preference = "feature_moth_antennae"
	dna_block = DNA_MOTH_ANTENNAE_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae

	///Are we burned?
	var/burnt = FALSE
	///Store our old datum here for if our antennae are healed
	var/original_sprite_datum

/obj/item/organ/external/antennae/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()

	RegisterSignal(receiver, COMSIG_HUMAN_BURNING, PROC_REF(try_burn_antennae))
	RegisterSignal(receiver, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(heal_antennae))

/obj/item/organ/external/antennae/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL))

///check if our antennae can burn off ;_;
/obj/item/organ/external/antennae/proc/try_burn_antennae(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious antennae burn to a crisp!"))

		burn_antennae()
		human.update_body_parts()

///Burn our antennae off ;_;
/obj/item/organ/external/antennae/proc/burn_antennae()
	var/datum/bodypart_overlay/mutant/antennae/antennae = bodypart_overlay
	antennae.burnt = TRUE
	burnt = TRUE

///heal our antennae back up!!
/obj/item/organ/external/antennae/proc/heal_antennae(datum/source, heal_flags)
	SIGNAL_HANDLER

	if(!burnt)
		return

	if(heal_flags & (HEAL_LIMBS|HEAL_ORGANS))
		var/datum/bodypart_overlay/mutant/antennae/antennae = bodypart_overlay
		antennae.burnt = FALSE
		burnt = FALSE

///Moth antennae datum, with full burning functionality
/datum/bodypart_overlay/mutant/antennae
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "moth_antennae"
	///Accessory datum of the burn sprite
	var/datum/sprite_accessory/burn_datum = /datum/sprite_accessory/moth_antennae/burnt_off
	///Are we burned? If so we draw differently
	var/burnt = FALSE

/datum/bodypart_overlay/mutant/antennae/New()
	. = ..()

	burn_datum = fetch_sprite_datum(burn_datum) //turn the path into the singleton instance

/datum/bodypart_overlay/mutant/antennae/get_global_feature_list()
	return GLOB.moth_antennae_list

/datum/bodypart_overlay/mutant/antennae/get_base_icon_state()
	return burnt ? burn_datum.icon_state : sprite_datum.icon_state

///The leafy hair of a podperson
/obj/item/organ/external/pod_hair
	name = "podperson hair"
	desc = "Base for many-o-salads."

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_POD_HAIR

	preference = "feature_pod_hair"
	use_mob_sprite_as_obj_sprite = TRUE

	dna_block = DNA_POD_HAIR_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_PLANT

	bodypart_overlay = /datum/bodypart_overlay/mutant/pod_hair

///Podperson bodypart overlay, with special coloring functionality to render the flowers in the inverse color
/datum/bodypart_overlay/mutant/pod_hair
	layers = EXTERNAL_FRONT|EXTERNAL_ADJACENT
	feature_key = "pod_hair"

	///This layer will be colored differently than the rest of the organ. So we can get differently colored flowers or something
	var/color_swapped_layer = EXTERNAL_FRONT
	///The individual rgb colors are subtracted from this to get the color shifted layer
	var/color_inverse_base = 255

/datum/bodypart_overlay/mutant/pod_hair/get_global_feature_list()
	return GLOB.pod_hair_list

/datum/bodypart_overlay/mutant/pod_hair/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(draw_layer != bitflag_to_layer(color_swapped_layer))
		return ..()

	var/list/rgb_list = rgb2num(draw_color)
	overlay.color = rgb(color_inverse_base - rgb_list[1], color_inverse_base - rgb_list[2], color_inverse_base - rgb_list[3]) //inversa da color

/datum/bodypart_overlay/mutant/pod_hair/can_draw_on_bodypart(mob/living/carbon/human/human)
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE
