/datum/species/alternian
	// raça original
	name = "Alternian Troll"
	id = "alternian"
	say_mod = "quirks"
	blacklisted = 0
	sexes = 1
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	species_traits = list(HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_FAKEDEATH)
	inherent_biotypes = list(MOB_HUMANOID, MOB_ORGANIC)
	mutant_bodyparts = list("alternian_horns")
	default_features = list("alternian_horns" = "simple")
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	//limbs_id = "alternian"
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'


/datum/species/alternian/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["alternian_horns"])
			H.dna.features["alternian_horns"] = "[(H.client && H.client.prefs && LAZYLEN(H.client.prefs.features) && H.client.prefs.features["alternian_horns"]) ? H.client.prefs.features["alternian_horns"] : "simple"]"
			handle_mutant_bodyparts(H)

/datum/species/alternian/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/alternian/qualifies_for_rank(rank, list/features)
	if(CONFIG_GET(flag/enforce_human_authority) && (rank in GLOB.command_positions))
		return FALSE
	return TRUE