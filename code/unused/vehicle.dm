/obj/machinery/vehicle
	name = "Vehicle Pod"
	icon = 'escapepod.dmi'
	icon_state = "podfire"
	density = 1
	flags = FPRINT
	anchored = 1.0
	var/speed = 10.0
	var/maximum_speed = 10.0
	var/can_rotate = 1
	var/can_maximize_speed = 0
	var/one_person_only = 0
	use_power = 0

/obj/machinery/vehicle/pod
	name = "Escape Pod"
	desc = "A pod, for, moving in space"
	icon = 'escapepod.dmi'
	icon_state = "pod"
	can_rotate = 0
	var/id = 1.0

/obj/machinery/vehicle/recon
	name = "Reconaissance Pod"
	desc = "A fast moving pod."
	icon = 'escapepod.dmi'
	icon_state = "recon"
	speed = 1.0
	maximum_speed = 30.0
	can_maximize_speed = 1
	one_person_only = 1


/obj/machinery/vehicle/process()
	if (src.speed)
		if (src.speed <= 10)
			var/t1 = 10 - src.speed
			while(t1 > 0)
				step(src, src.dir)
				sleep(1)
				t1--
		else
			var/t1 = round(src.speed / 5)
			while(t1 > 0)
				step(src, src.dir)
				t1--
	return

/obj/machinery/vehicle/meteorhit(var/obj/O as obj)
	for (var/obj/item/I in src)
		I.loc = src.loc

	for (var/mob/M in src)
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
	del(src)

/obj/machinery/vehicle/ex_act(severity)
	switch (severity)
		if (1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			//SN src = null
			del(src)
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				//SN src = null
				del(src)

/obj/machinery/vehicle/blob_act()
	for(var/atom/movable/A as mob|obj in src)
		A.loc = src.loc
	del(src)

/obj/machinery/vehicle/Bump(var/atom/A)
	//world << "[src] bumped into [A]"
	spawn (0)
		..()
		src.speed = 0
		return
	return

/obj/machinery/vehicle/relaymove(mob/user as mob, direction)
	if (user.stat)
		return

	if ((user in src))
		if (direction & 1)
			src.speed = max(src.speed - 1, 1)
		else if (direction & 2)
			src.speed = min(src.maximum_speed, src.speed + 1)
		else if (src.can_rotate && direction & 4)
			src.dir = turn(src.dir, -90.0)
		else if (src.can_rotate && direction & 8)
			src.dir = turn(src.dir, 90)
		else if (direction & 16 && src.can_maximize_speed)
			src.speed = src.maximum_speed

/obj/machinery/vehicle/verb/eject()
	set src = usr.loc

	if (usr.stat)
		return

	var/mob/M = usr
	M.loc = src.loc
	if (M.client)
		M.client.eye = M.client.mob
		M.client.perspective = MOB_PERSPECTIVE
	step(M, turn(src.dir, 180))
	return

/obj/machinery/vehicle/verb/board()
	set src in oview(1)

	if (usr.stat)
		return

	if (src.one_person_only && locate(/mob, src))
		usr << "There is no room! You can only fit one person."
		return

	var/mob/M = usr
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src

	M.loc = src

/obj/machinery/vehicle/verb/unload(var/atom/movable/A in src)
	set src in oview(1)

	if (usr.stat)
		return

	if (istype(A, /atom/movable))
		A.loc = src.loc
		for(var/mob/O in view(src, null))
			if ((O.client && !(O.blinded)))
				O << text("\blue <B> [] unloads [] from []!</B>", usr, A, src)

		if (ismob(A))
			var/mob/M = A
			if (M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = M

/obj/machinery/vehicle/verb/load()
	set src in oview(1)

	if (usr.stat)
		return

	if (((istype(usr, /mob/living/carbon/human)) && (!(ticker) || (ticker && ticker.mode != "monkey"))))
		var/mob/living/carbon/human/H = usr

		if ((H.pulling && !(H.pulling.anchored)))
			if (src.one_person_only && !(istype(H.pulling, /obj/item/weapon)))
				usr << "You may only place items in."
			else
				H.pulling.loc = src
				if (ismob(H.pulling))
					var/mob/M = H.pulling
					if (M.client)
						M.client.perspective = EYE_PERSPECTIVE
						M.client.eye = src

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O << text("\blue <B> [] loads [] into []!</B>", H, H.pulling, src)

				H.stop_pulling()


/obj/machinery/vehicle/space_ship
	icon = 'escapepod.dmi'
	icon_state = "pod"
	var/datum/global_iterator/space_ship_inertial_movement/pr_inertial_movement
	var/datum/global_iterator/space_ship_speed_increment/pr_speed_increment
	var/last_relay = 0
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/health = 100
	var/datum/effects/system/spark_spread/spark_system = new

	New()
		..()
		internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
		pr_inertial_movement = new /datum/global_iterator/space_ship_inertial_movement(list(src),0)
		pr_speed_increment = new /datum/global_iterator/space_ship_speed_increment(list(src),0)
		src.spark_system.set_up(2, 0, src)
		src.spark_system.attach(src)
		return

	proc/inspace()
		if(istype(src.loc, /turf/space))
			return 1
		return 0

	remove_air(amount)
		if(src.internal_tank)
			return src.internal_tank.air_contents.remove(amount)
		else
			var/turf/T = get_turf(src)
			return T.remove_air(amount)

	return_air()
		if(src.internal_tank)
			return src.internal_tank.return_air()
		return

	proc/return_pressure()
		if(src.internal_tank)
			return src.internal_tank.return_pressure()
		return 0

	proc/return_temperature()
		if(src.internal_tank)
			return src.internal_tank.return_temperature()
		return 0

	Bump(var/atom/movable/A)
		if(istype(A))
			step(A, src.dir)
		else
			if(pr_inertial_movement.cur_delay<2)
				take_damage(25)
			pr_speed_increment.stop()
			pr_inertial_movement.stop()
		return

	proc/take_damage(value)
		if(isnum(value))
			src.health -= value
			if(src.health>0)
				src.spark_system.start()
//				world << "[src] health is [health]"
			else
				src.ex_act(1)
		return

	process()
		return

	proc/get_desired_speed()
		return (pr_inertial_movement.max_delay-pr_inertial_movement.desired_delay)/(pr_inertial_movement.max_delay-pr_inertial_movement.min_delay)*100

	proc/get_current_speed()
		return (pr_inertial_movement.max_delay-pr_inertial_movement.cur_delay)/(pr_inertial_movement.max_delay-pr_inertial_movement.min_delay)*100

/obj/machinery/vehicle/space_ship/relaymove(mob/user as mob, direction)
	spawn()
		if (user.stat || world.time-last_relay<2)
			return
		last_relay = world.time
		var/speed_change = 0
		if(direction & NORTH)
			pr_inertial_movement.desired_delay = between(pr_inertial_movement.min_delay, pr_inertial_movement.desired_delay-1, pr_inertial_movement.max_delay)
			speed_change = 1
		else if (direction & SOUTH)
			pr_inertial_movement.desired_delay = between(pr_inertial_movement.min_delay, pr_inertial_movement.desired_delay+1, pr_inertial_movement.max_delay)
			speed_change = 1
		else if (src.can_rotate && direction & 4)
			src.dir = turn(src.dir, -90.0)
		else if (src.can_rotate && direction & 8)
			src.dir = turn(src.dir, 90)
		if(speed_change)
//			user << "Desired speed: [get_desired_speed()]%"
			src.pr_speed_increment.start()
			src.pr_inertial_movement.start()
	return

//should try two directional iterator datums, one for vertical, one for horizontal movement.
/datum/global_iterator/space_ship_inertial_movement
	delay = 1
	var/min_delay = 0
	var/max_delay = 15
	var/desired_delay
	var/cur_delay
	var/last_move

	New()
		..()
		desired_delay = max_delay
		cur_delay = max_delay

	stop()
		src.cur_delay = max_delay
		src.desired_delay = max_delay
		return ..()

	process(var/obj/machinery/vehicle/space_ship/SS as obj)
		if(cur_delay >= max_delay)
			return src.stop()
		if(world.time - last_move < cur_delay)
			return
		last_move = world.time
/*
		if(src.delay>=SS.max_delay)
			return src.stop()
*/
		if(!step(SS, SS.dir) || !SS.inspace())
			src.stop()
		return

	proc/set_desired_delay(var/num as num)
		src.desired_delay = num
		return

/datum/global_iterator/space_ship_speed_increment
	delay = 5

	process(var/obj/machinery/vehicle/space_ship/SS as obj)
		if(SS.pr_inertial_movement.desired_delay!=SS.pr_inertial_movement.cur_delay)
			var/delta = SS.pr_inertial_movement.desired_delay - SS.pr_inertial_movement.cur_delay
			SS.pr_inertial_movement.cur_delay += delta>0?1:-1
/*
			for(var/mob/M in SS)
				M << "Current speed: [SS.get_current_speed()]"
*/
		else
			src.stop()
		return
