/datum/species/saiyan
	name = "\improper Saiyan"
	id = SPECIES_SAIYAN
	mutanteyes = /obj/item/organ/internal/eyes/saiyan
	mutantbrain = /obj/item/organ/internal/brain/saiyan
	mutantheart = /obj/item/organ/internal/heart/saiyan
	mutantstomach = /obj/item/organ/internal/stomach/saiyan
	payday_modifier = 2.0
	inherent_traits = list(
		TRAIT_CATLIKE_GRACE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_USES_SKINTONES,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/clown

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/saiyan,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/saiyan,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/saiyan,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/saiyan,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/saiyan,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/saiyan,
	)
	external_organs = list(
		/obj/item/organ/external/tail/monkey/saiyan = "Monkey",
	)

/datum/species/saiyan/prepare_human_for_preview(mob/living/carbon/human/human)
	human.set_haircolor("#292929", update = FALSE)
	human.set_hairstyle("Spiky 2", update = TRUE)

/datum/species/saiyan/check_roundstart_eligible()
	return TRUE
	// if(check_holidays(APRIL_FOOLS))
	//	return TRUE
	// return ..()

/datum/species/saiyan/get_physical_attributes()
	return "While they appear superficially similar to humans, Saiyans are universally specimens of toned and perfect health with \
		the honed physique of warriors. They can be distinguished from inferior Human stock by their simian tails, and expressive haircuts."

/datum/species/saiyan/get_species_description()
	return "Martially-inclined space warriors who live for battle and carnage. Have a tendency to lose it when exposed to moonlight."

/datum/species/saiyan/get_species_lore()
	return list(
		"Saiyans were once native to the planet Vegeta, which they shared with another species that they annihilated utterly. \
		Saiyans are natural warriors with an instinctive understanding of martial arts and love of violence, \
		their predominant reputation in the galaxy is as conquerors who clear planets of life before selling them to the highest bidder.",
	)

/datum/species/saiyan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Strong",
			SPECIES_PERK_DESC = "Saiyans build muscle quickly and easily, and have a natural understanding of fighting unarmed.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Ki Mastery",
			SPECIES_PERK_DESC = "Mastery of martial arts grants Saiyans many useful abilities such as the ability to fire Ki Blasts, and flight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "first-aid",
			SPECIES_PERK_NAME = "Full Throttle",
			SPECIES_PERK_DESC = "A Saiyan who recovers from grievous injury (but not death) often becomes more powerful.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Going Ape",
			SPECIES_PERK_DESC = "Saiyans uncontrollably revert into the form of powerful giant apes when exposed to moonlight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "warning",
			SPECIES_PERK_NAME = "Achilles' Tail",
			SPECIES_PERK_DESC = "Saiyans are significantly weakened if their tail is harmed or removed.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bowl-rice",
			SPECIES_PERK_NAME = "Warrior's Appetite",
			SPECIES_PERK_DESC = "Maintaining fighting fitness sure makes you awfully hungry.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Melee Fixation",
			SPECIES_PERK_DESC = "Saiyans mostly disavow the use of projectile weaponry on the grounds of honour, although some say it's simply that their big hands mean that they're not very good at using it.",
		),
	)

	return to_add
