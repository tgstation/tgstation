
//**************************************************************
// Nests
//**************************************************************

/obj/map/nest
	icon = 'icons/obj/map/nests.dmi'
	var/mobType = /mob/living/simple_animal/hostile/russian
	var/breedTime = 3000
	var/breedChance = 75
	var/pop = 10
	var/popMin = 2
	var/popMax = 30

/obj/map/nest/New()
	for(src.pop,src.pop,src.pop--)
		new src.mobType(src.loc)
	spawn() src.ticker()
	return

/obj/map/nest/proc/ticker()
	while(src)
		for(var/mob/M in get_area(src)) 
			if(istype(M,src.mobType)) src.pop++
			else src.pop-- //It's harder with an audience, you understand bb
		if(src.pop in src.popMin to src.popMax) //When enough simple animals...
			if(prob(src.breedChance)) //Love each other very much...
				new src.mobType(src.loc) //Babby formed!!
		sleep(src.breedTime)
	return

// Subtypes ////////////////////////////////////////////////////

/obj/map/nest/lizard
	name = "lizard breeding ground"
	icon_state = "lizard"
	mobType = /mob/living/simple_animal/lizard

/obj/map/nest/mouse
	name = "mouse breeding ground"
	icon_state = "mouse"
	mobType = /mob/living/simple_animal/mouse
	breedTime = 1200
	
/obj/map/nest/spider
	name = "spider breeding ground"
	icon_state = "spider"
	mobType = /mob/living/simple_animal/hostile/giant_spider
	popMax = 10
	
/obj/map/nest/carp
	name = "carp breeding ground"
	icon_state = "carp"
	mobType = /mob/living/simple_animal/hostile/carp
	popMax = 10

/obj/map/nest/bear
	name = "bear breeding ground"
	icon_state = "bear"
	mobType = /mob/living/simple_animal/hostile/carp
	breedTime = 9000
	popMax = 5
