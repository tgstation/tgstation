/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/lungs/ethereal
	smoker_lungs = /obj/item/organ/lungs/ethereal/ethereal_smoker
	mutantstomach = /obj/item/organ/stomach/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	exotic_bloodtype = BLOOD_TYPE_ETHEREAL
	siemens_coeff = 0.5 //They thrive on energy
	payday_modifier = 1.0
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS, // Has a separate pref for mutant color
		TRAIT_AGENDER,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/energybar
	species_language_holder = /datum/language_holder/ethereal
	sexes = FALSE //no fetish content allowed
	// Body temperature for ethereals is much higher than humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color_mode = USE_MUTANT_COLOR
	hair_alpha = 140
	facial_hair_alpha = 140

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

/datum/species/ethereal/on_species_gain(mob/living/carbon/human/new_ethereal, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	var/obj/item/organ/heart/ethereal/ethereal_heart = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	ethereal_heart.set_ethereal_color(new_ethereal.dna.features[FEATURE_MUTANT_COLOR])
	// Trigger a refresh as lazy attached limbs do not cause those
	var/datum/status_effect/grouped/bodypart_effect/ethereal_glow/glow_status = new_ethereal.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow)
	if (!isnull(glow_status))
		glow_status.refresh_light_color()

/datum/species/ethereal/randomize_features()
	var/list/features = ..()
	features[FEATURE_MUTANT_COLOR] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	return features

/datum/species/ethereal/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = GLOB.color_list_ethereal["Green"]

/datum/species/ethereal/get_features()
	var/list/features = ..()
	features += "feature_ethcolor"
	return features

/datum/species/ethereal/get_physical_attributes()
	return "Ethereals process electricity as their power supply, not food, and are somewhat resistant to it.\
		They do so via their crystal core, their equivalent of a human heart, which will also encase them in a reviving crystal if they die.\
		However, their skin is very thin and easy to pierce with brute weaponry."

/datum/species/ethereal/get_species_description()
	return "Coming from the planet of Sprout, the theocratic ethereals are \
		separated socially by caste, and espouse a dogma of aiding the weak and \
		downtrodden."

/datum/species/ethereal/get_species_lore()
	return list(
		"Ethereals are a species native to the planet Sprout. \
		When they were originally discovered, they were at a medieval level of technological progression, \
		but due to their natural acclimation with electricity, they felt easy among the large Nanotrasen installations.",
	)

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "Ethereals can feed on electricity from APCs, and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "gem",
			SPECIES_PERK_NAME = "Crystal Core",
			SPECIES_PERK_DESC = "The Ethereal's heart will encase them in crystal should they die, returning them to life after a time - \
				at the cost of a permanent brain trauma.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Elemental Attacker",
			SPECIES_PERK_DESC = "Ethereals deal burn damage with their punches instead of brute.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
	)

	return to_add

/datum/species/ethereal/lustrous //Ethereal pirates with an inherent bluespace prophet trauma.
	name = "Lustrous"
	id = SPECIES_ETHEREAL_LUSTROUS
	examine_limb_id = SPECIES_ETHEREAL
	mutantbrain = /obj/item/organ/brain/lustrous
	mutanttongue = /obj/item/organ/tongue/ethereal/lustrous
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_AGENDER,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal/lustrous,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

/datum/species/ethereal/lustrous/get_physical_attributes()
	return "Lustrous are what remains of an Ethereal after freebasing esoteric drugs. \
		They are pressure immune, virus immune, can see bluespace tears in reality, and have a really weird scream. They remain vulnerable to physical damage."

/datum/species/ethereal/lustrous/randomize_features()
	var/list/features = ..()
	features[FEATURE_MUTANT_COLOR] = GLOB.color_list_lustrous[pick(GLOB.color_list_lustrous)]
	return features
