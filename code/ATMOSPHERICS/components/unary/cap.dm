
/obj/machinery/atmospherics/unary/cap
	name = "pipe endcap"
	desc = "An endcap for pipes"
	icon = 'icons/obj/pipes.dmi'
	icon_state = "cap"
	level = 2
	layer = 2.4 //under wires with their 2.44
	//volume = 35

	available_colors = list(
		"grey"=PIPE_COLOR_GREY,
		"red"=PIPE_COLOR_RED,
		"blue"=PIPE_COLOR_BLUE,
		"cyan"=PIPE_COLOR_CYAN,
		"green"=PIPE_COLOR_GREEN,
		"yellow"=PIPE_COLOR_YELLOW,
		"purple"=PIPE_COLOR_PURPLE
	)

/obj/machinery/atmospherics/unary/cap/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/unary/cap/update_icon()
	overlays = 0
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	icon_state = "cap"
	return

/obj/machinery/atmospherics/unary/cap/visible
	level = 2
	icon_state = "cap"

/obj/machinery/atmospherics/unary/cap/visible/scrubbers
	name = "Scrubbers cap"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/unary/cap/visible/supply
	name = "Air supply cap"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/unary/cap/visible/supplymain
	name = "Main air supply cap"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/unary/cap/visible/general
	name = "Air supply cap"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/unary/cap/visible/yellow
	name = "Air supply cap"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/unary/cap/visible/filtering
	name = "Air filtering cap"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/unary/cap/visible/cyan
	name = "Air supply cap"
	_color = "cyan"
	color=PIPE_COLOR_CYAN

/obj/machinery/atmospherics/unary/cap/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/unary/cap/hidden/scrubbers
	name = "Scrubbers cap"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/unary/cap/hidden/supply
	name = "Air supply cap"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/unary/cap/hidden/supplymain
	name = "Main air supply cap"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/unary/cap/hidden/general
	name = "Air supply cap"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/unary/cap/hidden/yellow
	name = "Air supply cap"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/unary/cap/hidden/filtering
	name = "Air filtering cap"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/unary/cap/hidden/cyan
	name = "Air supply cap"
	_color = "cyan"
	color=PIPE_COLOR_CYAN


/obj/machinery/atmospherics/unary/cap/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/pipe_dispenser) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.

	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/red))
		src._color = "red"
		src.color = PIPE_COLOR_RED
		user << "\red You paint the pipe red."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src._color = "blue"
		src.color = PIPE_COLOR_BLUE
		user << "\red You paint the pipe blue."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src._color = "green"
		src.color = PIPE_COLOR_GREEN
		user << "\red You paint the pipe green."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src._color = "yellow"
		src.color = PIPE_COLOR_YELLOW
		user << "\red You paint the pipe yellow."
		update_icon()
		return 1

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()

	var/turf/T = get_turf(src)
	//if (level==1 && isturf(T) && T.intact)
	//	user << "\red You must remove the plating first."
	//	return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = T.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
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
