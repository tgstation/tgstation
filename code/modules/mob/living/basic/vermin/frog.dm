/mob/living/basic/frog
	name = "frog"
	desc = "They seem a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_AQUATIC
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
	attack_sound = 'sound/mobs/non-humanoids/frog/reee.ogg'
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

	var/stepped_sound = 'sound/mobs/non-humanoids/frog/huuu.ogg'
	///How much of a reagent the mob injects on attack
	var/poison_per_bite = 3
	///What reagent the mob injects targets with
	var/poison_type = /datum/reagent/drug/space_drugs
	///What type do we become if influenced by a regal rat?
	var/minion_type = /mob/living/basic/frog/crazy

/mob/living/basic/frog/Initialize(mapload)
	. = ..()

	add_traits(list(TRAIT_NODROWN, TRAIT_SWIMMER, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/venomous, poison_type, poison_per_bite)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_FROG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	if (minion_type)
		AddElement(/datum/element/regal_rat_minion, converted_path = minion_type, success_balloon = "ribbit", pet_commands = GLOB.regal_rat_minion_commands)

/mob/living/basic/frog/proc/on_entered(datum/source, entered as mob|obj)
	SIGNAL_HANDLER
	if(stat || !isliving(entered))
		return
	var/mob/living/entered_mob = entered
	if(entered_mob.mob_size > MOB_SIZE_TINY)
		playsound(src, stepped_sound, vol = 50, vary = TRUE)

/mob/living/basic/frog/rare
	name = "rare frog"
	desc = "They seem a little smug."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/food/nugget = 5)
	poison_type = /datum/reagent/drug/mushroomhallucinogen
	minion_type = /mob/living/basic/frog/crazy/rare

/// These frogs would REALLY rather like to get at your blood basically by any means possible
/mob/living/basic/frog/crazy
	name = "trash frog"
	desc = "They seem a little mad."
	icon_state = "frog_trash"
	icon_living = "frog_trash"
	icon_dead = "frog_trash_dead"
	health = 25
	maxHealth = 25
	melee_damage_lower = 6
	melee_damage_upper = 15
	obj_damage = 20
	minion_type = null
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/frog/trash

/mob/living/basic/frog/crazy/rare
	name = "crazy frog"
	desc = "They look hopping mad."
	icon_state = "rare_frog_trash"
	icon_living = "rare_frog_trash"
	icon_dead = "rare_frog_trash_dead"
	minion_type = null
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/food/nugget = 5)
	poison_type = /datum/reagent/drug/mushroomhallucinogen

/// The cold doesn't bother him
/mob/living/basic/frog/icemoon_facility
	name = "Peter Jr."
	desc = "They seem a little cold."
	minimum_survivable_temperature = BODYTEMP_COLD_ICEBOX_SAFE
	pressure_resistance = 200
	habitable_atmos = null
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/icemoon_facility/crazy
	name = "Crazy Pete"
	desc = "The cold is really getting to him."
	icon_state = "frog_trash"
	icon_living = "frog_trash"
	icon_dead = "frog_trash_dead"
	ai_controller = /datum/ai_controller/basic_controller/frog/trash


/// Frog spawned by leapers which explodes on attack
/mob/living/basic/frog/suicide
	name = "suicide frog"
	desc = "Driven by sheer will."
	icon_state = "frog_trash"
	icon_living = "frog_trash"
	icon_dead = "frog_trash_dead"
	maxHealth = 5
	health = 5
	ai_controller = /datum/ai_controller/basic_controller/frog/suicide_frog
	minion_type = null
	///how long do we exist for
	var/existence_period = 15 SECONDS

/mob/living/basic/frog/suicide/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/explode_on_attack, mob_type_dont_bomb = typecacheof(list(/mob/living/basic/frog, /mob/living/basic/leaper)))
	addtimer(CALLBACK(src, PROC_REF(death)), existence_period)

/datum/ai_controller/basic_controller/frog
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE, //We only flee from scary fishermen.
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
		/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman,
		/datum/ai_planning_subtree/flee_target/from_fisherman,
		/datum/ai_planning_subtree/go_for_swim,
	)

/datum/ai_controller/basic_controller/frog/trash
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman,
		/datum/ai_planning_subtree/flee_target/from_fisherman,
	)

/datum/ai_controller/basic_controller/frog/suicide_frog
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN, //No fear, only hatred. It has nothing to lose
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_target_prioritize_traits,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
