#define PIPE_BINARY		0
#define PIPE_BENT		1
#define PIPE_TRINARY	2
#define PIPE_TRIN_M		3
#define PIPE_UNARY		4

//UTILITIES.

/datum/rcd_schematic/decon_pipes
	name		= "Eat pipes"
	category	= "Utilities"
	flags		= RCD_RANGE

/datum/rcd_schematic/decon_pipes/attack(var/atom/A, var/mob/user)
	if(!istype(A, /atom/movable))
		return 1

	var/atom/movable/AM = A

	if(!is_type_in_list(AM, list(/obj/item/pipe, /obj/item/pipe_meter, /obj/item/pipe_gsensor, /obj/structure/disposalconstruct)))
		return 1

	user << "Destroying Pipe..."
	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, AM, 5))
		return 1

	if(!AM)
		return 1

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)

	if(istype(AM, /obj/item/pipe))
		returnToPool(A)
	else
		qdel(AM)

/datum/rcd_schematic/paint_pipes
	name		= "Paint pipes"
	category	= "Utilities"
	flags		= RCD_RANGE

	var/list/available_colors = list(
		"grey"		= "#CCCCCC",
		"red"		= "#800000",
		"blue"		= "#000080",
		"cyan"		= "#1C94C4",
		"green"		= "#00CC00",
		"yellow"	= "#FFCC00",
		"purple"	= "purple"
	)

	var/selected_color = "grey"

/datum/rcd_schematic/paint_pipes/New(var/obj/item/device/rcd/n_master)
	. = ..()

	if(!master || !master.interface)
		return

	//Add the colour CSS defines to the master's interface's HEAD.
	var/color_css

	for(var/color_name in available_colors)
		var/color = available_colors[color_name]
		color_css += {"
			a.color.[color_name] {
				color: [color];
			}
			a.color.[color_name]:hover {
				border:1px solid [color];
			}
			a.color.[color_name].selected {
				background-color: [color];
			}
		"}

	master.interface.head += "<style type='text/css'>[color_css]</style>"

/datum/rcd_schematic/paint_pipes/deselect(var/mob/user, var/datum/rcd_schematic/new_schematic)
	. = ..()

	selected_color = available_colors[1]

/datum/rcd_schematic/paint_pipes/get_HTML()
	for(var/color_name in available_colors)
		var/selected = ""
		if(color_name == selected_color)
			selected = " selected"

		. += "<a class='color [color_name][selected]' href='?src=\ref[master.interface];set_color=[color_name]'>&bull;</a>"

/datum/rcd_schematic/paint_pipes/attack(var/atom/A, var/mob/user)
	if(!istype(A, /obj/machinery/atmospherics))
		return 1

	var/obj/machinery/atmospherics/O = A

	if(!O.available_colors || !O.available_colors.len)
		return "you cannot paint this!"

	if(!(selected_color in O.available_colors))
		return "the color '[selected_color]' is not available for \a [O]"

	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	O._color = selected_color

	user.visible_message("<span class='notice'>[user] paints \the [O] [selected_color].</span>","<span class='notice'>You paint \the [O] [selected_color].</span>")
	O.update_icon()

/datum/rcd_schematic/paint_pipes/Topic(var/href, var/list/href_list)
	if(href_list["set_color"])
		if(href_list["set_color"] in available_colors)
			selected_color = href_list["set_color"]

			master.update_options_menu()

		return 1

//METERS AND SENSORS.

/datum/rcd_schematic/gsensor
	name		= "Gas sensor"
	category	= "Devices"
	flags		= RCD_RANGE | RCD_GET_TURF

/datum/rcd_schematic/gsensor/attack(var/atom/A, var/mob/user)
	if(!isturf(A))
		return

	user << "Building gas sensor..."
	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
	new /obj/item/pipe_gsensor(A)

/datum/rcd_schematic/pmeter
	name		= "Pipe meter"
	category	= "Devices"
	flags		= RCD_RANGE | RCD_GET_TURF

/datum/rcd_schematic/pmeter/attack(var/atom/A, var/mob/user)
	if(!isturf(A))
		return

	user << "Building pipe meter..."
	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
	new /obj/item/pipe_meter(A)

//ACTUAL PIPES.

/datum/rcd_schematic/pipe
	name				= "Pipe"
	category			= "Regular pipes"
	flags				= RCD_RANGE | RCD_GET_TURF

	var/pipe_id			= PIPE_SIMPLE_STRAIGHT
	var/pipe_type		= PIPE_BINARY
	var/selected_dir	= NORTH

/datum/rcd_schematic/pipe/send_icons(var/client/client)
	var/list/dir_list	//We get the dirs to loop through and send images to the client for.
	switch(pipe_type)
		if(PIPE_UNARY, PIPE_TRINARY)
			dir_list = cardinal

		if(PIPE_BINARY)
			dir_list = list(NORTH, EAST)

		if(PIPE_BENT)
			dir_list = diagonal

		if(PIPE_TRIN_M)
			dir_list = alldirs

		else
			dir_list = list()

	for(var/dir in dir_list)
		send_icon(client, dir)

/datum/rcd_schematic/pipe/proc/send_icon(var/client/client, var/dir)
	client << browse_rsc(new/icon('icons/obj/pipe-item.dmi', pipeID2State[pipe_id + 1], dir), "RPD_[pipe_id]_[dir].png")

/datum/rcd_schematic/pipe/get_HTML()
	. += "<p>"

	switch(pipe_type)
		if(PIPE_BINARY)
			. += render_dir_image(NORTH,	"Vertical")
			. += render_dir_image(EAST,		"Horizontal")

		if(PIPE_UNARY)
			. += render_dir_image(NORTH,	"North")
			. += render_dir_image(EAST,		"East")
			. += render_dir_image(SOUTH,	"South")
			. += render_dir_image(WEST,		"West")

		if(PIPE_BENT)
			. += render_dir_image(9,		"West to North")
			. += render_dir_image(5,		"North to East")
			. += "<br/>"
			. += render_dir_image(10,		"South to West")
			. += render_dir_image(6,		"East to South")

		if(PIPE_TRINARY)
			. += render_dir_image(NORTH,	"West South East")
			. += render_dir_image(EAST,		"North West South")
			. += "<br/>"
			. += render_dir_image(SOUTH,	"East North West")
			. += render_dir_image(WEST,		"South East North")

		if(PIPE_TRIN_M)
			. += render_dir_image(NORTH,	"West South East")
			. += render_dir_image(EAST,		"North West South")
			. += "<br/>"
			. += render_dir_image(SOUTH,	"East North West")
			. += render_dir_image(WEST,		"South East North")
			. += "<br/>"
			. += render_dir_image(6,		"West South East")
			. += render_dir_image(5,		"North West South")
			. += "<br/>"
			. += render_dir_image(9,		"East North West")
			. += render_dir_image(10,		"South East North")

	. += "</p>"

/datum/rcd_schematic/pipe/proc/render_dir_image(var/dir, var/title)
	var/selected = ""
	if(selected_dir == dir)
		selected = " class='selected'"

	return "<a href='?src=\ref[master.interface];set_dir=[dir]'[selected] title='[title]'><img src='RPD_[pipe_id]_[dir].png'/></a>"

/datum/rcd_schematic/pipe/Topic(var/href, var/href_list)
	if(href_list["set_dir"])
		var/dir = text2num(href_list["set_dir"])
		if(!(dir in alldirs) || selected_dir == dir)
			return 1

		selected_dir = dir
		master.update_options_menu()

		return 1

/datum/rcd_schematic/pipe/attack(var/atom/A, var/mob/user)
	user << "Building Pipes ..."
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/item/pipe/P = getFromPool(/obj/item/pipe, A, pipe_id, selected_dir)
	P.update()
	P.add_fingerprint(user)

//Disposal piping.
/datum/rcd_schematic/pipe/disposal
	category		= "Disposal Pipes"

	pipe_id			= DISP_PIPE_STRAIGHT
	var/actual_id	= 0	//This is needed because disposals construction code is a shit.

/datum/rcd_schematic/pipe/disposal/send_icon(var/client/client, var/dir)
	client << browse_rsc(new/icon('icons/obj/pipes/disposal.dmi', disposalpipeID2State[pipe_id + 1], dir), "RPD_D_[pipe_id]_[dir].png")

/datum/rcd_schematic/pipe/disposal/render_dir_image(var/dir, var/title)
	var/selected = ""
	if(selected_dir == dir)
		selected = " class='selected'"

	return "<a href='?src=\ref[master.interface];set_dir=[dir]'[selected] title='[title]'><img src='RPD_D_[pipe_id]_[dir].png'/></a>"

/datum/rcd_schematic/pipe/disposal/attack(var/atom/A, var/mob/user)
	user << "Building Pipes ..."
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/structure/disposalconstruct/C = new/obj/structure/disposalconstruct(A)
	C.dir	= selected_dir
	C.ptype	= actual_id
	C.update()

	C.add_fingerprint(user)

var/global/list/disposalpipeID2State=list(
	"pipe-s",
	"pipe-c",
	"pipe-j1",
	"pipe-y",
	"pipe-t",
	"disposal",
	"outlet",
	"intake",
	"pipe-j1s",
	"pipe-j1s",
)

//PIPE DEFINES START HERE.

//REGULAR PIPES.
//Straight is the base class, so not included.

/datum/rcd_schematic/pipe/bent
	name		= "Bent Pipe"

	pipe_id		= PIPE_SIMPLE_BENT
	pipe_type	= PIPE_BENT

/datum/rcd_schematic/pipe/manifold
	name		= "Manifold"

	pipe_id		= PIPE_MANIFOLD
	pipe_type	= PIPE_TRINARY

/datum/rcd_schematic/pipe/valve
	name		= "Manual Valve"

	pipe_id		= PIPE_MVALVE
	pipe_type	= PIPE_BINARY

/datum/rcd_schematic/pipe/dvalve
	name		= "Digital Valve"

	pipe_id		= PIPE_DVALVE
	pipe_type	= PIPE_BINARY

/datum/rcd_schematic/pipe/cap
	name		= "Pipe Cap"

	pipe_id		= PIPE_CAP
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/manifold_4w
	name		= "4-Way Manifold"

	pipe_id		= PIPE_MANIFOLD4W
	pipe_type	= PIPE_BINARY

/datum/rcd_schematic/pipe/mtvalve
	name		= "Manual T-Valve"

	pipe_id		= PIPE_MTVALVE
	pipe_type	= PIPE_TRIN_M

/datum/rcd_schematic/pipe/dtvalve
	name		= "Digital T-Valve"

	pipe_id		= PIPE_DTVALVE
	pipe_type	= PIPE_TRIN_M

//DEVICES.

/datum/rcd_schematic/pipe/connector
	name		= "Connecter"
	category	= "Devices"

	pipe_id		= PIPE_CONNECTOR
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/unary_vent
	name		= "Unary Vent"
	category	= "Devices"

	pipe_id		= PIPE_UVENT
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/passive_vent
	name		= "Passive Vent"
	category	= "Devices"

	pipe_id		= PIPE_PASV_VENT
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/pump
	name		= "Gas Pump"
	category	= "Devices"

	pipe_id		= PIPE_PUMP
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/passive_gate
	name		= "Passive gate"
	category	= "Devices"

	pipe_id		= PIPE_PASSIVE_GATE
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/volume_pump
	name		= "Volume Pump"
	category	= "Devices"

	pipe_id		= PIPE_VOLUME_PUMP
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/scrubber
	name		= "Scrubber"
	category	= "Devices"

	pipe_id		= PIPE_SCRUBBER
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/filter
	name		= "Gas Filter"
	category	= "Devices"

	pipe_id		= PIPE_GAS_FILTER
	pipe_type	= PIPE_TRIN_M

/datum/rcd_schematic/pipe/mixer
	name		= "Gas Mixer"
	category	= "Devices"

	pipe_id		= PIPE_GAS_MIXER
	pipe_type	= PIPE_TRIN_M

/datum/rcd_schematic/pipe/thermal_plate
	name		= "Thermal Plate"
	category	= "Devices"

	pipe_id		= PIPE_THERMAL_PLATE
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/injector
	name		= "Injector"
	category	= "Devices"

	pipe_id		= PIPE_INJECTOR
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/dp_vent
	name		= "Dual-Port Vent"
	category	= "Devices"

	pipe_id		= PIPE_DP_VENT
	pipe_type	= PIPE_UNARY

//H/E Pipes.

/datum/rcd_schematic/pipe/he
	name		= "Pipe"
	category	= "Heat Exchange"

	pipe_id		= PIPE_HE_STRAIGHT
	pipe_type	= PIPE_BINARY

/datum/rcd_schematic/pipe/he_bent
	name		= "Bent Pipe"
	category	= "Heat Exchange"

	pipe_id		= PIPE_HE_BENT
	pipe_type	= PIPE_BENT

/datum/rcd_schematic/pipe/juntion
	name		= "Junction"
	category	= "Heat Exchange"

	pipe_id		= PIPE_JUNCTION
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/heat_exchanger
	name		= "Heat Exchanger"
	category	= "Heat Exchange"

	pipe_id		= PIPE_HEAT_EXCHANGE
	pipe_type	= PIPE_UNARY

//INSULATED PIPES.

/datum/rcd_schematic/pipe/insulated
	name		= "Pipe"
	category	= "Insulated Pipes"

	pipe_id		= PIPE_INSULATED_STRAIGHT
	pipe_type	= PIPE_BINARY

/datum/rcd_schematic/pipe/insulated_bent
	name		= "Bent Pipe"
	category	= "Insulated Pipes"

	pipe_id		= PIPE_INSULATED_BENT
	pipe_type	= PIPE_BENT

/datum/rcd_schematic/pipe/insulated_manifold
	name		= "Manifold"
	category	= "Insulated Pipes"

	pipe_id		= PIPE_INSUL_MANIFOLD
	pipe_type	= PIPE_TRINARY

/datum/rcd_schematic/pipe/insulated_4w_manifold
	name		= "4-Way Manifold"
	category	= "Insulated Pipes"

	pipe_id		= PIPE_INSUL_MANIFOLD4W
	pipe_type	= PIPE_BINARY

//DISPOSAL PIPES
//Again basic straight is handled in the parent.

/datum/rcd_schematic/pipe/disposal/bent
	name		= "Bent Pipe"

	pipe_id		= DISP_PIPE_BENT
	actual_id	= 1
	pipe_type	= PIPE_UNARY	//Yes this makes no sense but BLAME FUCKING DISPOSALS CODE.

/datum/rcd_schematic/pipe/disposal/junction
	name		= "Junction"

	pipe_id		= DISP_JUNCTION
	actual_id	= 2
	pipe_type	= PIPE_TRINARY

/datum/rcd_schematic/pipe/disposal/y_junction
	name		= "Y-Junction"

	pipe_id		= DISP_YJUNCTION
	actual_id	= 4
	pipe_type	= PIPE_TRINARY

/datum/rcd_schematic/pipe/disposal/trunk
	name		= "Trunk"

	pipe_id		= DISP_END_TRUNK
	actual_id	= 5
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/disposal/bin
	name		= "Bin"

	pipe_id		= DISP_END_BIN
	actual_id	= 6
	pipe_type	= -1	//Will disable the icon.

/datum/rcd_schematic/pipe/disposal/outlet
	name		= "Outlet"

	pipe_id		= DISP_END_OUTLET
	actual_id	= 7
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/disposal/chute
	name		= "Chute"

	pipe_id		= DISP_END_CHUTE
	actual_id	= 8
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/disposal/sort
	name		= "Sorting Junction"

	pipe_id		= DISP_SORT_JUNCTION
	actual_id	= 9
	pipe_type	= PIPE_TRINARY

/datum/rcd_schematic/pipe/disposal/sort_wrap
	name		= "Wrapped Sorting Junction"

	pipe_id		= DISP_SORT_WRAP_JUNCTION
	actual_id	= 11
	pipe_type	= PIPE_TRINARY
