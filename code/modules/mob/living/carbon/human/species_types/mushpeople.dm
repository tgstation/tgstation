/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	plural_form = "Mushroompeople"
	id = SPECIES_MUSHROOM
	mutant_bodyparts = list("caps" = "Round")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	fixed_mut_color = "#DBBF92"
	hair_color = "#FF4B19" //cap color, spot color uses eye color

	species_traits = list(
		MUTCOLORS,
		NOEYESPRITES,
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_NOFLASH,
	)
	inherent_factions = list(FACTION_MUSHROOM)
	speedmod = 1.5 //faster than golems but not by much

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING

	burnmod = 1.25
	heatmod = 1.5

	mutanttongue = /obj/item/organ/internal/tongue/mush
	mutanteyes = /obj/item/organ/internal/eyes/night_vision/mushroom
	mutantlungs = null
	use_skintones = FALSE
	var/datum/martial_art/mushpunch/mush
	species_language_holder = /datum/language_holder/mushroom

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mushroom,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mushroom,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mushroom,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mushroom,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mushroom,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mushroom,
	)

/datum/species/mush/check_roundstart_eligible()
	return FALSE //hard locked out of roundstart on the order of design lead kor, this can be removed in the future when planetstation is here OR SOMETHING but right now we have a problem with races.

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["caps"])
			H.dna.features["caps"] = "Round"
			handle_mutant_bodyparts(H)
		mush = new(null)
		mush.teach(H)

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	mush.remove(C)
	QDEL_NULL(mush)

/datum/species/mush/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone/weedkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE

/datum/species/mush/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	forced_colour = FALSE
	..()
