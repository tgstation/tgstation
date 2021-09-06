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
	speed = 0
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	faction = list("stickman")

	ai_controller = /datum/ai_controller/basic_controller/stickman

/mob/living/basic/stickman/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/basic_body_temp_sensitive)
	AddElement(/datum/element/atmos_requirements, list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0), 7.5)

/datum/ai_controller/basic_controller/stickman
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/stickman,
		/datum/ai_planning_subtree/find_and_hunt_target
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/stickman
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/stickman

/datum/ai_behavior/basic_melee_attack/stickman
	action_cooldown = 1.5 SECONDS

/datum/ai_controller/basic_controller/stickman/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)


/mob/living/basic/stickman/dog
	name = "Angry Stick Dog"
	desc = "Stickman's best friend, if he could see him at least."
	icon_state = "stickdog"
	icon_living = "stickdog"
	icon_dead = "stickdog_dead"
	mob_biotypes = MOB_BEAST

/mob/living/basic/stickman/ranged
	icon_state = "stickmanranged"
	icon_living = "stickmanranged"

	ai_controller = /datum/ai_controller/basic_controller/stickman/ranged

/mob/living/basic/stickman/ranged/Initialize()
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/gun/ballistic/automatic/pistol/stickman))
	AddElement(/datum/element/ranged_attacks, /obj/item/ammo_casing/c45, 'sound/misc/bang.ogg')

/datum/ai_controller/basic_controller/stickman/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/stickman,
		/datum/ai_planning_subtree/find_and_hunt_target
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/stickman
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/stickman

/datum/ai_behavior/basic_ranged_attack/stickman
	action_cooldown = 2.5 SECONDS
	required_distance = 5
