/mob/living/simple_animal/monstrosity
	name = "...what?"
	desc = "WHAT IT IS THAT!? WHAT THE FUCK IS THAT!?"
	icon = 'icons/mob/monstrosity.dmi'
	icon_state = "monstrosity"
	icon_living = "monstrosity"
	icon_dead = "monstrosity_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "pushes"
	response_help_simple = "push"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	speak_emote = list("speaks")
	del_on_death = 1
