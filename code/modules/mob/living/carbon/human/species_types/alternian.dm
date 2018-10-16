/datum/species/alternian
	// raça original
	name = "Alternian Troll"
	id = "alternian"
	say_mod = "says"
	blacklisted = 0 // para tds
	sexes = 1 // te,ps sexo
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	species_traits = list(HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_FAKEDEATH)
	inherent_biotypes = list(MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/bone
	mutant_bodyparts = list("alternian_horns")
	default_features = list("alternian_horns" = "Simple")
	damage_overlay_type = ""
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'

/datum/species/alternian/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/alternian/qualifies_for_rank(rank, list/features)
	if(CONFIG_GET(flag/enforce_human_authority) && (rank in GLOB.command_positions))
		return FALSE
	return TRUE