/mob/living/simple_animal/pet/gondola/funky
	name = "Funky"
	real_name = "Funky"
	desc = "Gondola is the silent walker. Having no hands he embodies the Taoist principle of wu-wei (non-action) while his smiling facial expression shows his utter and complete acceptance of the world as it is. Its hide is extremely valuable. This one seems a little skinny and attached to the Theater."
	loot = list(/obj/effect/decal/cleanable/blood/gibs)

/mob/living/basic/pet/dog/dobermann/walter
	name = "Walter"
	real_name = "Walter"
	desc = "It's Walter, he bites criminals just as well as he bites toddlers."

/mob/living/basic/rabbit/daisy
	name = "Daisy"
	real_name = "Daisy"
	desc = "The Curator's pet bnuuy."
	gender = FEMALE

/mob/living/basic/bear/wojtek
	name = "Wojtek"
	real_name = "Wojtek"
	desc = "The bearer of Bluespace Artillery."
	faction = list(FACTION_NEUTRAL)
	gender = MALE

/mob/living/basic/chicken/teshari
	name = "Teshari"
	real_name = "Teshari"
	desc = "A timeless classic."
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 30000

///Wild carp that just vibe ya know
/mob/living/basic/carp/passive
	name = "passive carp"
	desc = "A timid, sucker-bearing creature that resembles a fish. "

	attack_verb_continuous = "suckers"
	attack_verb_simple = "suck"

	melee_damage_lower = 4
	melee_damage_upper = 4
	ai_controller = /datum/ai_controller/basic_controller/carp/passive

/mob/living/basic/carp/passive/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "bloops happily!")

/**
 * Carp which bites back, but doesn't look for targets and doesnt do as much damage
 * Still migrate and stuff
 */
/datum/ai_controller/basic_controller/carp/passive
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/carp_migration,
	)
