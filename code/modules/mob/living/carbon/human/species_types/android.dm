/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	say_mod = "states"
	species_traits = list(NOBLOOD, NO_DNA_COPY, NOTRANSSTING)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_NOMETABOLISM,
		TRAIT_TOXIMMUNE,
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NOHUNGER,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOCLONELOSS,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	damage_overlay_type = "synth"
	mutanttongue = /obj/item/organ/tongue/robot
	species_language_holder = /datum/language_holder/synthetic
	wings_icons = list("Robotic")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot,
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/robot,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/robot,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/robot,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/robot
	)
	examine_limb_id = SPECIES_HUMAN

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	// Androids don't eat, hunger or metabolise foods. Let's do some cleanup.
	C.set_safe_hunger_level()

/datum/species/human/krokodil_addict/replace_body(mob/living/carbon/C, datum/species/new_species)
	..()
	var/skintone
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		skintone = H.skin_tone

	for(var/obj/item/bodypart/BP as anything in C.bodyparts)
		if(BP.body_zone == BODY_ZONE_HEAD || BP.body_zone == BODY_ZONE_CHEST)
			BP.is_dimorphic = TRUE
		BP.skin_tone ||= skintone
		BP.limb_id = SPECIES_HUMAN
		BP.should_draw_greyscale = TRUE
		BP.name = "human [parse_zone(BP.body_zone)]"
		BP.update_limb()
		BP.brute_reduction = 5
		BP.burn_reduction = 4
