//the mad piano
//looks like a regular piano, then if you get close it wakes up and bites you

/mob/living/basic/mad_piano
	name = "space piano"
	desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
	icon = 'icons/mob/simple/mad_piano.dmi'
	icon_state = "calm"
	mob_size = MOB_SIZE_HUGE
	move_resist = INFINITY
	combat_mode = TRUE
	faction = list(FACTION_HOSTILE, FACTION_TURRET)
	maxHealth = 120
	health = 120
	melee_damage_lower = 24
	melee_damage_upper = 26
	melee_attack_cooldown = 1 SECONDS
	speed = 2
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	attack_sound = 'sound/effects/piano_hit.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	ai_controller = /datum/ai_controller/basic_controller/mad_piano
	//alternate variables used when aggro
	var/name_aggro = "mad piano"
	var/icon_aggro = "aggressive"
	var/desc_aggro = "This instrument is aggressive! Better stay away from its big chomping teeth!"
	//and when calm
	var/name_calm
	var/icon_calm
	var/desc_calm
	COOLDOWN_DECLARE(tantrum_time)
	//length of aggro state
	var/tantrum_time_duration = 3.5 SECONDS

/mob/living/basic/mad_piano/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/gibspawner/robot)
	AddElement(/datum/element/death_drops, death_loot)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(aggro_tantrum))
	AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = 1, works_in_containers = FALSE)
	AddElementTrait(TRAIT_WADDLING, INNATE_TRAIT, /datum/element/waddling)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_PACIFISM, TRAIT_GENERIC)
	name_calm = name
	icon_calm = icon_state
	desc_calm = desc

/mob/living/basic/mad_piano/process(seconds_per_tick)

	if (COOLDOWN_FINISHED(src, tantrum_time))
		calm_down()

/mob/living/basic/mad_piano/proc/aggro_tantrum(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim, /mob/living/carbon) || victim.stat == DEAD)
		return
	tantrum_time = tantrum_time_duration
	name = name_aggro
	icon_state = icon_aggro
	desc = desc_aggro
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	REMOVE_TRAIT(src, TRAIT_PACIFISM, TRAIT_GENERIC)
	COOLDOWN_START(src, tantrum_time, tantrum_time_duration)
	START_PROCESSING(SSprocessing, src)

/mob/living/basic/mad_piano/proc/calm_down(datum/source)
	if(!COOLDOWN_FINISHED(src, tantrum_time))
		return
	icon_state = icon_calm
	desc = desc_calm
	name = name_calm
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_PACIFISM, TRAIT_GENERIC)
	STOP_PROCESSING(SSprocessing, src)

/mob/living/basic/mad_piano/med_hud_set_health() //sneaky sneaky sneaky
	return

/mob/living/basic/mad_piano/med_hud_set_status()
	return

/mob/living/basic/mad_piano/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/ai_controller/basic_controller/mad_piano
	idle_behavior = /datum/idle_behavior/idle_random_walk/mad_piano
	max_target_distance = 2
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/idle_behavior/idle_random_walk/mad_piano
	walk_chance = 80
