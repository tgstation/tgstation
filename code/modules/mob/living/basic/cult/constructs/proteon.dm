/// Proteon - a very weak construct that only appears in NPC form in various ruins.
/mob/living/basic/construct/proteon
	name = "Proteon"
	real_name = "Proteon"
	desc = "A weaker construct meant to scour ruins for objects of Nar'Sie's affection. Those barbed claws are no joke."
	icon_state = "proteon"
	icon_living = "proteon"
	maxHealth = 35
	health = 35
	melee_damage_lower = 8
	melee_damage_upper = 10
	attack_verb_continuous = "pinches"
	attack_verb_simple = "pinch"
	smashes_walls = TRUE
	attack_sound = 'sound/items/weapons/punch2.ogg'
	playstyle_string = span_bold("You are a Proteon. Your abilities in combat are outmatched by most combat constructs, but you are still fast and nimble. Run metal and supplies, and cooperate with your fellow cultists.")

/// Hostile NPC version
/mob/living/basic/construct/proteon/hostile
	ai_controller = /datum/ai_controller/basic_controller/proteon
	smashes_walls = FALSE
	melee_attack_cooldown = 1.5 SECONDS

/mob/living/basic/construct/proteon/hostile/Initialize(mapload)
	. = ..()
	var/datum/callback/retaliate_callback = CALLBACK(src, PROC_REF(ai_retaliate_behaviour))
	AddComponent(/datum/component/ai_retaliate_advanced, retaliate_callback)

/// Set a timer to clear our retaliate list
/mob/living/basic/construct/proteon/hostile/proc/ai_retaliate_behaviour(mob/living/attacker)
	if (!istype(attacker))
		return
	var/random_timer = rand(2 SECONDS, 4 SECONDS) //for unpredictability
	addtimer(CALLBACK(src, PROC_REF(clear_retaliate_list)), random_timer)

/mob/living/basic/construct/proteon/hostile/proc/clear_retaliate_list()
	if(!ai_controller.blackboard_key_exists(BB_BASIC_MOB_RETALIATE_LIST))
		return
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
