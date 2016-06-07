//Transferring this eldritch abomination to its own .dm for all our sakes

/mob/living/simple_animal/hostile/crab
	name = "MEGAMADCRAB"
	real_name = "MEGAMADCRAB"
	desc = "OH NO YOU DUN IT NOW."
	icon = 'icons/mob/animal.dmi'
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks with fury", "clicks angrily")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 15//Gotta go fast
	maxHealth = 300//So they don't die as quickly
	health = 300


	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "snips"
	attack_sound = 'sound/weapons/toolhit.ogg'
