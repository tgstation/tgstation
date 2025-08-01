/mob/living/basic/flock
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC | MOB_SPECIAL
	faction = list(FACTION_FLOCK)
	unsuitable_atmos_damage = 0 // they don't need air!
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	fire_stack_decay_rate = -10 // todo: self-extinguish behaviour for all flock mobs
	pressure_resistance = 100
	damage_coeff = list(BRUTE = 1.2, BURN = 0.8, TOX = 0, STAMINA = 0.5, OXY = 0)
	unique_name = TRUE
	can_buckle_to = FALSE
	initial_language_holder = /datum/language_holder/flock
	death_message = "cracks and splinters, falling over."

	speak_emote = list("chimes", "intones", "hums")
	response_help_continuous = "pats"
	response_help_simple = "pat"
	response_disarm_continuous = "shoves"
	response_disarm_simple = "shove"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	melee_attack_cooldown = CLICK_CD_MELEE


