/mob/living/carbon/human/species/insectoid
	race = /datum/species/insectoid

/datum/species/insectoid
	name = "\improper Insectoid"
	plural_form = "Insectoid"
	id = SPECIES_INSECTOID
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "Insectoid Pattern")
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	exotic_blood = /datum/reagent/blood/green
	exotic_bloodtype = "I*"

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/insectoid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/insectoid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/insectoid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/insectoid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/insectoid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/insectoid,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/insectoid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/insectoid,
	)


/datum/species/insectoid/get_species_description()
	return "Nothing yet."

/datum/species/insectoid/get_species_lore()
	return list(
		"Nothing yet.",
	)
