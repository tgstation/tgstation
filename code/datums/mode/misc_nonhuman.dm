///*=====================================SLAUGHTER DEMON=====================================*
/datum/role/slaughter_demon
	name = "slaughter demon"
	id = "slaughter"
	threat = 20 //wip
	default_form = /mob/living/simple_animal/slaughter

///*======================================HACKED DRONE=======================================*
/datum/role/hacked_drone
	name = "hacked drone"
	id = "freedrone"
	threat = 10 //wip
	default_form = /mob/living/simple_animal/drone

/datum/role/hacked_drone/enpower()
	if(isdrone(owner.current))
		var/mob/living/simple_animal/drone/D = owner.current
		D.update_drone_hack(1)
	..()

/datum/role/hacked_drone/depower()
	if(isdrone(owner.current))
		var/mob/living/simple_animal/drone/D = owner.current
		D.update_drone_hack(0)
	..()