#define PIPE_BINARY		0
#define PIPE_BENT			1
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

	to_chat(user, "Destroying Pipe...")
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
	var/mass_colour = 0
	var/list/available_colors = list(
		"grey"		= PIPE_COLOR_GREY,
		"red"		= PIPE_COLOR_RED,
		"blue"		= PIPE_COLOR_BLUE,
		"cyan"		= PIPE_COLOR_CYAN,
		"green"		= PIPE_COLOR_GREEN,
		"orange"	= PIPE_COLOR_ORANGE,
		"purple"	= PIPE_COLOR_PURPLE,
		"custom" 	= "custom"
	)
	var/last_colouration = 0
	var/selected_color = "grey"
	var/colouring_delay = 0

/datum/rcd_schematic/paint_pipes/New(var/obj/item/device/rcd/n_master)
	. = ..()

	if(!master || !master.interface)
		return

	//Add the colour CSS defines to the master's interface's HEAD.
	var/color_css

	for(var/color_name in available_colors)
		var/color = available_colors[color_name]
		if (color == "custom")
			color = "#000000"
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

	master.interface.head += "<style type='text/css'>[color_css]</style><br><"

/datum/rcd_schematic/paint_pipes/deselect(var/mob/user, var/datum/rcd_schematic/new_schematic)
	. = ..()

	selected_color = available_colors[1]

/datum/rcd_schematic/paint_pipes/get_HTML()
	. += "<h4>Colour Choice:</h4>"
	for(var/color_name in available_colors)
		var/selected = ""
		if(color_name == selected_color)
			selected = " selected"
		if (selected_color == "custom")
			selected_color = input("Select Colour to change the pipe to", "Custom Pipe Colour", selected_color) as color
		if (selected_color == "#ffffff")
			selected_color = "#fffffe"
		. += "<a class='color [color_name][selected]' href='?src=\ref[master.interface];set_color=[color_name]'>&bull;</a>"
	var/mass_colour_on = mass_colour ? "On" : "Off"
	. += {" <br>
			<h4>Mass Colour:</h4>
			Mass Colouration: <b><A href='?src=\ref[master.interface];set_mass_colour=1'>[mass_colour_on]</a></b>"}

/datum/rcd_schematic/paint_pipes/attack(var/atom/A, var/mob/user)
	if(!istype(A, /obj/machinery/atmospherics))
		return 1

	var/obj/machinery/atmospherics/O = A

	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	if (selected_color in available_colors)
		selected_color = available_colors[selected_color]
	if(mass_colour && world.timeofday < last_colouration + colouring_delay)
		return "We aren't ready to mass paint again; please wait [(last_colouration+colouring_delay)-world.timeofday] more seconds!"
	if(mass_colour && istype(O, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/pipe_to_colour = O
		var/datum/pipeline/pipe_line = pipe_to_colour.parent
		var/list/pipeline_members = pipe_line.members
		if (pipeline_members.len < 500)
			last_colouration = world.timeofday
			colouring_delay = (pipeline_members.len)/2
			O.color = selected_color
			pipe_to_colour.mass_colouration(selected_color)
		else return "That pipe network is simply too big to paint!"
	else
		O.color = selected_color
		O.update_icon()
	user.visible_message("<span class='notice'>[user] paints \the [O] [selected_color].</span>","<span class='notice'>You paint \the [O] [selected_color].</span>")

/datum/rcd_schematic/paint_pipes/Topic(var/href, var/list/href_list)
	if(href_list["set_color"])
		if(href_list["set_color"] in available_colors)
			selected_color = href_list["set_color"]
			master.update_options_menu()
	if(href_list["set_mass_colour"])
		mass_colour = mass_colour ? 0:1
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

	to_chat(user, "Building gas sensor...")
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

	to_chat(user, "Building pipe meter...")
	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
	new /obj/item/pipe_meter(A)

//ACTUAL PIPES.

/datum/rcd_schematic/pipe
	name					= "Pipe"
	category				= "Regular pipes"
	flags					= RCD_RANGE | RCD_GET_TURF

	var/pipe_id				= PIPE_SIMPLE_STRAIGHT
	var/pipe_type			= PIPE_BINARY
	var/selected_dir		= NORTH
	var/layer				= PIPING_LAYER_DEFAULT //Layer selected, at 0, no layer picker will be available (disposals).

/datum/rcd_schematic/pipe/New(var/obj/item/device/rcd/n_master)
	. = ..()
	if(n_master) // So we don't do this in case we're created for asset registering.
		selected_dir = get_base_dir()
	
/datum/rcd_schematic/pipe/proc/get_base_dir()
	if(pipe_type == PIPE_BENT)
		return NORTHEAST

	return NORTH

/datum/rcd_schematic/pipe/register_assets()
	var/list/dir_list = get_dirs()

	for(var/dir in dir_list)
		register_icon(dir)

/datum/rcd_schematic/pipe/send_assets(var/client/client)
	var/list/dir_list = get_dirs()

	for(var/dir in dir_list)
		send_icon(client, dir)

	send_asset(client, "RPD-layer-blended-1.png")
	send_asset(client, "RPD-layer-blended-4.png")

	send_asset(client, "RPD_0_4.png")
	send_asset(client, "RPD_0_1.png")


/datum/rcd_schematic/pipe/proc/get_dirs()
	switch(pipe_type)
		if(PIPE_UNARY, PIPE_TRINARY)
			. = cardinal

		if(PIPE_BINARY)
			. = list(NORTH, EAST)

		if(PIPE_BENT)
			. = diagonal

		if(PIPE_TRIN_M)
			. = alldirs

		else
			.= list()

/datum/rcd_schematic/pipe/proc/register_icon(var/dir)
	register_asset("RPD_[pipe_id]_[dir].png", new/icon('icons/obj/pipe-item.dmi', pipeID2State[pipe_id + 1], dir))

/datum/rcd_schematic/pipe/proc/send_icon(var/client/client, var/dir)
	send_asset(client, "RPD_[pipe_id]_[dir].png")

/datum/rcd_schematic/pipe/get_HTML()
	. += "<p>"

	. += "<h4>Layers</h4>"

	if(layer)
		. += {"
		<div class="layer_holder">
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=1"><div class="layer vertical one 			[layer == 1 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=2"><div class="layer vertical two 			[layer == 2 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=3"><div class="layer vertical three 		[layer == 3 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=4"><div class="layer vertical four 			[layer == 4 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=5"><div class="layer vertical five 			[layer == 5 ? "selected" : ""]"></div></a>
		</div>

		<div class="layer_holder" style="left: 200px;">
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=1"><div class="layer horizontal one		[layer == 1 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=2"><div class="layer horizontal two		[layer == 2 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=3"><div class="layer horizontal three		[layer == 3 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=4"><div class="layer horizontal four		[layer == 4 ? "selected" : ""]"></div></a>
			<a class="no_dec" href="?src=\ref[master.interface];set_layer=5"><div class="layer horizontal five		[layer == 5 ? "selected" : ""]"></div></a>
		</div>

	"}

	. += "<h4>Directions</h4>"

	switch(pipe_type)
		if(PIPE_BINARY)
			. += render_dir_image(NORTH,		"Vertical")
			. += render_dir_image(EAST,			"Horizontal")

		if(PIPE_UNARY)
			. += render_dir_image(NORTH,		"North")
			. += render_dir_image(EAST,			"East")
			. += render_dir_image(SOUTH,		"South")
			. += render_dir_image(WEST,			"West")

		if(PIPE_BENT)
			. += render_dir_image(NORTHWEST,	"West to North")
			. += render_dir_image(NORTHEAST,	"North to East")
			. += "<br/>"
			. += render_dir_image(SOUTHWEST,	"South to West")
			. += render_dir_image(SOUTHEAST,	"East to South")

		if(PIPE_TRINARY)
			. += render_dir_image(NORTH,		"West South East")
			. += render_dir_image(EAST,			"North West South")
			. += "<br/>"
			. += render_dir_image(SOUTH,		"East North West")
			. += render_dir_image(WEST,			"South East North")

		if(PIPE_TRIN_M)
			. += render_dir_image(NORTH,		"West South East")
			. += render_dir_image(EAST,			"North West South")
			. += "<br/>"
			. += render_dir_image(SOUTH,		"East North West")
			. += render_dir_image(WEST,			"South East North")
			. += "<br/>"
			. += render_dir_image(6,			"West South East")
			. += render_dir_image(5,			"North West South")
			. += "<br/>"
			. += render_dir_image(9,			"East North West")
			. += render_dir_image(10,			"South East North")

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

	if(href_list["set_layer"] && layer) //Only handle this is layer is nonzero.
		var/n_layer = Clamp(round(text2num(href_list["set_layer"])), 1, 5)
		if(layer == n_layer) //No point doing anything.
			return 1

		layer = n_layer
		master.update_options_menu()

/datum/rcd_schematic/pipe/attack(var/atom/A, var/mob/user)
	to_chat(user, "Building Pipes ...")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/item/pipe/P = getFromPool(/obj/item/pipe, A, pipe_id, selected_dir)
	P.setPipingLayer(layer)
	P.update()
	P.add_fingerprint(user)

/datum/rcd_schematic/pipe/select(var/mob/user, var/datum/rcd_schematic/old_schematic)
	if(!istype(old_schematic, /datum/rcd_schematic/pipe))
		return ..()

	var/datum/rcd_schematic/pipe/P = old_schematic
	if(P.layer)
		layer = P.layer

	return ..()
	
//Disposal piping.
/datum/rcd_schematic/pipe/disposal
	category		= "Disposal Pipes"

	layer				= 0	//Set to 0 to disable layer selection.
	pipe_id			= DISP_PIPE_STRAIGHT
	var/actual_id	= 0	//This is needed because disposals construction code is a shit.

/datum/rcd_schematic/pipe/disposal/register_icon(var/dir)
	register_asset("RPD_D_[pipe_id]_[dir].png", new/icon('icons/obj/pipes/disposal.dmi', disposalpipeID2State[pipe_id + 1], dir))

/datum/rcd_schematic/pipe/disposal/send_icon(var/client/client, var/dir)
	send_asset(client, "RPD_D_[pipe_id]_[dir].png")

/datum/rcd_schematic/pipe/disposal/render_dir_image(var/dir, var/title)
	var/selected = ""
	if(selected_dir == dir)
		selected = " class='selected'"

	return "<a href='?src=\ref[master.interface];set_dir=[dir]'[selected] title='[title]'><img src='RPD_D_[pipe_id]_[dir].png'/></a>"

/datum/rcd_schematic/pipe/disposal/attack(var/atom/A, var/mob/user)
	to_chat(user, "Building Pipes ...")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, A, 20))
		return 1

	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/structure/disposalconstruct/C = new/obj/structure/disposalconstruct(A)
	C.dir	= selected_dir
	C.ptype	= actual_id
	C.update()

	C.add_fingerprint(user)

var/global/list/disposalpipeID2State = list(
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

//This is a meta thing to send a blended pipe sprite to clients, basically the default straight pipe, but blended blue.
//Yes I tried to find a proper way to blend things in HTML/CSS, alas.
/datum/rcd_schematic/pipe/blender/register_assets()
	var/icon/I = new/icon('icons/obj/pipe-item.dmi', pipeID2State[1], 1)
	I.Blend("#0000FF", ICON_MULTIPLY)	//Make it blue
	register_asset("RPD-layer-blended-1.png", I)

	I = new/icon('icons/obj/pipe-item.dmi', pipeID2State[1], 4)
	I.Blend("#0000FF", ICON_MULTIPLY)	//Make it blue
	register_asset("RPD-layer-blended-4.png", I)

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

/datum/rcd_schematic/pipe/layer_manifold
	name		= "Layer Manifold"

	pipe_id		= PIPE_LAYER_MANIFOLD
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/layer_adapter
	name		= "Layer Adapter"

	pipe_id		= PIPE_LAYER_ADAPTER
	pipe_type	= PIPE_UNARY

/datum/rcd_schematic/pipe/layer_adapter/register_icon(var/dir)
	for(var/layer = PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		register_asset("RPD_[pipe_id]_[dir]_[layer].png", new/icon('icons/obj/atmospherics/pipe_adapter.dmi', "adapter_[layer]", dir))

/datum/rcd_schematic/pipe/layer_adapter/send_icon(var/client/client, var/dir)
	send_asset(client, "RPD_[pipe_id]_[dir]_[layer].png")


/datum/rcd_schematic/pipe/layer_adapter/render_dir_image(var/dir, var/title)
	var/selected = ""
	if(selected_dir == dir)
		selected = " class='selected'"

	return "<a href='?src=\ref[master.interface];set_dir=[dir]'[selected] title='[title]'><img src='RPD_[pipe_id]_[dir]_[layer].png'/></a>"

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
