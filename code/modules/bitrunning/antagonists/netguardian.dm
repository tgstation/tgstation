/datum/antagonist/bitrunning_glitch/netguardian
	name = ROLE_NETGUARDIAN
	threat = 150
	show_in_antagpanel = TRUE

/mob/living/basic/netguardian
	name = "netguardian prime"
	desc = "The last line of defense against organic intrusion. It doesn't appear happy to see you."
	icon = 'icons/mob/nonhuman-player/netguardian.dmi'
	icon_state = "netguardian"
	icon_living = "netguardian"
	icon_dead = "crash"

	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE

	health = 500
	maxHealth = 500
	melee_damage_lower = 45
	melee_damage_upper = 65

	attack_verb_continuous = "drills"
	attack_verb_simple = "drills"
	attack_sound = 'sound/weapons/drill.ogg'
	attack_vis_effect = ATTACK_EFFECT_MECHFIRE
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	faction = list(
		FACTION_BOSS,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_GLITCH,
		ROLE_SYNDICATE,
	)

	combat_mode = TRUE
	speech_span = SPAN_ROBOT
	death_message = "malfunctions!"

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = TCMB
	ai_controller = /datum/ai_controller/basic_controller/netguardian

/mob/living/basic/netguardian/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, \
		casing_type = /obj/item/ammo_casing/c46x30mm, \
		projectile_sound = 'sound/weapons/gun/smg/shot.ogg', \
		burst_shots = 6 \
	)
	AddComponent(/datum/component/seethrough_mob)

	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian/rockets = new(src)
	rockets.Grant(src)
	ai_controller.set_blackboard_key(BB_NETGUARDIAN_ROCKET_ABILITY, rockets)

	AddElement(/datum/element/simple_flying)

/mob/living/basic/netguardian/death(gibbed)
	do_sparks(number = 3, cardinal_only = TRUE, source = src)
	playsound(src, 'sound/mecha/weapdestr.ogg', 100)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian
	name = "2E Rocket Launcher"
	button_icon = 'icons/obj/weapons/guns/ammo.dmi'
	button_icon_state = "rocketbundle"
	cooldown_time = 30 SECONDS
	default_projectile_spread = 15
	projectile_type = /obj/projectile/bullet/rocket
	shot_count = 3

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian/attack_sequence(mob/living/firer, atom/target)
	playsound(firer, 'sound/mecha/skyfall_power_up.ogg', 120)
	firer.say("target acquired.", "machine")

	var/mutable_appearance/firing_effect = mutable_appearance('icons/mob/nonhuman-player/netguardian.dmi', "firing")
	firer.add_overlay(firing_effect)
	if(do_after(firer, 1.5 SECONDS))
		..()

	firer.cut_overlay(firing_effect)

/datum/ai_controller/basic_controller/netguardian
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/targeted_mob_ability/fire_rockets,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/netguardian,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/netguardian
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/netguardian

/datum/ai_behavior/basic_ranged_attack/netguardian
	action_cooldown = 1 SECONDS
	avoid_friendly_fire = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/fire_rockets
	ability_key = BB_NETGUARDIAN_ROCKET_ABILITY
	finish_planning = FALSE
