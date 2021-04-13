/datum/species/monkey/kobold
	name = "Kobold"
	id = "kobold"
	say_mod = "shrills"
	mutant_organs = list(/obj/item/organ/tail/lizard/kobold)
	mutant_bodyparts = list("tail_kobold" = "Kobold")
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	knife_butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 5, /obj/item/stack/sheet/animalhide/lizard = 1)
	species_traits = list(MUTCOLORS,HAS_FLESH,HAS_BONE,NO_UNDERWEAR,LIPS,NOEYESPRITES,NOBLOODOVERLAY,NOTRANSSTING, NOAUGMENTS)
	disliked_food = GRAIN | DAIRY | CLOTH
	liked_food = GROSS | MEAT
	limbs_id = "kobold"
	bodypart_overides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm,\
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm,\
		BODY_ZONE_HEAD = /obj/item/bodypart/head,\
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg,\
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg,\
		BODY_ZONE_CHEST = /obj/item/bodypart/chest)
	species_language_holder = /datum/language_holder/kobold

/datum/species/monkey/kobold/random_name(gender,unique,lastname)
	var/randname = "kobold ([rand(1,999)])"
	return randname

/datum/species/monkey/kobold/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	if(!H.dna.features["tail_kobold"] || H.dna.features["tail_kobold"] == "None")
		H.dna.features["tail_kobold"] = "Kobold"
		handle_mutant_bodyparts(H)

/datum/species/monkey/kobold/check_roundstart_eligible()
	return FALSE
