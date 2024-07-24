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
	melee_attack_cooldown = 2.5 SECONDS
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
		make_rare()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/venomous, poison_type, poison_per_bite)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_FROG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/frog/proc/make_rare()
	name = "rare frog"
	desc = "They seem a little smug."
	icon_state = "rare_[icon_state]"
	icon_living = "rare_[icon_living]"
	icon_dead = "rare_[icon_dead]"
	butcher_results = list(/obj/item/food/nugget = 5)
	poison_type = /datum/reagent/drug/mushroomhallucinogen

/mob/living/basic/frog/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(!stat && isliving(AM))
		var/mob/living/L = AM
		if(L.mob_size > MOB_SIZE_TINY)
			playsound(src, stepped_sound, 50, TRUE)

/mob/living/basic/frog/icemoon_facility
	name = "Peter Jr."
	desc = "They seem a little cold."
	minimum_survivable_temperature = BODYTEMP_COLD_ICEBOX_SAFE
	pressure_resistance = 200
	habitable_atmos = null
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/icemoon_facility/make_rare()
	. = ..()
	name = "Peter Sr." //make him senior.

/mob/living/basic/frog/frog_suicide
	name = "suicide frog"
	desc = "Driven by sheer will."
	icon_state = "frog_trash"
	icon_living = "frog_trash"
	icon_dead = "frog_trash_dead"
	maxHealth = 5
	health = 5
	ai_controller = /datum/ai_controller/basic_controller/frog/suicide_frog
	///how long do we exist for
	var/existence_period = 15 SECONDS

/mob/living/basic/frog/frog_suicide/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/explode_on_attack, mob_type_dont_bomb = typecacheof(list(/mob/living/basic/frog, /mob/living/basic/leaper)))
	addtimer(CALLBACK(src, PROC_REF(death)), existence_period)

/datum/ai_controller/basic_controller/frog
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me licks its own eyeballs in disapproval.",
			"*me croaks sadly."
		)
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/go_for_swim,
	)

/datum/ai_controller/basic_controller/frog/trash
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/frog/suicide_frog
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
