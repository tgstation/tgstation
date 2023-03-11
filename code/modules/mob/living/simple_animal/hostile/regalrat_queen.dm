/mob/living/simple_animal/hostile/regalrat_queen
	name = "feral regal rat queen"
	desc = "Fate of souls that gods truly hate. Disgusting creature that must be killed at all costs. Godless furry abomination."
	icon_state = "regalrat_queen"
	icon_living = "regalrat_queen"
	icon_dead = "regalrat_queen_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	// Slightly brown red, for the eyes
	// Might be a bit too dim
	lighting_cutoff_red = 22
	lighting_cutoff_green = 8
	lighting_cutoff_blue = 5
	obj_damage = 10
	butcher_results = list(/obj/item/food/meat/slab/mouse = 2, /obj/item/clothing/head/costume/crown = 1)
	response_help_continuous = "glares at"
	response_help_simple = "glare at"
	response_disarm_continuous = "skoffs at"
	response_disarm_simple = "skoff at"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	melee_damage_lower = 3
	melee_damage_upper = 5
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	unique_name = TRUE
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES)
	///Whether or not the regal rat is already opening an airlock
	var/opening_airlock = FALSE
	///The spell that the rat uses to generate miasma
	var/datum/action/cooldown/domain/domain