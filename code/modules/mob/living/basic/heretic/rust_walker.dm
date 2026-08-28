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
	mob_biotypes = MOB_ROBOTIC|MOB_MINERAL

/mob/living/basic/heretic_summon/rust_walker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_RUST)

	var/static/list/grantable_spells = list(
		/datum/action/cooldown/spell/aoe/rust_conversion = BB_GENERIC_ACTION,
		/datum/action/cooldown/spell/basic_projectile/rust_wave/short = BB_TARGETED_ACTION,
	)
	grant_actions_by_list(grantable_spells)

/mob/living/basic/heretic_summon/rust_walker/setDir(newdir)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/heretic_summon/rust_walker/do_rust_heretic_act(atom/target)
	target.rust_heretic_act(RUST_RESISTANCE_TITANIUM)

/mob/living/basic/heretic_summon/rust_walker/update_icon_state()
	. = ..()
	if(stat == DEAD) // We usually delete on death but just in case
		return
	if(dir & NORTH)
		icon_state = "[base_icon_state]_n"
	else if(dir & SOUTH)
		icon_state = "[base_icon_state]_s"
	icon_living = icon_state

/mob/living/basic/heretic_summon/rust_walker/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(!.) //dead or deleted
		return
	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjust_brute_loss(-3 * seconds_per_tick)

	return ..()

/// Converts unconverted terrain, sprays pocket sand around
/datum/ai_controller/basic_controller/rust_walker
	behavior_tree_json = "code/modules/mob/living/basic/heretic/rust_walker.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
