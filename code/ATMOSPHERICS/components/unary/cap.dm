
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
		user << "<span class='warning'>You paint the pipe red.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src._color = "blue"
		src.color = PIPE_COLOR_BLUE
		user << "<span class='warning'>You paint the pipe blue.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src._color = "green"
		src.color = PIPE_COLOR_GREEN
		user << "<span class='warning'>You paint the pipe green.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src._color = "yellow"
		src.color = PIPE_COLOR_YELLOW
		user << "<span class='warning'>You paint the pipe yellow.</span>"
		update_icon()
		return 1

	return ..()
