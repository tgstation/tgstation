/// These won't appear normally in games, they are meant to for debuging the adjustment of limbs based on the height of a humans bodyparts.
/datum/species/human/tallboy
	name = "\improper Tall Boy"
	id = SPECIES_TALLBOY
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/tallboy,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/tallboy,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)

/datum/species/monkey/human_legged
	id = SPECIES_MONKEY_HUMAN_LEGGED
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)

/datum/species/monkey/monkey_freak
	id = SPECIES_MONKEY_FREAK
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)

/mob/living/carbon/human/species/monkey/humand_legged
	race = /datum/species/monkey/human_legged

/mob/living/carbon/human/species/monkey/monkey_freak
	race = /datum/species/monkey/monkey_freak

/mob/living/carbon/human/species/tallboy
	race = /datum/species/human/tallboy
