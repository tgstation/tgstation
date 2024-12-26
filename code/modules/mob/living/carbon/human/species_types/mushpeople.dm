/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	plural_form = "Mushroompeople"
	id = SPECIES_MUSHROOM
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	fixed_mut_color = "#DBBF92"

	mutant_organs = list(/obj/item/organ/mushroom_cap = "Round")

	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NOBREATH,
		TRAIT_NOFLASH,
		TRAIT_NO_UNDERWEAR,
	)
	inherent_factions = list(FACTION_MUSHROOM)

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING

	heatmod = 1.5

	mutanttongue = /obj/item/organ/tongue/mush
	mutanteyes = /obj/item/organ/eyes/night_vision/mushroom
	mutantlungs = null
	species_language_holder = /datum/language_holder/mushroom

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mushroom,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mushroom,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mushroom,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mushroom,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mushroom,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mushroom,
	)
	var/datum/martial_art/mushpunch/mush

/datum/species/mush/check_roundstart_eligible()
	return FALSE //hard locked out of roundstart on the order of design lead kor, this can be removed in the future when planetstation is here OR SOMETHING but right now we have a problem with races.

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(ishuman(C))
		mush = new()
		mush.teach(C)
		mush.allow_temp_override = FALSE

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	mush.fully_remove(C)
	QDEL_NULL(mush)

/datum/species/mush/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(chem.type == /datum/reagent/toxin/plantbgone/weedkiller)
		affected.adjustToxLoss(3 * REM * seconds_per_tick)

/datum/species/mush/get_fixed_hair_color(mob/living/carbon/human/for_mob)
	return "#FF4B19" //cap color, spot color uses eye color

/// A mushpersons mushroom cap organ
/obj/item/organ/mushroom_cap
	name = "mushroom cap"
	desc = "These are yummie, no cap."

	use_mob_sprite_as_obj_sprite = TRUE

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_POD_HAIR

	preference = "feature_mushperson_cap"

	dna_block = DNA_MUSHROOM_CAPS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_PLANT

	bodypart_overlay = /datum/bodypart_overlay/mutant/mushroom_cap

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/// Bodypart overlay for the mushroom cap organ
/datum/bodypart_overlay/mutant/mushroom_cap
	layers = EXTERNAL_ADJACENT
	feature_key = "caps"
	dyable = TRUE

/datum/bodypart_overlay/mutant/mushroom_cap/get_global_feature_list()
	return SSaccessories.caps_list

/datum/bodypart_overlay/mutant/mushroom_cap/can_draw_on_bodypart(mob/living/carbon/human/human)
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE

/datum/bodypart_overlay/mutant/mushroom_cap/override_color(obj/item/bodypart/bodypart_owner)
	//The mushroom cap is red by default (can still be dyed)
	return "#FF4B19"
