/mob/living/basic/frog
	name = "frog"
	desc = "They seem a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	verb_say = "ribbits"
	verb_ask = "ribbits inquisitively"
	verb_exclaim = "croaks"
	verb_yell = "croaks loudly"
	maxHealth = 15
	health = 15
	speed = 1.1
	melee_damage_lower = 5
	melee_damage_upper = 5
	obj_damage = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pokes"
	response_disarm_simple = "poke"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)
	attack_sound = 'sound/effects/reee.ogg'
	butcher_results = list(/obj/item/food/nugget = 1)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'

	habitable_atmos = list("min_oxy" = 3, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 15, "min_co2" = 0, "max_co2" = 15, "min_n2" = 0, "max_n2" = 0)

	ai_controller = /datum/ai_controller/basic_controller/frog

	var/stepped_sound = 'sound/effects/huuu.ogg'
	///How much of a reagent the mob injects on attack
	var/poison_per_bite = 3
	///What reagent the mob injects targets with
	var/poison_type = /datum/reagent/drug/space_drugs

/mob/living/basic/frog/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	if(prob(1))
		name = "rare frog"
		desc = "They seem a little smug."
		icon_state = "rare_frog"
		icon_living = "rare_frog"
		icon_dead = "rare_frog_dead"
		butcher_results = list(/obj/item/food/nugget = 5)
		poison_type = /datum/reagent/drug/mushroomhallucinogen

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/venomous, poison_type, poison_per_bite)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_FROG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/frog/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(!stat && isliving(AM))
		var/mob/living/L = AM
		if(L.mob_size > MOB_SIZE_TINY)
			playsound(src, stepped_sound, 50, TRUE)

/datum/ai_controller/basic_controller/frog
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/frog,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/frog
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/frog

/datum/ai_behavior/basic_melee_attack/frog
	action_cooldown = 2.5 SECONDS

/datum/ai_controller/basic_controller/frog/trash
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/frog,
	)
