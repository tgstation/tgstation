/mob/living/basic/stickman
	name = "Angry Stick Man"
	desc = "A being from a realm with only 2 dimensions. At least it's trying to stay faced towards you."
	icon_state = "stickman"
	icon_living = "stickman"
	icon_dead = "stickman_dead"
	mob_biotypes = MOB_HUMANOID
	gender = MALE
	health = 100
	maxHealth = 100
	speed = 0.5
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	faction = list(FACTION_STICKMAN)
	unsuitable_atmos_damage = 7.5
	unsuitable_cold_damage = 7.5
	unsuitable_heat_damage = 7.5

	ai_controller = /datum/ai_controller/basic_controller/stickman

/mob/living/basic/stickman/lesser
	maxHealth = 25
	health = 25

/mob/living/basic/stickman/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/paper_scatter(get_turf(src))

/datum/ai_controller/basic_controller/stickman
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/stickman
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/stickman
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/stickman

/datum/ai_behavior/basic_melee_attack/stickman
	action_cooldown = 1.5 SECONDS

/mob/living/basic/stickman/dog
	name = "Angry Stick Dog"
	desc = "Stickman's best friend, if he could see him at least."
	icon_state = "stickdog"
	icon_living = "stickdog"
	icon_dead = "stickdog_dead"
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_vis_effect = ATTACK_EFFECT_BITE
	sharpness = SHARP_POINTY
	mob_biotypes = MOB_BEAST
	attack_sound = 'sound/weapons/bite.ogg'

/mob/living/basic/stickman/ranged
	name = "Angry Stick Gunman"
	desc = "How do 2 dimensional guns even work??"
	icon_state = "stickmanranged"
	icon_living = "stickmanranged"
	attack_verb_continuous = "whacks"
	attack_verb_simple = "whack"
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_sound = 'sound/weapons/genhit1.ogg'

	ai_controller = /datum/ai_controller/basic_controller/stickman/ranged

/mob/living/basic/stickman/ranged/Initialize(mapload)
	. = ..()
	var/static/list/stickman_drops = list(/obj/item/gun/ballistic/automatic/pistol/stickman)
	AddElement(/datum/element/death_drops, stickman_drops)
	AddComponent(/datum/component/ranged_attacks, casing_type = /obj/item/ammo_casing/c9mm, projectile_sound = 'sound/misc/bang.ogg', cooldown_time = 5 SECONDS)

/datum/ai_controller/basic_controller/stickman/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/stickman
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/stickman
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/stickman

/datum/ai_behavior/basic_ranged_attack/stickman
	action_cooldown = 5 SECONDS
