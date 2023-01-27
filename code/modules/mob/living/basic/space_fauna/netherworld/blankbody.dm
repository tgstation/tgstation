/mob/living/basic/netherworld
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
	attack_vis_effect = ATTACK_EFFECT_SLASH // I always thought they bit. Guess I was wrong.
	faction = list("nether")
	speak_emote = list("screams")
	death_message = "falls apart into a fine dust."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	ai_controller = /datum/ai_controller/basic_controller/blankbody

	/// How much 1/4th of our maxHealth is
	var/one_fourth_health
	/// How much 2/4th of our maxHealth is
	var/two_fourth_health
	/// How much 3/4th of our maxHealth is
	var/three_fourth_health
	/// What is the current movement speed modifier if we have one
	var/datum/movespeed_modifier/movement_speed_datum

/mob/living/basic/netherworld/Initialize(mapload)
	. = ..()
	one_fourth_health = maxHealth / 4
	two_fourth_health = one_fourth_health * 2
	three_fourth_health = one_fourth_health * 3
	var/datum/callback/health_changes_callback = CALLBACK(src, PROC_REF(health_check))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 0)
	AddComponent(/datum/component/damage_buffs, health_changes_callback)

/mob/living/basic/netherworld/proc/health_check(mob/living/attacker)
	if(health < one_fourth_health)
		health_low_behaviour()
	else if (health < two_fourth_health)
		health_medium_behaviour()
	else if (health < three_fourth_health)
		health_high_behaviour()
	else
		health_full_behaviour()

/mob/living/basic/netherworld/proc/health_full_behaviour()
	melee_damage_lower = 2
	melee_damage_upper = 6

/mob/living/basic/netherworld/proc/health_high_behaviour()
	melee_damage_lower = 4
	melee_damage_upper = 8

/mob/living/basic/netherworld/proc/health_medium_behaviour()
	melee_damage_lower = 8
	melee_damage_upper = 12

/mob/living/basic/netherworld/proc/health_low_behaviour()
	melee_damage_lower = 10
	melee_damage_upper = 20

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
