
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
	response_harm   = "hits"
	stop_automated_movement_when_pulled = 0
	maxHealth = 75 // Was 200
	health = 75 // 150/2
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	var/poison_per_bite = 5
	var/poison_type = "toxin"
	faction = "spiders"
	var/busy = 0
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 3

//nursemaids - these create webs and eggs
// Slower
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 10
	var/atom/cocoon_target
	poison_type = "stoxin"
	speed=2.5
	var/fed = 0

//hunters have the most poison and move the fastest, so they can find prey
// THEY CAN ALSO OPEN DOORS OH GOD
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 60 // Was 120
	health = 60
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	speed=-1
	//var/target=null

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
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
/mob/living/simple_animal/hostile/giant_spider/hunter/Life()
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			if(!busy && prob(40)) // Pick a door and rape it
				var/list/doors = list()
				for(var/obj/machinery/door/O in oview(src, 7))
					// Skip some door types
					if(istype(O,/obj/machinery/door/poddoor))
						continue
					doors+=O
				if(doors.len>0)
					for(var/i=0;i<doors.len;i++)
						var/obj/machinery/door/D = pick(doors)
						if(D.density==1) // Closed
							busy=MOVING_TO_TARGET
							Goto(D, move_to_delay)
							target=D
							GiveUp(D)
							return
			if(busy)
				if(busy == MOVING_TO_TARGET && target)
					var/obj/machinery/door/D = target
					if(D.density==1)
						if(get_dist(src, target) > 1)
							return // keep movin'.
						stop_automated_movement = 1
						walk(src,0)
						D.visible_message("\red \the [D]'s motors whine as four arachnid claws begin trying to force it open!")
						spawn(50)
							if(prob(25))
								D.open(1)
								D.visible_message("\red \the [src] forces \the [D] open!")
					busy = 0
					stop_automated_movement = 0


/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/giant_spider/hunter/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(target == C && get_dist(src,target) > 1)
				target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat && !istype(C,/mob/living/simple_animal/hostile/giant_spider))
						cocoon_target = C
						busy = MOVING_TO_TARGET
						Goto(C, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return

				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					busy = SPINNING_WEB
					src.visible_message("\blue \the [src] begins to secrete a sticky substance.")
					stop_automated_movement = 1
					spawn(40)
						if(busy == SPINNING_WEB)
							W = locate() in get_turf(src)
							if(!W)
								new /obj/effect/spider/stickyweb(src.loc)
							busy = 0
							stop_automated_movement = 0
				else
					//third, lay an egg cluster there
					var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
					if(!E && fed > 0)
						busy = LAYING_EGGS
						src.visible_message("\blue \the [src] begins to lay a cluster of eggs.")
						stop_automated_movement = 1
						spawn(50)
							if(busy == LAYING_EGGS)
								E = locate() in get_turf(src)
								if(!E)
									new /obj/effect/spider/eggcluster(src.loc)
									fed--
								busy = 0
								stop_automated_movement = 0
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)

							if(istype(O,/obj/machinery/door))
								if(O.density) // Closed? Skip it.
									continue
								// Skip some door types
								if(istype(O,/obj/machinery/door/poddoor))
									continue
								// Jammed? Skippit.
								if(locate(/obj/effect/spider/stickyweb) in get_turf(O))
									continue
							else
								if(O.anchored)
									continue

							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
								// Quit breaking shit you can't break.
								//if(istype(O,/obj/structure/window) && O:godmode==1)
								//	continue
								// Skip things we can't wrap
								if(istype(O, /mob/living/simple_animal/hostile/giant_spider))
									continue
								cocoon_target = O
								busy = MOVING_TO_TARGET
								stop_automated_movement = 1
								Goto(O, move_to_delay)
								//give up if we can't reach them after 10 seconds
								GiveUp(O)

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					if(istype(cocoon_target, /mob/living/simple_animal/hostile/giant_spider))
						busy=0
						stop_automated_movement=0
					busy = SPINNING_COCOON
					src.visible_message("\blue \the [src] begins to secrete a sticky substance around \the [cocoon_target].")
					stop_automated_movement = 1
					walk(src,0)
					spawn(50)
						if(busy == SPINNING_COCOON)
							if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
								if(istype(cocoon_target,/obj/machinery/door))
									var/obj/machinery/door/D=cocoon_target
									var/obj/effect/spider/stickyweb/W = locate() in get_turf(cocoon_target)
									if(!W)
										src.visible_message("\red \the [src] jams \the [cocoon_target] open with web!")
										W=new /obj/effect/spider/stickyweb(cocoon_target.loc)
										// Jam the door open with webs
										D.jammed=W
									busy = 0
									stop_automated_movement = 0
								else
									var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
									var/large_cocoon = 0
									C.pixel_x = cocoon_target.pixel_x
									C.pixel_y = cocoon_target.pixel_y
									for(var/mob/living/M in C.loc)
										if(istype(M, /mob/living/simple_animal/hostile/giant_spider))
											continue
										large_cocoon = 1
										fed++
										src.visible_message("\red \the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.")
										M.loc = C
										C.pixel_x = M.pixel_x
										C.pixel_y = M.pixel_y
										break
									for(var/obj/item/I in C.loc)
										I.loc = C
									for(var/obj/structure/S in C.loc)
										if(!S.anchored)
											S.loc = C
											large_cocoon = 1
									for(var/obj/machinery/M in C.loc)
										if(!M.anchored)
											M.loc = C
											large_cocoon = 1
									if(large_cocoon)
										C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
							busy = 0
							stop_automated_movement = 0

		else
			busy = 0
			stop_automated_movement = 0

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON