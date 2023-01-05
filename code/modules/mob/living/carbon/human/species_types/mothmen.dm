/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	species_traits = list(
		LIPS,
		HAS_MARKINGS,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TACKLING_WINGED_ATTACKER,
		TRAIT_ANTENNAE,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list("moth_markings" = "None")
	external_organs = list(/obj/item/organ/external/wings/moth = "Plain", /obj/item/organ/external/antennae = "Plain")
	meat = /obj/item/food/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS | BUGS | GORE
	toxic_food = MEAT | RAW | SEAFOOD
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	wing_types = list(/obj/item/organ/external/wings/functional/moth/megamoth, /obj/item/organ/external/wings/functional/moth/mothra)
	payday_modifier = 0.75
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)
	internal_organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/internal/brain,
		ORGAN_SLOT_EARS = /obj/item/organ/internal/ears,
		ORGAN_SLOT_EYES = /obj/item/organ/internal/eyes/moth,
		ORGAN_SLOT_TONGUE = /obj/item/organ/internal/tongue/moth,
		ORGAN_SLOT_HEART = /obj/item/organ/internal/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs,
		ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach,
		ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/internal/appendix,

		ORGAN_SLOT_BRAIN_ANTIDROP = NO_ORGAN,
		ORGAN_SLOT_BRAIN_ANTISTUN = NO_ORGAN,
		ORGAN_SLOT_HUD = NO_ORGAN,
		ORGAN_SLOT_BREATHING_TUBE = NO_ORGAN,
		ORGAN_SLOT_HEART_AID = NO_ORGAN,
		ORGAN_SLOT_STOMACH_AID = NO_ORGAN,
		ORGAN_SLOT_THRUSTERS = NO_ORGAN,
		ORGAN_SLOT_RIGHT_ARM_AUG = NO_ORGAN,
		ORGAN_SLOT_LEFT_ARM_AUG = NO_ORGAN,

		ORGAN_SLOT_ADAMANTINE_RESONATOR = NO_ORGAN,
		ORGAN_SLOT_VOICE = NO_ORGAN,
		ORGAN_SLOT_MONSTER_CORE = NO_ORGAN,
		ORGAN_SLOT_CHEST_BONUS = NO_ORGAN,
		ORGAN_SLOT_GROIN_BONUS = NO_ORGAN,

		ORGAN_SLOT_ZOMBIE = NO_ORGAN,
		ORGAN_SLOT_PARASITE_EGG = NO_ORGAN,

		ORGAN_SLOT_XENO_HIVENODE = NO_ORGAN,
		ORGAN_SLOT_XENO_ACIDGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_RESINSPINNER = NO_ORGAN,
		ORGAN_SLOT_XENO_PLASMAVESSEL = NO_ORGAN,
		ORGAN_SLOT_XENO_EGGSAC = NO_ORGAN,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 10 //flyswatters deal 10x damage to moths
	return 1


/datum/species/moth/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.dna.features["moth_markings"] = pick(GLOB.moth_markings_list)
	randomize_external_organs(human_mob)

/datum/species/moth/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/voice/moth/scream_moth.ogg'

/datum/species/moth/get_species_description()
	return "Hailing from a planet that was lost long ago, the moths travel \
		the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a new homeland."

/datum/species/moth/get_species_lore()
	return list(
		"Their homeworld lost to the ages, the moths live aboard the Grand Nomad Fleet. \
		Made up of what could be found, bartered, repaired, or stolen the armada is a colossal patchwork \
		built on a history of politely flagging travelers down and taking their things. Occasionally a moth \
		will decide to leave the fleet, usually to strike out for fortunes to send back home.",

		"Nomadic life produces a tight-knit culture, with moths valuing their friends, family, and vessels highly. \
		Moths are gregarious by nature and do best in communal spaces. This has served them well on the galactic stage, \
		maintaining a friendly and personable reputation even in the face of hostile encounters. \
		It seems that the galaxy has come to accept these former pirates.",

		"Surprisingly, living together in a giant fleet hasn't flattened variance in dialect and culture. \
		These differences are welcomed and encouraged within the fleet for the variety that they bring.",
	)

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for temporary nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Bright Lights",
			SPECIES_PERK_DESC = "Moths need an extra layer of flash protection to protect \
				themselves, such as against security officers or when welding. Welding \
				masks will work.",
		),
	)

	return to_add
