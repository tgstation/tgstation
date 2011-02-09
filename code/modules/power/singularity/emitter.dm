/obj/machinery/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser"
	icon = 'singularity.dmi'
	icon_state = "Emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine)
	var/active = 0
	var/fire_delay = 100
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300


/obj/machinery/emitter/New()
	..()
	return


/obj/machinery/emitter/update_icon()
	if (active && !(stat & (NOPOWER|BROKEN)))
		icon_state = "Emitter +a"
	else
		icon_state = "Emitter"


/obj/machinery/emitter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(state == 2)
		if(!src.locked || istype(user, /mob/living/silicon))
			if(src.active==1)
				src.active = 0
				user << "You turn off the [src]."
				src.use_power = 1
			else
				src.active = 1
				user << "You turn on the [src]."
				src.shot_number = 0
				src.fire_delay = 100
				src.use_power = 2
			update_icon()
		else
			user << "The controls are locked!"
	else
		user << "The [src] needs to be firmly secured to the floor first."
		return 1

/obj/machinery/emitter/emp_act()//Emitters are hardened but still might have issues
	use_power(50)
	if(prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1
	return 1


/obj/machinery/emitter/process()

	if(stat & (NOPOWER|BROKEN))
		return

	if(src.state != 2)
		src.active = 0
		return

	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))
		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(20,100)
			src.shot_number = 0

		use_power(1000)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser( src.loc )
		A.icon_state = "u_laser"
		playsound(src.loc, 'emitter.ogg', 75, 1)

		if(prob(35))
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		A.dir = src.dir
		if(src.dir == 1)//Up
			A.yo = 20
			A.xo = 0

		else if(src.dir == 2)//Down
			A.yo = -20
			A.xo = 0

		else if(src.dir == 4)//Right
			A.yo = 0
			A.xo = 20

		else if(src.dir == 8)//Left
			A.yo = 0
			A.xo = -20

		else // Any other
			A.yo = -20
			A.xo = 0

		A.process()


/obj/machinery/emitter/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "Turn off the [src] first."
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear ratchet")
				src.anchored = 0
			if(2)
				user << "\red The [src.name] needs to be unwelded from the floor."
				return

	else if(istype(W, /obj/item/weapon/weldingtool))
		if(active)
			user << "Turn off the [src] first."
			return
		switch(state)
			if(0)
				user << "\red The [src.name] needs to be wrenched to the floor."
				return
			if(1)
				if (W:remove_fuel(2))
					playsound(src.loc, 'Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20))
						state = 2
						user << "You weld the [src] to the floor."
				else
					user << "\blue You need more welding fuel to complete this task."
					return
			if(2)
				if (W:remove_fuel(2))
					playsound(src.loc, 'Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20))
						state = 1
						user << "You cut the [src] free from the floor."
				else
					user << "\blue You need more welding fuel to complete this task."
					return
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."
			return
	else
		..()
		return


/obj/machinery/emitter/power_change()
	..()
	update_icon()