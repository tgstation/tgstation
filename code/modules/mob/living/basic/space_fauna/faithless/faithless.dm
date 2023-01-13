/mob/living/basic/faithless
	name = "The Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	speed = 0.5
	maxHealth = 80
	health = 80

	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("growls")

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	faction = list("faithless")
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/faithless

/mob/living/basic/faithless/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddComponent(/datum/component/pry_open_door)

/datum/ai_controller/basic_controller/faithless
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/faithless(),
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // lights
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/attack_obstacle_in_path/low_priority_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/faithless,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
		/datum/ai_planning_subtree/random_speech/faithless,
	)

/datum/targetting_datum/basic/faithless
	stat_attack = UNCONSCIOUS

/datum/ai_planning_subtree/basic_melee_attack_subtree/faithless
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/faithless

/datum/ai_behavior/basic_melee_attack/faithless
	action_cooldown = 1 SECONDS
	/// What are the odds we paralyze a target
	var/paralyze_chance = 12
	/// How long do we paralyze a target for if we attack them
	var/paralyze_duration = 2 SECONDS

/datum/ai_behavior/basic_melee_attack/faithless/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/mob/living/living_pawn = controller.pawn

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(living_target.pulledby, /datum/ai_controller/basic_controller/faithless)) //Dont steal from my fellow faithless.
		if(living_pawn.Adjacent(living_target) && isturf(living_target.loc) && living_target.stat == SOFT_CRIT)
			living_target.grabbedby(living_pawn) //Drag their bodies around as a menace.
	if(prob(paralyze_chance) && iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.Paralyze(paralyze_duration)
		carbon_target.visible_message(span_danger("\The [living_pawn] knocks down \the [carbon_target]!"), \
				span_userdanger("\The [living_pawn] knocks you down!"))
