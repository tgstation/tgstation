/datum/species/monkey/kobold
	name = "\improper Kobold"
	id = SPECIES_KOBOLD
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/lizard = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/horns = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/frills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/snout = "Round",
		/obj/item/organ/tail/lizard = "Smooth",
	)
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanteyes = /obj/item/organ/eyes/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	knife_butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 5, /obj/item/stack/sheet/animalhide/lizard = 1)
	inherent_traits = list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
		TRAIT_MUTANT_COLORS,
	)
	coldmod = 1.5
	heatmod = 0.67
	death_sound = 'sound/mobs/humanoids/lizard/deathsound.ogg'
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)
	species_cookie = /obj/item/food/meat/slab
	species_language_holder = /datum/language_holder/kobold
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/kobold,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/kobold,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/kobold,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/kobold,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/kobold,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/kobold,
	)
	exotic_bloodtype = "L"
	payday_modifier = 1.35

/datum/species/monkey/kobold/get_scream_sound(mob/living/carbon/human/kobold)
	return pick(
		'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_2.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_3.ogg',
	)

/datum/species/monkey/kobold/get_hiss_sound(mob/living/carbon/human/kobold)
	return 'sound/mobs/humanoids/lizard/lizard_hiss.ogg'

/datum/species/monkey/kobold/get_physical_attributes()
	return "Kobolds are functionally identical to monkeys, but with the downsides of lizards."

/datum/species/monkey/kobold/get_species_description()
	return "Kobolds are diminutive, reptilian creatures as related to Lizardpeople as monkeys are to humans."

/datum/species/monkey/get_species_lore()
	return list(
		"Please, gently the kobolds.",
	)

/datum/species/monkey/kobold/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Kobolds have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/datum/species/monkey/kobold/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Kobolds can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Simple Squamate",
			SPECIES_PERK_DESC = "Kobolds are primitive humanoids, and can't do most things a humanoid can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Kobolds are reverted into normal lizardpeople upon being exposed to Mutadone.",
		),
	)

	return to_add
