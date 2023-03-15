/datum/species/simian
	// Highly intelligent, genetically modified chimps
	name = "Simian"
	id = SPECIES_SIMIAN
	bodyflag = FLAG_SIMIAN
	say_mod = "chimpers"
	species_traits = list(SKINTONES,EYECOLOR,LIPS,ALTEYESPRITES,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_VAULTING, TRAIT_KLEPTOMANIAC, TRAIT_MONKEYFRIEND)
	alt_eye = 'monkestation/icons/mob/species/simian/bodyparts.dmi'
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutant_bodyparts = list("tail_monkey")
	mutanttongue = /obj/item/organ/tongue/monkey
	mutanttail = /obj/item/organ/tail/monkey
	default_features = list("tail_monkey" = "Chimp")
	skin_tone_list = "simian"
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	meat = /obj/item/food/meat/slab/monkey
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	disliked_food = GROSS
	liked_food = FRUIT | MEAT
	deathsound = 'monkestation/sound/voice/simian/deathsound.ogg'
	species_language_holder = /datum/language_holder/monkey
	maxhealthmod = 0.85 //small = weak
	staminamod = 0.7
	speedmod = -0.1 //lil bit faster
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,3), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,2), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_RIGHT_HAND = list(0,3), OFFSET_LEFT_HAND = list(0,3)) //im sorry

	species_chest = /obj/item/bodypart/chest/simian
	species_head = /obj/item/bodypart/head/simian
	species_l_arm = /obj/item/bodypart/l_arm/simian
	species_r_arm = /obj/item/bodypart/r_arm/simian
	species_l_leg = /obj/item/bodypart/l_leg/simian
	species_r_leg = /obj/item/bodypart/r_leg/simian

/datum/species/simian/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/species/simian/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_simian_name(gender)

	var/randname = simian_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/simian/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source = null)
	qdel(H.wear_neck)
	var/obj/item/clothing/mask/translator/T = new /obj/item/clothing/mask/translator
	H.equip_to_slot(T, ITEM_SLOT_NECK)




/datum/species/simian/get_custom_icons(var/part)
	switch(part)
		if("uniform")
			return 'monkestation/icons/mob/species/simian/simian_uniforms.dmi'
		if("gloves")
			return 'monkestation/icons/mob/species/simian/simian_gloves.dmi'
		if("glasses")
			return 'monkestation/icons/mob/species/simian/simian_glasses.dmi'
		if("shoes")
			return 'monkestation/icons/mob/species/simian/simian_shoes.dmi'
		if("belt")
			return 'monkestation/icons/mob/species/simian/simian_belts.dmi'
		if("suit")
			return 'monkestation/icons/mob/species/simian/simian_suits.dmi'
		if("back")
			return 'monkestation/icons/mob/species/simian/simian_back.dmi'
		if("neck")
			return 'monkestation/icons/mob/species/simian/simian_neck.dmi'
		else
			return
