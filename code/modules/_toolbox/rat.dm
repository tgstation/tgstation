/mob/living/simple_animal/hostile/rat
	name = "rabid rat"
	desc = "Eeek! A huge rabid rat."
	icon = 'icons/oldschool/simple_animals.dmi'
	icon_state = "rat"
	icon_living = "rat"
	icon_dead = "rat_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks")
	emote_hear = list("squeeks.")
	emote_taunt = list("stares ferociously", "hisses")
	speak_chance = 1
	taunt_chance = 25
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 50
	health = 50

	obj_damage = 21
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	friendly = "rat hugs"

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5

	faction = list("rat")
	gold_core_spawnable = 1