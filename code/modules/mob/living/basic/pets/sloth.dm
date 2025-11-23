GLOBAL_DATUM(cargo_sloth, /mob/living/basic/sloth)

/mob/living/basic/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"

	speak_emote = list("yawns")

	can_be_held = TRUE
	held_state = "sloth"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN

	melee_damage_lower = 18
	melee_damage_upper = 18
	health = 50
	maxHealth = 50
	speed = 10 // speed is fucking weird man. they aren't fast though don't worry
	butcher_results = list(/obj/item/food/meat/slab = 3)

	ai_controller = /datum/ai_controller/basic_controller/sloth

/datum/emote/sloth
	mob_type_allowed_typecache = /mob/living/basic/sloth
	mob_type_blacklist_typecache = list()

/datum/emote/sloth/smile_slow
	key = "ssmile"
	key_third_person = "slowlysmiles"
	message = "slowly smiles!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/mob/living/basic/sloth/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "ssmile")
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/tree_climber)

	if(!mapload || !isnull(GLOB.cargo_sloth) || !is_station_level(z))
		return

	// If someone adds non-cargo sloths to maps we'll have a problem but we're fine for now
	GLOB.cargo_sloth = src
	GLOB.gorilla_start += get_turf(src)

/mob/living/basic/sloth/Destroy()
	if(GLOB.cargo_sloth == src)
		GLOB.cargo_sloth = null

	return ..()

/mob/living/basic/sloth/paperwork
	name = "Paperwork"
	desc = "Cargo's pet sloth. About as useful as the rest of the techs."
	gender = MALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/sloth/citrus
	name = "Citrus"
	desc = "Cargo's pet sloth. She's dressed in a horrible sweater."
	icon_state = "cool_sloth"
	icon_living = "cool_sloth"
	icon_dead = "cool_sloth_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/toy/spinningtoy = 1)
	gold_core_spawnable = NO_SPAWN

/// They're really passive in game, so they just wanna get away if you start smacking them. No trees in space from them to use for clawing your eyes out, but they will try if desperate.
/datum/ai_controller/basic_controller/sloth
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/random_speech/sloth,
	)

/datum/ai_planning_subtree/random_speech/sloth
	speech_chance = 1
	emote_hear = list("snores.", "yawns.")
	emote_see = list("dozes off.", "looks around sleepily.")
