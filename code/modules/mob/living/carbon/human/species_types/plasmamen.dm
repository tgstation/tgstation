/datum/species/plasmaman
	name = "\improper Plasmaman"
	plural_form = "Plasmamen"
	id = SPECIES_PLASMAMAN
	sexes = FALSE
	meat = /obj/item/stack/sheet/mineral/plasma
	// plasmemes get hard to wound since they only need a severe bone wound to dismember, but unlike skellies, they can't pop their bones back into place
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_HARDLY_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_UNHUSKABLE,
	)

	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	inherent_respiration_type = RESPIRATION_PLASMA
	mutantlungs = /obj/item/organ/lungs/plasmaman
	smoker_lungs = /obj/item/organ/lungs/plasmaman/plasmaman_smoker
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/bone/plasmaman
	mutantstomach = /obj/item/organ/stomach/bone/plasmaman
	mutantappendix = null
	mutantheart = null
	heatmod = 1.5
	payday_modifier = 1.0
	breathid = GAS_PLASMA
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	species_cookie = /obj/item/reagent_containers/condiment/milk
	outfit_important_for_life = /datum/outfit/plasmaman
	species_language_holder = /datum/language_holder/skeleton

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/plasmaman,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/plasmaman,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/plasmaman,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/plasmaman,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/plasmaman,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/plasmaman,
	)

	// Body temperature for Plasmen is much lower human as they can handle colder environments
	bodytemp_normal = (BODYTEMP_NORMAL - 40)
	// The minimum amount they stabilize per tick is reduced making hot areas harder to deal with
	bodytemp_autorecovery_min = 2
	// They are hurt at hot temps faster as it is harder to hold their form
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 20) // about 40C
	// This effects how fast body temp stabilizes, also if cold resit is lost on the mob
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 50) // about -50c

	outfit_override_registry = list(
		/datum/outfit/syndicate = /datum/outfit/syndicate/plasmaman,
		/datum/outfit/syndicate/full = /datum/outfit/syndicate/full/plasmaman,
		/datum/outfit/syndicate/leader = /datum/outfit/syndicate/leader/plasmaman,
		/datum/outfit/syndicate/reinforcement = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/cybersun = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/donk = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/gorlex = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/interdyne = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/mi13 = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/waffle = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/support = /datum/outfit/syndicate/support/plasmaman,
		/datum/outfit/syndicate/full/loneop = /datum/outfit/syndicate/full/plasmaman/loneop,
	)

	/// If the bones themselves are burning clothes won't help you much
	var/internal_fire = FALSE

/datum/species/plasmaman/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	if(job?.plasmaman_outfit)
		equipping.equipOutfit(job.plasmaman_outfit, visuals_only)
	else
		give_important_for_life(equipping)

/datum/species/plasmaman/get_scream_sound(mob/living/carbon/human)
	return pick(
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_1.ogg',
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_2.ogg',
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_3.ogg',
	)

/datum/species/plasmaman/get_physical_attributes()
	return "Plasmamen literally breathe and live plasma. They spontaneously combust on contact with oxygen, and besides all the quirks that go with that, \
		they're very vulnerable to all kinds of physical damage due to their brittle structure."

/datum/species/plasmaman/get_species_description()
	return "Found on the Icemoon of Freyja, plasmamen consist of colonial \
		fungal organisms which together form a sentient being. In human space, \
		they're usually attached to skeletons to afford a human touch."

/datum/species/plasmaman/get_species_lore()
	return list(
		"A confusing species, plasmamen are truly \"a fungus among us\". \
		What appears to be a singular being is actually a colony of millions of organisms \
		surrounding a found (or provided) skeletal structure.",

		"Originally discovered by NT when a researcher \
		fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating \
		the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen \
		have been deployed en masse throughout NT to bolster the workforce.",

		"New to the galactic stage, plasmamen are a blank slate. \
		Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. \
		It might be the whole \"flammable purple skeleton\" thing.",

		"The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. \
		Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
	)

/datum/species/plasmaman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Protected",
			SPECIES_PERK_DESC = "Plasmamen are immune to radiation, poisons, and most diseases.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "Wound Resistance",
			SPECIES_PERK_DESC = "Plasmamen have higher tolerance for damage that would wound others.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Healing",
			SPECIES_PERK_DESC = "Plasmamen can heal wounds by consuming plasma.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hard-hat",
			SPECIES_PERK_NAME = "Protective Helmet",
			SPECIES_PERK_DESC = "Plasmamen's helmets provide them shielding from the flashes of welding, as well as an inbuilt flashlight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Living Torch",
			SPECIES_PERK_DESC = "Plasmamen instantly ignite when their body makes contact with oxygen.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Complex Biology",
			SPECIES_PERK_DESC = "Plasmamen take specialized medical knowledge to be \
				treated. Do not expect speedy revival, if you are lucky enough to get \
				one at all.",
		),
	)

	return to_add
