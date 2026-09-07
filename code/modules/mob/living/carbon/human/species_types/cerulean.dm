/datum/species/human/cerulean
	name = "\improper Cerulean"
	id = SPECIES_CERULEAN
	mutant_organs = list(/obj/item/organ/tail/fish/cerulean = /datum/sprite_accessory/tails/fish/cerulean::name)
	mutanttongue = /obj/item/organ/tongue/fish
	mutantstomach = /obj/item/organ/stomach/fish
	mutantliver = /obj/item/organ/liver/fish
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)

	species_cookie = /obj/item/food/chips/shrimp
	inert_mutation = /datum/mutation/echolocation
	payday_modifier = 0.9
	family_heirlooms = list(
		/obj/item/ammo_casing/harpoon,
		/obj/item/toy/seashell,
	)

/datum/species/human/cerulean/get_physical_attributes()
	return "An unremarkable species."

/datum/species/human/cerulean/get_species_description()
	return "Nothing yet."

/datum/species/human/cerulean/get_species_lore()
	return list(
		"Nothing yet.",
	)

/datum/species/human/cerulean/prepare_human_for_preview(mob/living/carbon/human/preview_human)
	preview_human.set_haircolor("#a54ea1", update = FALSE)
	preview_human.set_hairstyle(/datum/sprite_accessory/hair/countryponytail::name, update = TRUE)
	preview_human.dna.features[TRAIT_USES_SKINTONES] = "asian1"
	preview_human.dna.features[FEATURE_TAIL_FISH_COLOR] = COLOR_CARP_TEAL
	preview_human.dna.features[FEATURE_FRILLS] = /datum/sprite_accessory/frills/aquatic::name
	preview_human.dna.species.mutant_organs[/obj/item/organ/frills] = /datum/sprite_accessory/frills/aquatic::name
	regenerate_organs(preview_human, excluded_zones = GLOB.leg_zones)

/datum/species/human/cerulean/get_features()
	var/list/features = ..()
	LAZYOR(features, /datum/preference/choiced/cerulean_lungs::savefile_key)
	LAZYOR(features, /datum/preference/toggle/cerulean_frills::savefile_key)
	LAZYOR(features, /datum/preference/color/fish_tail_color::savefile_key)
	return features

/datum/species/human/cerulean/randomize_features()
	var/list/features = ..()
	LAZYSET(features, FEATURE_TAIL_FISH_COLOR, pick(GLOB.carp_colors - COLOR_CARP_SILVER))
	return features

/datum/species/human/cerulean/on_species_gain(mob/living/carbon/human/cerulean, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (isdummy(cerulean))
		cerulean.visual_only_organs = FALSE //sorry but we need them all for the organ set bonus
		return
	if (cerulean.has_gravity())
		cerulean.set_resting(TRUE, silent = TRUE, instant = TRUE)
	//apply a free wet stack to prevent the choking screen alert to appear for a second on mob creation
	cerulean.apply_status_effect(/datum/status_effect/fire_handler/wet_stacks, 1, FALSE)

/// good guy nanotrasen provides a wheelchair to their employees
/datum/species/human/cerulean/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	if (!istype(job))
		return
	cerulean.put_in_wheelchair()

/// gives a 'necessary for life' device to Ceruleans with gills
/datum/species/human/cerulean/post_equip_species_outfit(mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	var/obj/item/organ/lungs/lungs = cerulean.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (/datum/gas/oxygen in lungs?.breathe_always)
		return
	// try to attach to uniform
	var/obj/item/clothing/under/uniform = cerulean.w_uniform
	var/attached = uniform?.attach_accessory(SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean))
	if (attached)
		return
	// try anything else
	cerulean.equip_in_one_of_slots(
		equipping = SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean),
		slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_HANDS, LOCATION_BACKPACK),
		qdel_on_fail = FALSE,
		indirect_action = TRUE,
	)

/*
 * the main driver of the species and the source of the strongest species perks
 * allowing free movement in any atmosphere if zero g
 */
/obj/item/organ/tail/fish/cerulean
	name = "oversized fish tail"
	desc = "A hugely sized and scaled fish tail, clearly severed from something much larger than a mere space carp."
	external_bodyshapes = BODYSHAPE_CERULEAN
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean
	w_class = WEIGHT_CLASS_BULKY
	fillet_amount = 12
	organ_traits = list(
		TRAIT_FREE_FLOAT_MOVEMENT,
		TRAIT_FLOPPING,
		TRAIT_SWIMMER,
		TRAIT_BLOCK_ATTACHING_LEGS,
	)

/obj/item/organ/tail/fish/cerulean/on_mob_insert(mob/living/carbon/owner, special)
	. = ..()
	get_your_sealegs(owner, special)

/obj/item/organ/tail/fish/cerulean/on_mob_remove(mob/living/carbon/owner, special)
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	if(special)
		return
	var/limb_name = "\improper [bodypart_owner.name]"
	var/tail_name = "\improper [name]"
	owner.apply_damage(rand(35, 45), def_zone = BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	if(!HAS_TRAIT(owner, TRAIT_ANALGESIA))
		owner.emote("scream") //owowowowowow
		owner.set_jitter_if_lower(1 SECONDS)
		shake_camera(owner, 1 SECONDS, 2)
		to_chat(owner, span_userdanger("You wince and scream as your [tail_name] is grotesquely torn from your [limb_name]!"))
	if(!splatter_check(owner))
		// if you have no blood or are missing half of it, its a clean cut
		return
	owner.blood_volume -= (owner.blood_volume / 3)
	owner.add_splatter_floor(get_turf(src))
	owner.spray_blood(REVERSE_DIR(owner.dir), 2)
	owner.visible_message(span_danger("[src] detaches from [owner]'s [limb_name], spilling out liters of [LOWER_TEXT(owner.get_bloodtype()?.get_blood_name())]!"))
	REMOVE_TRAIT(src, TRAIT_NODROP, ORGAN_INSIDE_BODY_TRAIT) //do this early so we can fling it
	throw_at(get_edge_target_turf(owner, REVERSE_DIR(owner.dir))) //ok so it doesnt actually fling it it just spins but idk hwo to fling
	playsound(src, 'sound/effects/cartoon_sfx/cartoon_splat.ogg', rand(50, 75), TRUE)

/obj/item/organ/tail/fish/cerulean/on_surgical_removal(mob/living/user, obj/item/bodypart/limb, obj/item/tool)
	. = ..()
	if(!splatter_check(limb.owner))
		return
	shake_camera(user, 1 SECONDS, 2) //you shake too hehe
	user.set_jitter_if_lower(1 SECONDS)

// limit restyle to our tail's unique pool
/obj/item/organ/tail/fish/cerulean/get_valid_restyles()
	return bodypart_overlay.get_global_feature_list()

/// check if we have (enough) blood for an (un)clean cut
/obj/item/organ/tail/fish/cerulean/proc/splatter_check(mob/living/carbon/owner)
	if(isnull(owner))
		return FALSE
	return (owner.blood_volume && !HAS_TRAIT(owner, TRAIT_NOBLOOD) && owner.blood_volume >= (owner.default_blood_volume / 2))

/// if legs are present remove them silently if special = true, not so silently else
/obj/item/organ/tail/fish/cerulean/proc/get_your_sealegs(mob/living/carbon/owner, special)
	var/obj/item/bodypart/right_leg = owner.get_bodypart(BODY_ZONE_R_LEG)
	var/obj/item/bodypart/left_leg = owner.get_bodypart(BODY_ZONE_L_LEG)
	if(special || HAS_TRAIT(owner, TRAIT_GODMODE) || HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		right_leg?.drop_limb(TRUE, FALSE, FALSE)
		left_leg?.drop_limb(TRUE, FALSE, FALSE)
		var/obj/item/clothing/shoesprobably = owner.get_item_by_slot(ITEM_SLOT_FEET)
		if(!isnull(shoesprobably))
			owner.dropItemToGround(shoesprobably, force = TRUE)
		return
	right_leg?.dismember()
	left_leg?.dismember()

/// the bodypart overlay for cerulean fish tails!
/datum/bodypart_overlay/mutant/tail/fish/cerulean
	layers = list(
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)

/datum/bodypart_overlay/mutant/tail/fish/cerulean/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

// simpler than parent. we don't care about locked/natural_spawn. all the accessories in our pool are locked
/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_random_appearance()
	return fetch_sprite_datum_from_name(pick(get_global_feature_list()))

// make our own little feature list by copying the global and removing the normal fish tails
/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_global_feature_list()
	var/static/list/glob_feature_list = list()
	if(!length(glob_feature_list))
		glob_feature_list = SSaccessories.feature_list[feature_key]
	var/list/feature_list = glob_feature_list.Copy()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(!istype(accessory_datum, /datum/sprite_accessory/tails/fish/cerulean))
			feature_list -= accessory
	return feature_list

/*
 * same as parent, but with a pretty skeleton texture
 */
/obj/item/organ/tail/fish/cerulean/abyssal
	name = "skeletal oversized fish tail"
	desc = "A hugely sized and scaled fish tail, it is partially translucent and shows the skeleton inside."
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal
	var/abyssal_tweak = /datum/bodypart_texture/abyssal_cerulean

// an additional overlay to be added to the image stack. used by abyssal cerulean's skeleton
/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	var/list/created_overlays = ..()
	created_overlays += mutable_appearance(sprite_datum.icon, "abyssal_skeleton", offset_spokesman = limb, alpha = 105, layer = layer_real)
	created_overlays += emissive_appearance(sprite_datum.icon, "abyssal_skeleton", offset_spokesman = limb, alpha = 35, layer = layer_real)
	return created_overlays

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/added_to_limb(obj/item/bodypart/limb)
	limb.add_bodypart_texture(abyssal_tweak, FALSE)

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/removed_from_limb(obj/item/bodypart/limb)
	limb.remove_bodypart_texture(abyssal_tweak, FALSE)

/datum/bodypart_texture/abyssal_cerulean/modify_bodypart_appearance(image/appearance)
	var/icon/new_appearance = new(appearance.icon)
	new_appearance.Blend(icon(/datum/sprite_accessory/tails/fish/cerulean::icon, "abyssal_mask"), ICON_SUBTRACT)
	appearance.icon = new_appearance

/datum/bodypart_texture/abyssal_cerulean/can_texture_bodypart(obj/item/bodypart/bodypart_owner)
	return TRUE

/*
 *
 */
/obj/item/organ/tail/fish/cerulean/ephemeral
	var/datum/weakref/owner_ref
	var/alist/ephemeral_limbs = alist(
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/obj/item/organ/tail/fish/cerulean/ephemeral/on_mob_insert(mob/living/carbon/owner, special)
	. = ..()
	if(special || !owner)
		return
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_IS_WET), SIGNAL_REMOVETRAIT(TRAIT_IS_WET)), PROC_REF(toggle_legs))

/obj/item/organ/tail/fish/cerulean/ephemeral/on_mob_remove(mob/living/carbon/owner, special)
	. = ..()
	if(special || !owner)
		return
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_IS_WET),	SIGNAL_REMOVETRAIT(TRAIT_IS_WET)))

/obj/item/organ/tail/fish/cerulean/ephemeral/bodypart_insert(obj/item/bodypart/bodypart, mob/living/carbon/limb_owner, movement_flags)
	if(!isnull(owner_ref) && limb_owner == owner_ref.resolve())
		return ..()
	else
		..()
		set_up(bodypart, limb_owner)
		owner_ref = WEAKREF(limb_owner)

/obj/item/organ/tail/fish/cerulean/ephemeral/proc/set_up(obj/item/bodypart/bodypart, mob/living/carbon/limb_owner)

	var/list/missing_limbs = limb_owner.get_missing_limbs()
	for(var/obj/item/bodypart/missing_limb in missing_limbs)
		if(!(missing_limb.body_zone in GLOB.leg_zones))
			continue
		ephemeral_limbs[missing_limb.body_zone] = new missing_limb

	for(var/zone in ephemeral_limbs)
		if(isnull(ephemeral_limbs[zone]))
			var/obj/item/bodypart/leg/new_leg
			var/is_digi_species = limb_owner.dna.species.digitigrade_customization
			switch(zone)
				if(BODY_ZONE_L_LEG)
					if(limb_owner.dna.species.bodypart_overrides[BODY_ZONE_L_LEG])
						if(is_digi_species && limb_owner.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)
							new_leg = /obj/item/bodypart/leg/left/digitigrade
						else
							new_leg = limb_owner.dna?.species?.bodypart_overrides[BODY_ZONE_L_LEG]
					else
						new_leg = /obj/item/bodypart/leg/left

				if(BODY_ZONE_R_LEG)
					if(limb_owner.dna.species.bodypart_overrides[BODY_ZONE_R_LEG])
						if(is_digi_species && limb_owner.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)
							new_leg = /obj/item/bodypart/leg/right/digitigrade
						else
							new_leg = limb_owner.dna?.species?.bodypart_overrides[BODY_ZONE_R_LEG]
					else
						new_leg = /obj/item/bodypart/leg/right

			limb_owner.dna.species.bodypart_overrides[zone] = new_leg.type
			ephemeral_limbs[zone] = new new_leg

	Remove(limb_owner, TRUE)

	for(var/zone in ephemeral_limbs)
		var/obj/item/bodypart/leg/ephemeral_limb = ephemeral_limbs[zone]
		if(ephemeral_limb.try_attach_limb(limb_owner, TRUE))
			ephemeral_limb.update_draw_color()
			ephemeral_limb.update_limb(FALSE, TRUE)
			ephemeral_limbs -= ephemeral_limb

	limb_owner.set_resting(FALSE, silent = TRUE, instant = TRUE)

/obj/item/organ/tail/fish/cerulean/ephemeral/proc/toggle_legs(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	//load tail if wet
	if(!loc && HAS_TRAIT(source, TRAIT_IS_WET))
		source.dna.species.bodypart_overrides = GLOB.species_prototypes[source.dna.species.type].bodypart_overrides
		for(var/zone in ephemeral_limbs)
			var/obj/item/bodypart/ephemeral_limb = source.get_bodypart(zone)
			if(isnull(ephemeral_limb))
				continue
			ephemeral_limb.drop_limb(TRUE, FALSE, FALSE)
			ephemeral_limb.moveToNullspace()
			ephemeral_limbs[zone] = ephemeral_limb
		Insert(source, TRUE)
		var/obj/item/bodypart/chest/tail_holder = source.get_bodypart(BODY_ZONE_CHEST)
		if(!isnull(tail_holder) && source.wear_suit?.supports_variations_flags & CERULEAN_VARIATIONS)
			tail_holder.remove_bodypart_texture(/datum/bodypart_texture/mesh)
	//load legs if dry
	else if(istype(loc, /obj/item/bodypart/chest))
		source.dna.species.bodypart_overrides[BODY_ZONE_L_LEG] = ephemeral_limbs[BODY_ZONE_L_LEG].type
		source.dna.species.bodypart_overrides[BODY_ZONE_R_LEG] = ephemeral_limbs[BODY_ZONE_R_LEG].type
		Remove(owner, TRUE)
		for(var/zone in ephemeral_limbs)
			var/obj/item/bodypart/ephemeral_limb = ephemeral_limbs[zone]
			if(ephemeral_limb.try_attach_limb(source, TRUE))
				ephemeral_limb.update_draw_color()
				ephemeral_limb.update_limb(FALSE, TRUE)
				ephemeral_limbs -= ephemeral_limb
	//regen clothing icons
	source.regenerate_icons()
