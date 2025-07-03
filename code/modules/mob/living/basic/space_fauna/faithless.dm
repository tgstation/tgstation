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
	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	melee_attack_cooldown = 1 SECONDS
	speak_emote = list("growls")

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	faction = list(FACTION_FAITHLESS)
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/faithless

	/// What are the odds we paralyze a target on attack
	var/paralyze_chance = 12
	/// How long do we paralyze a target for if we attack them
	var/paralyze_duration = 2 SECONDS

/mob/living/basic/faithless/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	AddElement(/datum/element/door_pryer)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/mob_grabber, steal_from_others = FALSE)

/mob/living/basic/faithless/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !isliving(target))
		return

	var/mob/living/living_target = target
	if (prob(paralyze_chance))
		living_target.Paralyze(paralyze_duration)
		living_target.visible_message(span_danger("\The [src] knocks \the [target] down!"), \
			span_userdanger("\The [src] knocks you down!"))

/datum/ai_controller/basic_controller/faithless
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // lights
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/attack_obstacle_in_path/low_priority_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
		/datum/ai_planning_subtree/random_speech/faithless,
	)
