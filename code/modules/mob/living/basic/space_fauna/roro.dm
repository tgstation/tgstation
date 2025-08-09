/mob/living/basic/roro
	name = "roro"
	desc = "A little round, sharp beaked alien. It bears a striking resemblance to insulated gloves."
	icon_state = "roro"
	icon_living = "roro"
	icon_dead = "roro_dead"
	mob_biotypes = MOB_ORGANIC
	speed = 0.5
	maxHealth = 50
	health = 50

	butcher_results = list(
		/obj/item/clothing/gloves/color/yellow = 1
	)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"

	melee_damage_lower = 1
	melee_damage_upper = 4
	attack_verb_continuous = "nips"
	attack_verb_simple = "nip"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	melee_attack_cooldown = 0.5 SECONDS
	speak_emote = list("warbles")

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	faction = list(FACTION_HOSTILE)

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_retaliate

/datum/emote/roro
	mob_type_allowed_typecache = /mob/living/basic/roro
	mob_type_blacklist_typecache = list()

/datum/emote/roro/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles happily!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = SFX_RORO_WARBLE

/mob/living/basic/roro/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "warble")
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/roro
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
