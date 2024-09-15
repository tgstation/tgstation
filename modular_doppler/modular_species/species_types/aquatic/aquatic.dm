/mob/living/carbon/human/species/aquatic
	race = /datum/species/aquatic

/datum/species/aquatic
	name = "\improper Aquatic"
	plural_form = "Aquatic"
	id = SPECIES_AQUATIC
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "Aquatic Pattern")
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/aquatic,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/aquatic,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/aquatic,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/aquatic,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/aquatic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/aquatic,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/aquatic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/aquatic,
	)


/datum/species/aquatic/get_species_description()
	return "Nothing yet."

/datum/species/aquatic/get_species_lore()
	return list(
		"Nothing yet.",
	)
