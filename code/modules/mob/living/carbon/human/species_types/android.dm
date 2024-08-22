/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	species_traits = list(
		NO_DNA_COPY,
		NOTRANSSTING,
		NO_UNDERWEAR,
		NOHUSK,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOFIRE,
		TRAIT_NOHUNGER,
		/* TRAIT_NOMETABOLISM, */ // monkestation edit: making androids closer to IPCs
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_VIRUSIMMUNE,
		TRAIT_REVIVES_BY_HEALING, // monkestation edit: making androids closer to IPCs
	)

	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 10}
	species_gibs = GIB_TYPE_ROBOTIC
	mutantbrain = /obj/item/organ/internal/brain/cybernetic
	mutanttongue = /obj/item/organ/internal/tongue/robot
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	mutantappendix = null
	mutantbladder = null
	mutanteyes = /obj/item/organ/internal/eyes/robotic
	mutantears = /obj/item/organ/internal/ears/cybernetic
	mutantbutt = /obj/item/organ/internal/butt/cyber
	species_language_holder = /datum/language_holder/synthetic
	wing_types = list(/obj/item/organ/external/wings/functional/robotic)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	reagent_tag = PROCESS_SYNTHETIC // They don't HAVE a liver, but if they did, they'd have synthetic chem processing.
	special_step_sounds = list('sound/effects/servostep.ogg')



	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/android,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/android,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/android,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/android,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/android,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/android,
	)
	examine_limb_id = SPECIES_HUMAN


//Taken from TGstation
/datum/species/android/get_species_description()
	return "Androids are an entirely synthetic species."


/// Taken from TGstation.
/datum/species/android/create_pref_traits_perks()
	var/list/to_add = list()

	to_add += list(
	list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_ALT,
		SPECIES_PERK_NAME = "Android Aptitude",
		SPECIES_PERK_DESC = "As a synthetic lifeform, Androids are immune to many forms of damage humans are susceptible to. \
			Fire, cold, heat, pressure, radiation, and toxins are all ineffective against them. \
			They also can't overdose on drugs, don't need to breathe or eat, can't catch on fire, and are immune to being pierced.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_COGS,
		SPECIES_PERK_NAME = "Modular Lifeform",
		SPECIES_PERK_DESC = "Android limbs are modular, allowing them to easily reattach severed bodyparts.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DNA,
		SPECIES_PERK_NAME = "Not Human After All",
		SPECIES_PERK_DESC = "There is no humanity behind the eyes of the Android, and as such, they have no DNA to genetically alter.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_HEART,
		SPECIES_PERK_NAME = "Some Components Optional",
		SPECIES_PERK_DESC = "Androids have very few internal organs. While they can survive without many of them, \
			they don't have any benefits from them either.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_ROBOT,
		SPECIES_PERK_NAME = "Synthetic",
		SPECIES_PERK_DESC = "Being synthetic, Androids are vulnernable to EMPs.",
	),
	)
	return to_add

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	// Androids don't eat, hunger or metabolise foods. Let's do some cleanup.
	C.set_safe_hunger_level()
