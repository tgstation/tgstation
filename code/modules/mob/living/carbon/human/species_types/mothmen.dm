/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	inherent_traits = list(
		TRAIT_HAS_MARKINGS,
		TRAIT_TACKLING_WINGED_ATTACKER,
		TRAIT_ANTENNAE,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list("moth_markings" = "None")
	external_organs = list(/obj/item/organ/external/wings/moth = "Plain", /obj/item/organ/external/antennae = "Plain")
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanttongue = /obj/item/organ/internal/tongue/moth
	mutanteyes = /obj/item/organ/internal/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	death_sound = 'sound/voice/moth/moth_death.ogg'
	payday_modifier = 1.0
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

/datum/species/moth/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current= TRUE, list/excluded_zones, visual_only)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		handle_mutant_bodyparts(H)

/datum/species/moth/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))

/datum/species/moth/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/species/moth/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 10 // Yes, a 10x damage modifier

/datum/species/moth/randomize_features()
	var/list/features = ..()
	features["moth_markings"] = pick(SSaccessories.moth_markings_list)
	return features

/datum/species/moth/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/voice/moth/scream_moth.ogg'

/datum/species/moth/get_cough_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/voice/human/female_cough1.ogg',
			'sound/voice/human/female_cough2.ogg',
			'sound/voice/human/female_cough3.ogg',
			'sound/voice/human/female_cough4.ogg',
			'sound/voice/human/female_cough5.ogg',
			'sound/voice/human/female_cough6.ogg',
		)
	return pick(
		'sound/voice/human/male_cough1.ogg',
		'sound/voice/human/male_cough2.ogg',
		'sound/voice/human/male_cough3.ogg',
		'sound/voice/human/male_cough4.ogg',
		'sound/voice/human/male_cough5.ogg',
		'sound/voice/human/male_cough6.ogg',
	)


/datum/species/moth/get_cry_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/voice/human/female_cry1.ogg',
			'sound/voice/human/female_cry2.ogg',
		)
	return pick(
		'sound/voice/human/male_cry1.ogg',
		'sound/voice/human/male_cry2.ogg',
		'sound/voice/human/male_cry3.ogg',
	)


/datum/species/moth/get_sneeze_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/voice/human/female_sneeze1.ogg'
	return 'sound/voice/human/male_sneeze1.ogg'


/datum/species/moth/get_laugh_sound(mob/living/carbon/human/moth)
	return 'sound/voice/moth/moth_laugh1.ogg'

/datum/species/moth/get_physical_attributes()
	return "Moths have large and fluffy wings, which help them navigate the station if gravity is offline by pushing the air around them. \
		Due to that, it isn't of much use out in space. Their eyes are very sensitive."

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
