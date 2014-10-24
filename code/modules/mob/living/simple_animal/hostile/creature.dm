/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"
	speed = 4

/mob/living/simple_animal/hostile/creature/cult
	faction = "cult"
	var/shuttletarget = null
	var/enroute = 0

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/creature/cult/Life()
	..()
	if(emergency_shuttle.location == 1)
		if(!enroute && !target)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget || (get_dist(src, shuttletarget) >= 2))
				shuttletarget = pick(get_area_turfs(locate(/area/hallway/secondary/exit)))
			enroute = 1
			stop_automated_movement = 1
			spawn()
				if(!src.stat)
					horde()

		if(get_dist(src, shuttletarget) <= 2)		//The monster reached the escape hallway
			enroute = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/creature/cult/proc/horde()
	var/turf/T = get_step_to(src, shuttletarget)
	for(var/atom/A in T)
		if(istype(A,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = A
			if(D.density && !D.locked && !D.welded)
				D.open()
		else if(istype(A,/obj/structure/mineral_door))
			var/obj/machinery/door/D = A
			if(D.density)
				D.open()
		else if(istype(A,/obj/structure/cult/pylon))
			A.attack_animal(src)
		else if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
			A.attack_animal(src)
	Move(T)
	var/new_target = FindTarget()
	GiveTarget(new_target)
	if(!target || enroute)
		spawn(10)
			if(!src.stat)
				horde()