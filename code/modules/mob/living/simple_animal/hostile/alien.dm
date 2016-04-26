var/list/nest_locations = list()

/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = -1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	species_type = /mob/living/simple_animal/hostile/alien
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	a_intent = I_HURT
	attack_sound = 'sound/weapons/bladeslice.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "alien"
	environment_smash = 2
	status_flags = CANPUSH
	minbodytemp = 0
	heat_damage_per_tick = 20
	treadmill_speed = 4 //Not as insane as it seems, because of their slow default move rate, this is more like a functional 2x human
	var/weed = 45
	var/mob/living/dragging = null
	var/turf/last_loc = null
	var/acid = 200

/mob/living/simple_animal/hostile/alien/Life()
	..()
	var/turf/T = get_turf(src)
	if(weed < 50)
		weed++
		if(locate(/obj/effect/alien/weeds) in T)
			weed += 4
	else if(!stat && !client)
		if(!(locate(/obj/effect/alien/weeds) in T) && !(locate(/obj/structure/bed/nest) in T) && !(locate(/obj/effect/alien/egg) in T) && isturf(src.loc) && !istype(T, /turf/space))
			weed = 0
			visible_message("<span class='alien'>[src] has planted some alien weeds!</span>")
			new /obj/effect/alien/weeds/node(T)

	if(acid < 200)
		acid++

	if(!client)
		if(stance == HOSTILE_STANCE_IDLE)
			var/new_dest = FindNest()
			if(new_dest)
				if(FindPrey())
					MovetoPrey()
					DragPrey(new_dest)
			else
				dragging = null
				if(pulling)
					stop_pulling()
				walk(src, 0)
				stop_automated_movement = 0
				vision_range = idle_vision_range
		else
			dragging = null
			if(pulling)
				stop_pulling()

/mob/living/simple_animal/hostile/alien/DestroySurroundings()
	if(environment_smash)
		EscapeConfinement()
		for(var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if(istype(T, /turf/simulated/wall))
				if(!locate(/obj/effect/alien/acid) in T)
					if(acid >= 200)
						new /obj/effect/alien/acid/hyper(T, T)
						acid = 0
			for(var/atom/A in T)
				if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
					A.attack_animal(src)
				else if(istype(A,/obj/machinery/door))
					var/obj/machinery/door/D = A
					if(D.density && !D.operating)
						D.attack_hand(src)
						if(D.density && !D.operating)
							var/obj/item/weapon/crowbar/CB = new(src)//kek, but it works. Allows aliens to force open doors in unpowered environement thanks to their super strength claws.
							CB.name = "claws"
							CB.force = melee_damage_upper//if it's a windoor, we'll eventually break it down
							D.attackby(CB,src)
							qdel(CB)
	return



/mob/living/simple_animal/hostile/alien/wander_move(var/turf/dest)
	..()
	for(var/obj/machinery/light/L in range(src,1))
		if(L.light_range > 0)
			L.attack_animal(src)

	for(var/obj/machinery/door/D in range(src,1))
		spawn()
			if(D.density && !D.operating)
				D.attack_hand(src)
				if(D.density && !D.operating)
					var/obj/item/weapon/crowbar/CB = new(src)//kek, but it works. Allows aliens to force open doors in unpowered environement thanks to their super strength claws.
					CB.name = "claws"
					CB.force = melee_damage_upper//if it's a windoor, we'll eventually break it down
					D.attackby(CB,src)
					qdel(CB)

/mob/living/simple_animal/hostile/alien/CanAttack(var/atom/the_target)//they don't kill mindless monkeys so they can drag them to nests with a higher chance of a successful impregnation.
	if(istype(the_target,/mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/M = the_target
		if(!M.client)
			return 0

	if(iscarbon(the_target))
		var/mob/living/carbon/C = the_target
		if(C.locked_to && istype(C.locked_to,/obj/structure/bed/nest))
			return 0

	return ..(the_target)

/mob/living/simple_animal/hostile/alien/proc/FindNest()
	if(!nest_locations.len)
		return
	var/smallest_distance = 555
	var/best_nest
	for(var/obj/structure/bed/nest/N in nest_locations)
		if((N.z == src.z) && (N.locked_atoms.len == 0))
			var/dist = get_dist(src,N)
			if(dist < smallest_distance)
				smallest_distance = dist
				best_nest = N

	if(smallest_distance > 30)
		return null
	else
		return best_nest

/mob/living/simple_animal/hostile/alien/proc/FindPrey()
	if(dragging)//if for whatever reason we are trying to drag a mob that another alien is dragging, or that is already placed on a bed, we cut that shit out
		if((dragging.pulledby && istype(dragging.pulledby,/mob/living/simple_animal/hostile/alien) && (dragging.pulledby != src)) || (dragging.locked_to && istype(dragging.locked_to,/obj/structure/bed/nest)))
			dragging = null
			walk(src, 0)
			stop_automated_movement = 0
			vision_range = idle_vision_range
			return
		else
			return dragging
	var/list/Preys = list()
	var/Prey
	for(var/atom/A in ListTargets())
		if(istype(A,/mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = A
			if(!M.client && !M.locked_to && !(M.flags & INVULNERABLE))
				Preys += A
		else if((faction != "neutral") && (istype(A,/mob/living/carbon/monkey) || istype(A,/mob/living/carbon/human)))
			var/mob/living/carbon/C = A
			if(C.stat && !C.locked_to && !(C.flags & INVULNERABLE))
				Preys += A
	if(Preys.len)
		Prey = pick(Preys)
	else
		walk(src, 0)
		stop_automated_movement = 0
		vision_range = idle_vision_range
	dragging = Prey
	return Prey

/mob/living/simple_animal/hostile/alien/proc/MovetoPrey()
	stop_automated_movement = 1
	if(!dragging)
		walk(src, 0)
		stop_automated_movement = 0
		vision_range = idle_vision_range
		return

	if(isturf(loc))
		if(!(dragging.pulledby && istype(dragging.pulledby,/mob/living/simple_animal/hostile/alien) && (dragging.pulledby != src)))
			if(dragging.Adjacent(src))
				if(!pulling && !(dragging.pulledby && istype(dragging.pulledby,/mob/living/simple_animal/hostile/alien) && (dragging.pulledby != src)))
					start_pulling(dragging)
			else if(canmove)
				if(last_loc && (last_loc == loc))
					DestroySurroundings()
				last_loc = loc
				Goto(dragging,move_to_delay,1)
		else//if another alien is dragging them, just leave them alone
			dragging = null
			walk(src, 0)
			stop_automated_movement = 0
			vision_range = idle_vision_range

		return

	walk(src, 0)
	stop_automated_movement = 0
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/alien/proc/DragPrey(var/obj/structure/bed/nest/dest)
	if(dragging && (pulling == dragging))
		if(dest.loc == src.loc)
			dragging.forceMove(dest.loc)
			stop_pulling()
			dest.buckle_mob(dragging,src)
			dragging = null
			walk(src, 0)
			stop_automated_movement = 0
			vision_range = idle_vision_range
		else if(canmove)
			if(last_loc && (last_loc == loc))
				DestroySurroundings()
			last_loc = loc
			Goto(dest,move_to_delay,0)


/mob/living/simple_animal/hostile/alien/proc/CanOpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/poddoor))
		return 0

	// Don't fuck with doors that are doing something
	if(D.operating>0)
		return 0

	// Don't open opened doors.
	if(!D.density)
		return 0

	// Can't open bolted/welded doors
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A=D
		if(A.locked || A.welded || A.jammed)
			return 0

	return 1

/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon_state = "aliend_running"
	icon_living = "aliend_running"
	icon_dead = "aliend_dead"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_dead"
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'


/mob/living/simple_animal/hostile/alien/queen
	name = "alien queen"
	icon_state = "alienq_running"
	icon_living = "alienq_running"
	icon_dead = "alienq_dead"
	health = 250
	maxHealth = 250
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	move_to_delay = 3
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	rapid = 1
	status_flags = 0
	var/nest = 65
	var/egg = 55

/mob/living/simple_animal/hostile/alien/queen/Life()
	..()
	var/turf/T = get_turf(src)
	if(nest < 75)
		nest++
		if(locate(/obj/effect/alien/weeds) in T)
			nest += 4
	else if(!stat && !client)
		if(!(locate(/obj/effect/alien/weeds/node) in T) && !(locate(/obj/structure/bed/nest) in T) && !(locate(/obj/effect/alien/egg) in T) && isturf(src.loc) && !istype(T, /turf/space))
			var/nearby_nests = 0
			for(var/obj/structure/bed/nest/N in range(5,src))
				nearby_nests++
			if(nearby_nests < 2)
				nest = 0
				visible_message("<span class='alien'>\The [src] vomits up a thick purple substance and shapes it into some form of resin structure!</span>")
				new /obj/structure/bed/nest(T)

	if(egg < 75)
		egg++
		if(locate(/obj/effect/alien/weeds) in T)
			egg += 4
	else if(!stat && !client)
		if(!(locate(/obj/effect/alien/weeds/node) in T) && !(locate(/obj/structure/bed/nest) in T) && !(locate(/obj/effect/alien/egg) in T) && isturf(src.loc) && !istype(T, /turf/space))
			var/nearby_eggs = 0
			for(var/obj/effect/alien/egg/E in range(3,src))
				nearby_eggs++
			if(nearby_eggs < 3)
				egg = 0
				visible_message("<span class='alien'>[src] has laid an egg!</span>")
				new /obj/effect/alien/egg(T)

/mob/living/simple_animal/hostile/alien/queen/wander_move(var/turf/dest)
	var/obj/effect/alien/weeds/W = locate() in range(src,3)
	if(W)
		if(locate(/obj/effect/alien/weeds) in range(dest,1))//we want the queen to remain relatively close to the weed-covered area
			..()
	else
		..()

/mob/living/simple_animal/hostile/alien/queen/large
	name = "alien empress"
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "queen_s"
	icon_living = "queen_s"
	icon_dead = "queen_dead"
	move_to_delay = 4
	maxHealth = 400
	health = 400
	pixel_x = -16

/obj/item/projectile/neurotox
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/alien/Die()
	..()
	visible_message("[src] lets out a waning guttural screech, green blood bubbling from its maw...")
	playsound(src, 'sound/voice/hiss6.ogg', 100, 1)

/mob/living/simple_animal/hostile/alien/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-a", sleeptime = 15)
	xgibs(loc, viruses)
	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/hostile/alien/CanAttack(var/atom/the_target)
	if(isalien(the_target))
		return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/alien/adjustBruteLoss(amount,var/damage_type) // Weak to Fire
	if(damage_type == BURN)
		..(amount * 2)
	else
		..(amount)
