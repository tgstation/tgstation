/// Pretty simple mob which creates areas of rust and has a rust-creating projectile spell
/mob/living/basic/heretic_summon/rust_walker
	name = "\improper Rust Walker"
	real_name = "Rusty"
	desc = "A grinding, clanking construct which leaches life from its surroundings with every armoured step."
	icon_state = "rust_walker_s"
	base_icon_state = "rust_walker"
	icon_living = "rust_walker_s"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	speed = 1
	ai_controller = /datum/ai_controller/basic_controller/rust_walker

/mob/living/basic/heretic_summon/rust_walker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_RUST)

	var/static/list/grantable_spells = list(
		/datum/action/cooldown/spell/aoe/rust_conversion/small = BB_GENERIC_ACTION,
		/datum/action/cooldown/spell/basic_projectile/rust_wave/short = BB_TARGETED_ACTION,
	)
	grant_actions_by_list(grantable_spells)

/mob/living/basic/heretic_summon/rust_walker/setDir(newdir)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/heretic_summon/rust_walker/update_icon_state()
	. = ..()
	if(stat == DEAD) // We usually delete on death but just in case
		return
	if(dir & NORTH)
		icon_state = "[base_icon_state]_n"
	else if(dir & SOUTH)
		icon_state = "[base_icon_state]_s"
	icon_living = icon_state

/mob/living/basic/heretic_summon/rust_walker/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(stat == DEAD)
		return ..()
	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjustBruteLoss(-3 * seconds_per_tick)

	return ..()

/// Converts unconverted terrain, sprays pocket sand around
/datum/ai_controller/basic_controller/rust_walker
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/rust
	planning_subtrees = list(
		/datum/ai_planning_subtree/use_mob_ability/rust_walker,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Moves a lot if healthy and on rust (to find more tiles to rust) or unhealthy and not on rust (to find healing rust)
/// Still moving in random directions though we're not really seeking it out
/datum/idle_behavior/idle_random_walk/rust

/datum/idle_behavior/idle_random_walk/rust/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/our_mob = controller.pawn
	var/turf/our_turf = get_turf(our_mob)
	if (HAS_TRAIT(our_turf, TRAIT_RUSTY))
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 10 : 50
	else
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 50 : 10
	return ..()

/// Use if we're not stood on rust right now
/datum/ai_planning_subtree/use_mob_ability/rust_walker

/datum/ai_planning_subtree/use_mob_ability/rust_walker/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/turf/our_turf = get_turf(controller.pawn)
	if (HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return
	return ..()
