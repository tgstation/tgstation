/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOFIRE,
		TRAIT_NOHUNGER,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_OVERDOSEIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
	)

	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	mutantbrain = /obj/item/organ/internal/brain/cybernetic
	mutanttongue = /obj/item/organ/internal/tongue/robot
	mutantstomach = null
	mutantappendix = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	mutanteyes = /obj/item/organ/internal/eyes/robotic
	mutantears = /obj/item/organ/internal/ears/cybernetic
	species_language_holder = /datum/language_holder/synthetic
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/android,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/android,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/android,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/android,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/android,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/android,
	)

/datum/species/android/get_physical_attributes()
	return "Androids are almost, but not quite, identical to fully augmented humans. \
	Unlike those, though, they're completely immune to toxin damage, don't have blood or organs (besides their head), don't get hungry, and can reattach their limbs! \
	That said, an EMP will devastate them and they cannot process any chemicals."

/datum/species/android/get_species_description()
	return "Androids are an entirely synthetic species."

/datum/species/android/get_species_lore()
	return list(
		"Androids are a synthetic species created by Nanotrasen as an intermediary between humans and cyborgs."
	)

/datum/species/android/create_pref_traits_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_ALT,
		SPECIES_PERK_NAME = "Android Aptitude",
		SPECIES_PERK_DESC = "As a synthetic lifeform, Androids are immune to many forms of damage humans are susceptible to. \
			Fire, cold, heat, pressure, radiation, and toxins are all ineffective against them. \
			They also can't overdose on drugs, don't need to breathe or eat, can't catch on fire, and are immune to being pierced.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_COGS,
		SPECIES_PERK_NAME = "Modular Lifeform",
		SPECIES_PERK_DESC = "Android limbs are modular, allowing them to easily reattach severed bodyparts.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DNA,
		SPECIES_PERK_NAME = "Not Human After All",
		SPECIES_PERK_DESC = "There is no humanity behind the eyes of the Android, and as such, they have no DNA to genetically alter.",
	))
	return perks

/datum/species/android/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_HEART,
		SPECIES_PERK_NAME = "Some Components Optional",
		SPECIES_PERK_DESC = "Androids have very few internal organs. While they can survive without many of them, \
			they don't have any benefits from them either.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_ROBOT,
		SPECIES_PERK_NAME = "Synthetic",
		SPECIES_PERK_DESC = "Being synthetic, Androids are vulnernable to EMPs.",
	))
	return perks
