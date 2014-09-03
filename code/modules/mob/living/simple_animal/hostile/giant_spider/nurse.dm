//nursemaids - these create webs and eggs
// Slower
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	maxHealth = 75 // 40
	health = 75
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 10
	poison_type = "stoxin"
	speed=2.5
	var/fed = 0
	var/atom/cocoon_target

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
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
				// If there IS web and we've been fed...
				else if(fed > 0)
					//third, lay an egg cluster there
					var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
					if(!E)
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
				// If we've got eggs, don't do anything but attack and lay eggs.
				if(fed>0)
					return
				//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
				for(var/obj/O in can_see)

					if(istype(O,/obj/machinery/door))
						var/obj/machinery/door/D=O
						if(D.density)
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