/*CONTENTS
Buildable pipes
Buildable meters
*/
#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_HE_STRAIGHT		2
#define PIPE_HE_BENT			3
#define PIPE_CONNECTOR			4
#define PIPE_MANIFOLD			5
#define PIPE_JUNCTION			6
#define PIPE_UVENT				7
#define PIPE_MVALVE				8
#define PIPE_PUMP				9
#define PIPE_SCRUBBER			10
#define PIPE_GAS_FILTER			11
#define PIPE_GAS_MIXER			12
#define PIPE_PASSIVE_GATE       13
#define PIPE_VOLUME_PUMP        14
#define PIPE_HEAT_EXCHANGE      15
#define PIPE_DVALVE             16
#define PIPE_4WAYMANIFOLD       17
//Disposal piping numbers - do NOT hardcode these, use the defines
#define DISP_PIPE_STRAIGHT		0
#define DISP_PIPE_BENT			1
#define DISP_JUNCTION			2
#define DISP_JUNCTION_FLIP		3
#define DISP_YJUNCTION			4
#define DISP_END_TRUNK			5
#define DISP_END_BIN			6
#define DISP_END_OUTLET			7
#define DISP_END_CHUTE			8
#define DISP_SORTJUNCTION		9
#define DISP_SORTJUNCTION_FLIP	10

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipename
	force = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = 3
	level = 2
	var/flipped = 0

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if (make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		src.color = make_from.color
		var/is_bent
		if  (make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = 0
		else
			is_bent = 1
		if     (istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			src.pipe_type = PIPE_JUNCTION
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			src.pipe_type = PIPE_HE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/unary/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			src.pipe_type = PIPE_UVENT
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve/digital))
			src.pipe_type = PIPE_DVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			src.pipe_type = PIPE_GAS_FILTER
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			src.pipe_type = PIPE_GAS_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			src.pipe_type = PIPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			src.pipe_type = PIPE_PASSIVE_GATE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/volume_pump))
			src.pipe_type = PIPE_VOLUME_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			src.pipe_type = PIPE_HEAT_EXCHANGE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w))
			src.pipe_type = PIPE_4WAYMANIFOLD

		var/obj/machinery/atmospherics/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			src.flipped = 1
			src.dir = turn(src.dir, -45)

	else
		src.pipe_type = pipe_type
		src.dir = dir
	//src.pipe_dir = get_pipe_dir()
	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type
var/global/list/pipeID2State = list(
	"simple", \
	"simple", \
	"he", \
	"he", \
	"connector", \
	"manifold", \
	"junction", \
	"uvent", \
	"mvalve", \
	"pump", \
	"scrubber", \
	"filter", \
	"mixer", \
	"passivegate", \
	"volumepump", \
	"heunary", \
	"dvalve", \
	"manifold4w", \
)

/obj/item/pipe/proc/update()
	var/list/nlist = list( \
		"pipe", \
		"bent pipe", \
		"h/e pipe", \
		"bent h/e pipe", \
		"connector", \
		"manifold", \
		"junction", \
		"vent", \
		"manual valve", \
		"pump", \
		"scrubber", \
		"gas filter", \
		"gas mixer", \
		"passive gate", \
		"volume pump", \
		"heat exchanger", \
		"digital valve", \
		"4-way manifold", \
	)
	name = nlist[pipe_type+1] + " fitting"
	icon_state = pipeID2State[pipe_type + 1]

//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	src.dir = turn(src.dir, -90)

	fixdir()

	return

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	if (pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER))
		src.dir = turn(src.dir, flipped ? 45 : -45)
		flipped = !flipped
		return

	src.dir = turn(src.dir, -180)

	fixdir()

	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE_BENT, PIPE_HE_BENT)) \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if ((pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER)) && flipped)
		src.dir = turn(src.dir, 45+90)
	else if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	return

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0

	var/direct = dir
	if(flipped)
		direct = turn(dir, 45)

	var/flip = turn(direct, 180)
	var/cw = turn(direct, -90)
	var/acw = turn(direct, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_HE_STRAIGHT, \
			PIPE_JUNCTION, \
			PIPE_PUMP, \
			PIPE_VOLUME_PUMP, \
			PIPE_PASSIVE_GATE, \
			PIPE_MVALVE, \
			PIPE_DVALVE \
		)
			return direct|flip
		if(PIPE_SIMPLE_BENT, PIPE_HE_BENT)
			return direct //dir|acw
		if(PIPE_CONNECTOR,PIPE_UVENT,PIPE_SCRUBBER,PIPE_HEAT_EXCHANGE)
			return direct
		if(PIPE_MANIFOLD)
			return flip|cw|acw
		if(PIPE_4WAYMANIFOLD)
			return NORTH|SOUTH|EAST|WEST
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER)
			return direct|flip|cw
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes

	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

	if (!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
		return get_pipe_dir()
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0
		if(PIPE_JUNCTION)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/pipe/proc/get_hdir() //endpoints for h/e pipes

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0

/obj/item/pipe/proc/unflip(var/direction)
	if(!(direction in cardinal))
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)

	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1

	fixdir()

	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M.initialize_directions & pipe_dir)	// matches at least one direction on either type of pipe
			user << "<span class='warning'>There is already a pipe at that location!</span>"
			return 1
	// no conflicts found

	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new( src.loc )
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new ( src.loc )
			P.initialize_directions_he = pipe_dir
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_CONNECTOR)
			var/obj/machinery/atmospherics/unary/portables_connector/C = new( src.loc )
			if (pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_MANIFOLD)
			var/obj/machinery/atmospherics/pipe/manifold/M = new(loc)
			M.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_4WAYMANIFOLD)
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new( src.loc )
			M.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new ( src.loc )
			P.initialize_directions_he = src.get_hdir()
			P.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_UVENT)
			var/obj/machinery/atmospherics/unary/vent_pump/V = new( src.loc )
			V.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_MVALVE)
			var/obj/machinery/atmospherics/binary/valve/V = new(src.loc)
			if (pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_DVALVE)
			var/obj/machinery/atmospherics/binary/valve/digital/V = new(src.loc)
			if (pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_PUMP)
			var/obj/machinery/atmospherics/binary/pump/P = new(src.loc)
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER)
			var/obj/machinery/atmospherics/trinary/P
			if(pipe_type == PIPE_GAS_FILTER)
				P = new /obj/machinery/atmospherics/trinary/filter(src.loc)
			else if(pipe_type == PIPE_GAS_MIXER)
				P = new /obj/machinery/atmospherics/trinary/mixer(src.loc)
			P.flipped = flipped
			if (pipename)
				P.name = pipename
			P.construction(unflip(dir), pipe_dir, pipe_type, color)

		if(PIPE_SCRUBBER)
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(src.loc)
			if (pipename)
				S.name = pipename
			S.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_PASSIVE_GATE)
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(src.loc)
			if (pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_VOLUME_PUMP)
			var/obj/machinery/atmospherics/binary/volume_pump/P = new(src.loc)
			if (pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_HEAT_EXCHANGE)
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new( src.loc )
			if (pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, pipe_type, color)

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratchet.</span>")

	qdel(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		user << "<span class='warning'>You need to fasten it to a pipe!</span>"
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You fasten the meter to the pipe.</span>"
	qdel(src)
