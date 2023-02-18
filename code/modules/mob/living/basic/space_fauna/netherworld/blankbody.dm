/mob/living/basic/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	health = 100
	maxHealth = 100
	obj_damage = 50
	melee_damage_lower = 2
	melee_damage_upper = 6
	speed = 1
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list("nether")
	speak_emote = list("screams")
	death_message = "falls apart into a fine dust."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	// Pink, like their skin
	lighting_cutoff_red = 30
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 40

	ai_controller = /datum/ai_controller/basic_controller/blankbody
	/// Used for mobs that get spawned in a spawner appearently.
	var/datum/component/spawner/nest

/mob/living/basic/blankbody/Initialize(mapload)
	. = ..()
	var/datum/callback/health_changes_callback = CALLBACK(src, PROC_REF(health_check))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 0)
	AddComponent(/datum/component/damage_buffs, health_changes_callback)

/mob/living/basic/blankbody/proc/health_check(mob/living/attacker)
	if(health < maxHealth * 0.25)
		health_low_behaviour()
	else if (health < maxHealth * 0.5)
		health_medium_behaviour()
	else if (health < maxHealth * 0.75)
		health_high_behaviour()
	else
		health_full_behaviour()

/mob/living/basic/blankbody/proc/health_full_behaviour()
	melee_damage_lower = 2
	melee_damage_upper = 6

/mob/living/basic/blankbody/proc/health_high_behaviour()
	melee_damage_lower = 4
	melee_damage_upper = 8

/mob/living/basic/blankbody/proc/health_medium_behaviour()
	melee_damage_lower = 8
	melee_damage_upper = 12

/mob/living/basic/blankbody/proc/health_low_behaviour()
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/basic/blankbody/Destroy()
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	return ..()

/datum/ai_controller/basic_controller/blankbody
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/average_speed,
	)
