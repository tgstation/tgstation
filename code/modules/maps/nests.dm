
//**************************************************************
// Nests
//**************************************************************

/obj/map/nest
	icon = 'icons/obj/map/nests.dmi'
	var/mob_type = /mob/living/simple_animal/hostile/humanoid/russian
	var/breed_time = 3000
	var/breed_chance = 75
	var/pop = 10
	var/pop_min = 2
	var/pop_max = 30

/obj/map/nest/perform_spawn()

	for(var/i = 1, i <= pop, i++)
		new mob_type(loc)

	spawn()
		ticker()

/obj/map/nest/proc/ticker()
	while(src)
		for(var/mob/M in get_area(src))
			if(istype(M, mob_type))
				pop++
			else pop-- //It's harder with an audience, you understand bb
		if(pop in pop_min to pop_max) //When enough simple animals...
			if(prob(breed_chance)) //Love each other very much...
				new mob_type(loc) //Babby formed!!
		sleep(breed_time)

// Subtypes ////////////////////////////////////////////////////

/obj/map/nest/lizard
	name = "lizard breeding ground"
	icon_state = "lizard"
	mob_type = /mob/living/simple_animal/lizard

/obj/map/nest/mouse
	name = "mouse breeding ground"
	icon_state = "mouse"
	mob_type = /mob/living/simple_animal/mouse
	breed_time = 1200

/obj/map/nest/mouse/limited
	name = "limited mouse breeding ground"
	pop = 4
	pop_max = 4

/obj/map/nest/spider
	name = "spider breeding ground"
	icon_state = "spider"
	mob_type = /mob/living/simple_animal/hostile/giant_spider
	pop_max = 10

/obj/map/nest/carp
	name = "carp breeding ground"
	icon_state = "carp"
	mob_type = /mob/living/simple_animal/hostile/carp
	pop_max = 10

/obj/map/nest/carp/limited
	name = "limited carp breeding ground"
	pop = 2
	pop_max = 2

/obj/map/nest/bear
	name = "bear breeding ground"
	icon_state = "bear"
	mob_type = /mob/living/simple_animal/hostile/carp
	breed_time = 9000
	pop = 5
	pop_max = 5

/obj/map/nest/necrozombie
	name = "necro zombie breeding ground" //Yep
	icon_state = "bear"
	mob_type = /mob/living/simple_animal/hostile/necro/zombie
	breed_time = 9000
	pop = 6
	pop_max = 6
