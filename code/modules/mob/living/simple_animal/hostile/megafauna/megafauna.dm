/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	sentience_type = SENTIENCE_OTHER
	environment_smash = 4
	robust_searching = 1
	stat_attack = 1

	var/can_die = FALSE //Used to prevent instagib/instakill attacks like the wand of death


	//Abilities
	var/next_ability = 0 //the world.time when we can use our next specialBlob

	var/anger = 0
	var/annoyed = 250
	var/angry = 500
	var/pissed = 750

/mob/living/simple_animal/hostile/megafauna/Life()
	if(health <= 0)
		can_die = TRUE
	..()

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(!can_die)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/gib()
	if(!can_die)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust()
	if(!can_die)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/adjustBruteLoss(damage)
	..()
	anger += damage

/mob/living/simple_animal/hostile/megafauna/proc/anger_modifier()
	. = 0
	if(anger)
		if(annoyed)
			. = 10
		if(angry)
			. = 20
		if(pissed)
			. = 30
