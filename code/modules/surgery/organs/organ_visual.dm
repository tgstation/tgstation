/**
 * System for drawing organs with overlays.
 * These overlays are drawn directly on the bodypart, attached to a person or not.
 * Works in tandem with the /datum/sprite_accessory and /datum/bodypart_overlay/mutant datums to generate sprites.
 */
/obj/item/organ
	/// The overlay datum that actually draws stuff on the limb
	var/datum/bodypart_overlay/mutant/bodypart_overlay
	/// If not null, overrides the appearance with this sprite accessory datum
	var/sprite_accessory_override

	/// The savefile_key of the preference this relates to. Used for the preferences UI.
	var/preference
	/// With what DNA block do we mutate in mutate_feature() ? For genetics
	var/dna_block

	/**
	 * Set to EXTERNAL_BEHIND, EXTERNAL_FRONT or EXTERNAL_ADJACENT if you want to draw one of those layers as the object sprite.
	 * FALSE to use your own.
	 * This will not work if it doesn't have a limb to generate it's icon with, yes that is scuffed.
	 */
	var/use_mob_sprite_as_obj_sprite = FALSE
	///Does this organ have any bodytypes to pass to it's ownerlimb?
	var/external_bodytypes = NONE
	/// Which flags does a 'modification tool' need to have to restyle us, if it all possible (located in code/_DEFINES/mobs)
	var/restyle_flags = NONE

/obj/item/organ/update_overlays()
	. = ..()
	if(!use_mob_sprite_as_obj_sprite)
		return

	//Build the mob sprite and use it as our overlay
	for(var/external_layer in bodypart_overlay.all_layers)
		if(bodypart_overlay.layers & external_layer)
			. += bodypart_overlay.get_overlay(external_layer, ownerlimb)

/// Initializes visual elements of a limb
/obj/item/organ/proc/initialize_visuals(accessory_type)
	if(restyle_flags)
		RegisterSignal(src, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle))

	accessory_type = accessory_type ? accessory_type : sprite_accessory_override
	var/update_appearance = TRUE
	if(accessory_type)
		bodypart_overlay.set_appearance(accessory_type)
		bodypart_overlay.imprint_on_next_insertion = FALSE
	else if(loc) //we've been spawned into the world, and not in nullspace to be added to a limb (yes its fucking scuffed)
		bodypart_overlay.randomize_appearance()
	else
		update_appearance = FALSE

	if(update_appearance && use_mob_sprite_as_obj_sprite)
		update_appearance()

/// Update our features after something changed our appearance (if we have an attached DNA block)
/obj/item/organ/proc/mutate_feature(features, mob/living/carbon/human/human)
	if(!dna_block)
		return

	var/list/feature_list = bodypart_overlay.get_global_feature_list()
	bodypart_overlay.set_appearance_from_name(feature_list[deconstruct_block(get_uni_feature_block(features, dna_block), feature_list.len)])

/**
 * If you need to change an external_organ for simple one-offs, use this.
 * Pass the accessory type : /datum/accessory/something
 */
/obj/item/organ/external/proc/simple_change_sprite(accessory_type)
	var/datum/sprite_accessory/typed_accessory = accessory_type //we only take types for maintainability

	bodypart_overlay.set_appearance(typed_accessory)

	if(owner) //are we in a person?
		owner.update_body_parts()
	else if(ownerlimb) //are we in a limb?
		ownerlimb.update_icon_dropped()
	else if(use_mob_sprite_as_obj_sprite) //are we out in the world, unprotected by flesh?
		update_appearance()
