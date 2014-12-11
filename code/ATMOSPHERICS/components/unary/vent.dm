/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"
	name = "Vent"
	desc = "A large air vent"
	level = 1
	var/volume = 250
	dir = SOUTH
	initialize_directions = SOUTH
	var/build_killswitch = 1

/obj/machinery/atmospherics/unary/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/unary/vent/New()
	..()
	air_contents.volume=volume

/obj/machinery/atmospherics/unary/vent/process()
	..()

	CHECK_DISABLED(vents)
	if (!node)
		return // Turning off the vent is a PITA. - N3X

	// New GC does this sometimes
	if(!loc) return

	//air_contents.mingle_with_turf(loc)

	var/datum/gas_mixture/removed = air_contents.remove(volume)

	loc.assume_air(removed)


/obj/machinery/atmospherics/unary/vent/update_icon()
	if(node)
		icon_state = "intact"
		//dir = get_dir(src, node)

	else
		icon_state = "exposed"


/obj/machinery/atmospherics/unary/vent/initialize()
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/hide(var/i)
	if(node)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		dir = get_dir(src, node)
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/unary/vent/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	if(pipe)
		dir = pipe.dir
		initialize_directions = pipe.get_pipe_dir()
		if (pipe.pipename)
			name = pipe.pipename
	else
		initialize_directions = dir
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize()
	build_network()
	if (node)
		node.initialize()
		node.build_network()
	return 1

/obj/machinery/atmospherics/unary/vent/attackby(var/obj/item/weapon/W, var/mob/user)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = T.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		user << "\red You cannot remove this [src], it too exerted due to internal pressure."
		add_fingerprint(user)
		return 1
	playsound(T, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/pipe(T, make_from=src)
		del(src)