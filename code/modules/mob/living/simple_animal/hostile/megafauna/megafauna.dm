/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = "harm"
	sentience_type = SENTIENCE_BOSS
	environment_smash = 4
	weather_immunities = list("lava","ash")
	robust_searching = 1
	stat_attack = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	layer = MOB_LAYER + 0.5 //Looks weird with them slipping under mineral walls and cameras and shit otherwise

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0)
		return
	else
		feedback_set_details("megafauna_kills","[initial(name)]")
		..()

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust()
	if(health > 0)
		return
	else
		..()

