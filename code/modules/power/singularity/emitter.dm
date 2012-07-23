//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine)

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300

	var/active = 0
	var/fire_delay = 100
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0


	verb/rotate()
		set name = "Rotate"
		set category = "Object"
		set src in oview(1)

		if (src.anchored || usr:stat)
			usr << "It is fastened to the floor!"
			return 0
		src.dir = turn(src.dir, 90)
		return 1


	New()
		..()
		return

	Del()
		investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
		..()

	update_icon()
		if (active && !(stat & (NOPOWER|BROKEN)))
			icon_state = "emitter_+a"
		else
			icon_state = "emitter"


	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if(state == 2)
			if(!src.locked)
				if(src.active==1)
					src.active = 0
					user << "You turn off the [src]."
					src.use_power = 1
					investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")
				else
					src.active = 1
					user << "You turn on the [src]."
					src.shot_number = 0
					src.fire_delay = 100
					src.use_power = 2
					investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")
				update_icon()
			else
				user << "\red The controls are locked!"
		else
			user << "\red The [src] needs to be firmly secured to the floor first."
			return 1


	emp_act(var/severity)//Emitters are hardened but still might have issues
		use_power(50)
		if((severity == 1)&&prob(1)&&prob(1))
			if(src.active)
				src.active = 0
				src.use_power = 1
		return 1


	process()
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
			var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
			playsound(src.loc, 'emitter.ogg', 25, 1)
			if(prob(35))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
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


	attackby(obj/item/W, mob/user)

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
						"You hear a ratchet")
					src.anchored = 1
				if(1)
					state = 0
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
						"You undo the external reinforcing bolts.", \
						"You hear a ratchet")
					src.anchored = 0
				if(2)
					user << "\red The [src.name] needs to be unwelded from the floor."
			return

		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(active)
				user << "Turn off the [src] first."
				return
			switch(state)
				if(0)
					user << "\red The [src.name] needs to be wrenched to the floor."
				if(1)
					if (WT.remove_fuel(0,user))
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
							"You start to weld the [src] to the floor.", \
							"You hear welding")
						if (do_after(user,20))
							if(!src || !WT.isOn()) return
							state = 2
							user << "You weld the [src] to the floor."
					else
						user << "\red You need more welding fuel to complete this task."
				if(2)
					if (WT.remove_fuel(0,user))
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
							"You start to cut the [src] free from the floor.", \
							"You hear welding")
						if (do_after(user,20))
							if(!src || !WT.isOn()) return
							state = 1
							user << "You cut the [src] free from the floor."
					else
						user << "\red You need more welding fuel to complete this task."
			return

		if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
			if(emagged)
				user << "\red The lock seems to be broken"
				return
			if(src.allowed(user))
				if(active)
					src.locked = !src.locked
					user << "The controls are now [src.locked ? "locked." : "unlocked."]"
				else
					src.locked = 0 //just in case it somehow gets locked
					user << "\red The controls can only be locked when the [src] is online"
			else
				user << "\red Access denied."
			return


		if(istype(W, /obj/item/weapon/card/emag) && !emagged)
			locked = 0
			emagged = 1
			user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
			return

		..()
		return


	power_change()
		..()
		update_icon()
		return
