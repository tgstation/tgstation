var/global/list/spider_types = typesof(/mob/living/simple_animal/hostile/giant_spider)

#define SPIDER_MAX_PRESSURE_DIFF 50

#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4
#define OPEN_DOOR 5

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/spidermeat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement_when_pulled = 0
	maxHealth = 200 // Was 75
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	faction = "spiders"
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 3
	attack_sound = 'sound/weapons/spiderlunge.ogg'

	wanted_objects = list(
		/obj/machinery/bot,          // Beepsky and friends
		/obj/machinery/light,        // Bust out lights
	)
	search_objects = 1 // Consider objects when searching.  Set to 0 when attacked
	wander = 1
	ranged = 0
	//minimum_distance = 1

	var/icon_aggro = null // for swapping to when we get aggressive
	var/busy = 0
	var/poison_per_bite = 5
	var/poison_type = "toxin"

	//Spider aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

// Checks pressure here vs. around us.
/mob/living/simple_animal/hostile/giant_spider/proc/performPressureCheck(var/turf/loc)
	var/turf/simulated/lT=loc
	if(!istype(lT) || !lT.zone)
		return 0
	var/datum/gas_mixture/myenv=lT.return_air()
	var/pressure=myenv.return_pressure()

	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			var/pdiff = abs(pressure - environment.return_pressure())
			if(pdiff > SPIDER_MAX_PRESSURE_DIFF)
				return pdiff
	return 0

//Can we actually attack a possible target?
/mob/living/simple_animal/hostile/giant_spider/CanAttack(var/atom/the_target)
	if(istype(the_target,/mob/living/simple_animal/hostile/giant_spider))
		return 0
	if(istype(the_target,/obj/machinery/door))
		return CanOpenDoor(the_target)
	if(istype(the_target,/obj/machinery/light))
		var/obj/machinery/light/L = the_target
		// Not empty or broken
		return L.status != 1 && L.status != 2
	return ..(the_target)

/mob/living/simple_animal/hostile/giant_spider/proc/CanOpenDoor(var/obj/machinery/door/D)
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

	var/turf/T = get_turf(D)

	// Don't kill ourselves
	if(!performPressureCheck(T))
		return 0

	return 1

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
	if(istype(target,/obj/structure/window))
		var/obj/structure/window/W=target
		if(get_dist(src, target) > 1)
			return // keep movin'.

		var/turf/T = get_turf(W)

		// Don't kill ourselves
		if(performPressureCheck(T))
			return

	if(istype(target,/obj/machinery/door))
		var/obj/machinery/door/D = target
		if(CanOpenDoor(D))
			if(get_dist(src, target) > 1)
				return // keep movin'.
			stop_automated_movement = 1
			walk(src,0)
			D.visible_message("\red \The [D]'s motors whine as four arachnid claws begin trying to force it open!")
			spawn(50)
				if(CanOpenDoor(D) && prob(25))
					D.open(1)
					D.visible_message("\red \The [src] forces \the [D] open!")

					// Open firedoors, too.
					for(var/obj/machinery/door/firedoor/FD in D.loc)
						if(FD && FD.density)
							FD.open(1)

					// Reset targetting
					busy = 0
					stop_automated_movement = 0
					target=null
			return
		busy = 0
		stop_automated_movement = 0
		return
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if(prob(poison_per_bite))
				src.visible_message("\red \the [src] injects a powerful toxin!")
				L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/giant_spider/Life()
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			//1% chance to skitter madly away
			if(!busy && prob(1))
				/*var/list/move_targets = list()
				for(var/turf/T in orange(20, src))
					move_targets.Add(T)*/
				stop_automated_movement = 1
				Goto(pick(orange(20, src)), move_to_delay)
				spawn(50)
					stop_automated_movement = 0
					walk(src,0)
				return 1

/mob/living/simple_animal/hostile/giant_spider/Aggro()
	..()
	if(icon_aggro)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/giant_spider/LoseAggro()
	..()
	if(icon_aggro)
		icon_state = icon_living

/mob/living/simple_animal/hostile/giant_spider/admin
	faction = "admin"