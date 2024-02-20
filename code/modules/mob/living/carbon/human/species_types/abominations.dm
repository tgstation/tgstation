/// These won't appear normally in games, they are meant to for debuging the adjustment of limbs based on the height of a humans bodyparts.
/datum/species/monkey/human_legged
	name = "human-legged monkey"
	id = SPECIES_MONKEY_HUMAN_LEGGED
	examine_limb_id = SPECIES_MONKEY
	changesource_flags = MIRROR_BADMIN
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)

/mob/living/carbon/human/species/monkey/humand_legged
	race = /datum/species/monkey/human_legged
