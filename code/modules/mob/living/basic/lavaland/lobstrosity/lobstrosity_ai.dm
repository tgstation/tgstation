#define SHRIMP_HARM_RESPONSES list(\
	"*me stares blankly.",\
	"*me stares shrimply.",\
	"*me gives a confused look.",\
	"*me chitters unpleasantly.",\
)

/datum/ai_controller/basic_controller/lobstrosity
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_LOBSTROSITY_EXPLOIT_TRAITS = list(TRAIT_INCAPACITATED, TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT),
		BB_LOBSTROSITY_FINGER_LUST = 0,
		BB_LOBSTROSITY_NAIVE_HUNTER = FALSE,
		BB_BASIC_MOB_FLEE_DISTANCE = 6,
		BB_EAT_FOOD_COOLDOWN = 3 MINUTES,
		BB_ONLY_FISH_WHILE_HUNGRY = TRUE,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_OWNER_SELF_HARM_RESPONSES = SHRIMP_HARM_RESPONSES,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/lobstrosity/lobstrosity.bt.json"

/datum/ai_controller/basic_controller/lobstrosity/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	var/static/list/food_types = typecacheof(list(/obj/item/fish/lavaloop))
	set_blackboard_key(BB_BASIC_FOODS, food_types)

///Ensure that juveline lobstrosities witll charge at things they can reach.
/datum/ai_controller/basic_controller/lobstrosity/juvenile
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_MINIMUM_STAT = SOFT_CRIT,
		BB_LOBSTROSITY_EXPLOIT_TRAITS = list(TRAIT_INCAPACITATED, TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT),
		BB_LOBSTROSITY_FINGER_LUST = 0,
		BB_LOBSTROSITY_NAIVE_HUNTER = TRUE,
		BB_BASIC_MOB_FLEE_DISTANCE = 4,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_OWNER_SELF_HARM_RESPONSES = SHRIMP_HARM_RESPONSES,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)

///A subtype of juvenile lobster AI that has the target_retaliate behaviour instead of simple_find_target
/datum/ai_controller/basic_controller/lobstrosity/juvenile/calm
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/lobstrosity/lobstrosity_calm.bt.json"

///A subtype of juvenile lobster AI that has the capricious_retaliate behaviour instead of simple_find_target
/datum/ai_controller/basic_controller/lobstrosity/juvenile/capricious
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/lobstrosity/lobstrosity_capricious.bt.json"

#undef SHRIMP_HARM_RESPONSES
