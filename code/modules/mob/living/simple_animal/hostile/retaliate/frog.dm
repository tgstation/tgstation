/mob/living/simple_animal/hostile/retaliate/frog
	name = "frog"
	desc = "It seems a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	speak = list("ribbits","croaks")
	emote_see = list("hops in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 15
	health = 15
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bites"
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "splats"
	density = 0
	ventcrawler = 2
	faction = list("hostile")
	attack_sound = 'sound/effects/Reee.ogg'
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = 1

/mob/living/simple_animal/frog/New()
	..()
	if(prob(1))
		name = "rare frog"
		desc = "It seems a little smug."

/mob/living/simple_animal/hostile/retaliate/frog/Crossed()
	if(!stat)
		playsound(src, 'sound/effects/Huuu.ogg', 100, 1)