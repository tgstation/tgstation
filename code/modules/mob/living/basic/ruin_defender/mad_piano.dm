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
	speed = 0
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	attack_sound = 'sound/effects/piano_hit.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	ai_controller = /datum/ai_controller/basic_controller/mad_piano
	faction = list(ROLE_SYNDICATE)
	//alternate variables used when aggro
	var/name_aggro = "mad piano"
	var/icon_aggro = "aggressive"
	var/desc_aggro = "This instrument is aggressive! Better stay away from its big chomping teeth!"
	var/speed_aggro = 2

/mob/living/basic/mad_piano/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/gibspawner/robot)
	AddElement(/datum/element/death_drops, death_loot)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(aggro_tantrum))
	AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = 2, works_in_containers = FALSE)
	AddElementTrait(TRAIT_WADDLING, INNATE_TRAIT, /datum/element/waddling)

/mob/living/basic/mad_piano/proc/aggro_tantrum(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || !istype(victim, /mob/living/carbon) || victim.stat == DEAD)
		return
	name = name_aggro
	icon_state = icon_aggro
	desc = desc_aggro
	speed = speed_aggro

/mob/living/basic/mad_piano/proc/calm_down(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) && !istype(victim, /mob/living/carbon) || victim.stat == DEAD)
		return
	icon_state = initial(icon_state)
	desc = initial(desc)
	name = initial(name)
	speed = initial(speed)

/mob/living/basic/mad_piano/med_hud_set_health() //sneaky sneaky sneaky
	return

/mob/living/basic/mad_piano/med_hud_set_status()
	return

/datum/ai_controller/basic_controller/mad_piano
	idle_behavior = /datum/idle_behavior/walk_near_target/mad_piano
	max_target_distance = 2
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mad_piano,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_TARGETLESS_TIME = 2 SECONDS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/sleep_with_no_target/mad_piano,
	)
/datum/targeting_strategy/basic/mad_piano

/datum/idle_behavior/walk_near_target/mad_piano
	walk_chance = 50
	minimum_distance = 5

/datum/ai_planning_subtree/sleep_with_no_target/mad_piano
	sleep_behaviour = /datum/ai_behavior/sleep_after_targetless_time/mad_piano

/datum/ai_behavior/sleep_after_targetless_time/mad_piano

/datum/ai_behavior/sleep_after_targetless_time/mad_piano/enter_sleep(datum/ai_controller/controller)
	var/mob/living/basic/mad_piano = controller.pawn
	if (!istype(mad_piano))
		return ..()
