/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Podperson"
	plural_form = "Podpeople"
	id = SPECIES_PODPERSON
	species_traits = list(MUTCOLORS, EYECOLOR, HAS_FLESH, HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_PLANT_SAFE,
	)
	external_organs = list(
		/obj/item/organ/external/pod_hair = "None",
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	inherent_factions = list("plants", "vines")
	attack_verb = "slash"
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	payday_modifier = 0.75
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water
	disliked_food = MEAT | DAIRY | SEAFOOD | BUGS
	liked_food = VEGETABLES | FRUIT | GRAIN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/pod,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/pod,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pod,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/pod,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/pod,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pod,
	)

	ass_image = 'icons/ass/asspodperson.png'

/datum/species/pod/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.stat == DEAD)
		return

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.adjust_nutrition(5 * light_amount * delta_time)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(0.5 * delta_time, 0.5 * delta_time, 0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-0.5 * delta_time)
			H.adjustOxyLoss(-0.5 * delta_time)

	if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL) //don't make podpeople fat because they stood in the sun for too long
		H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(1 * delta_time, 0)
	..()

/datum/species/pod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE

/datum/species/pod/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	var/hairstyle = pick(GLOB.pod_hair_list)
	human_mob.dna.features["pod_hair"] = hairstyle
	mutant_bodyparts["pod_hair"] = hairstyle
	human_mob.update_body()

/datum/species/pod/proc/change_hairstyle(mob/living/carbon/human/human_mob, new_style)
	var/obj/item/organ/external/organ = human_mob.getorganslot(ORGAN_SLOT_EXTERNAL_POD_HAIR)
	organ.set_sprite(new_style)
	human_mob.update_body_parts()
