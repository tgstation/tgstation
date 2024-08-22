/datum/species/satyr
	name = "\improper Satyr"
	plural_form = "Satyrs"
	id = SPECIES_SATYR
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	no_equip_flags = ITEM_SLOT_FEET
	sexes = TRUE
	species_traits = list(
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_ALCOHOL_TOLERANCE,
		TRAIT_HARD_SOLES
	)
	special_step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	use_skintones = TRUE
	external_organs = list(
		/obj/item/organ/external/satyr_fluff = "normal",
		/obj/item/organ/external/satyr_tail = "short",
		/obj/item/organ/external/satyr_horns = "back",
	)
	meat = /obj/item/food/meat/steak
	liked_food = GROSS | VEGETABLES | FRUIT
	disliked_food = MEAT | DAIRY
	maxhealthmod = 0.8
	stunmod = 1.2
	//speedmod = 1
	payday_modifier = 1
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/satyr,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/satyr,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/satyr,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/satyr,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/satyr,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/satyr,
	)

	var/datum/action/cooldown/mob_cooldown/dash/headbutt/headbutt

/datum/species/satyr/get_species_description()
	return "Mythical goat-people. The clacking of hooves and smell of beer follow them around."

/mob/living/carbon/human/species/satyr
    race = /datum/species/satyr

/datum/species/satyr/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Hooves",
			SPECIES_PERK_DESC = "Cloven feet prevent wearing of shoes, but also protect as a shoe would.",
		)
	)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Extreme Alcohol Tolerance",
			SPECIES_PERK_DESC = "Satyr's are immune to toxin damage done by powerful alcohol.",
		)
	)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Drunk",
			SPECIES_PERK_DESC = "Satyr's require a constant supply of booze to not become drunk.",
		)
	)

	return to_add

/datum/species/satyr/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	ADD_TRAIT(C, TRAIT_TIN_EATER, INNATE_TRAIT)
	C.AddComponent(/datum/component/living_drunk)

	headbutt = new
	headbutt.Grant(C)

/datum/species/satyr/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_TIN_EATER, INNATE_TRAIT)
	var/datum/component/living_drunk/drunk = C.GetComponent(/datum/component/living_drunk)
	qdel(drunk)

	if(headbutt)
		headbutt.Remove(C)
		qdel(headbutt)
