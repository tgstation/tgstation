/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	sentience_type = SENTIENCE_OTHER
	environment_smash = 4
	robust_searching = 1
	stat_attack = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	layer = 6 //Looks weird with them slipping under mineral walls and cameras and shit otherwise

	var/can_die = FALSE //Used to prevent instagib/instakill attacks like the wand of death

/mob/living/simple_animal/hostile/megafauna/Life()
	if(health <= 0)
		can_die = TRUE
	..()

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(!can_die)
		return
	else
		feedback_set_details("megafauna_kills","[initial(name)]")
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

