/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	var/id_tag = null
	var/on = 1.0
	var/obj/item/device/assembly_holder/assembly=null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/igniter/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/igniter/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)
	return

/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	use_power(50)
	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if (src.on && !(stat & NOPOWER) )
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1,surfaces=0)
	return 1

/obj/machinery/igniter/proc/toggle_state()
	use_power(50)
	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/New()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"

/obj/machinery/igniter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && src.assembly)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
			user << "\blue You begin to cut \the [src] off the floor..."
			if (do_after(user, 40))
				user.visible_message( \
					"[user] disassembles \the [src].", \
					"\blue You have disassembled \the [src].", \
					"You hear welding.")
				src.assembly.loc=src.loc
				del(src)
				return
		else:
			user << "\red You need more welder fuel to do that."
			return 1


// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id_tag = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = 1

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/sparker/New()
	..()

/obj/machinery/sparker/power_change()
	if ( powered() && disable == 0 )
		stat &= ~NOPOWER
		icon_state = "[base_state]"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]-p"
//		src.sd_SetLuminosity(0)

/obj/machinery/sparker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (istype(W, /obj/item/weapon/screwdriver))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disabled the [src]!", "\red You disable the connection to the [src].")
			icon_state = "[base_state]-d"
		if (!src.disable)
			user.visible_message("\red [user] has reconnected the [src]!", "\red You fix the connection to the [src].")
			if(src.powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if (src.anchored)
		return src.spark()
	else
		return

/obj/machinery/sparker/proc/spark()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[base_state]-spark", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	src.last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1,surfaces=0)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	spark()
	..(severity)

/obj/machinery/ignition_switch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attackby(obj/item/weapon/W, mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in world)
		if (M.id_tag == src.id_tag)
			spawn( 0 )
				M.spark()

	for(var/obj/machinery/igniter/M in world)
		if(M.id_tag == src.id_tag)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return