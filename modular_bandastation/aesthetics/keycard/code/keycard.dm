/obj/machinery/keycard_auth
	icon = 'modular_bandastation/aesthetics/keycard/icons/keycard.dmi'
	// TODO: update auth_on

/obj/machinery/keycard_auth/Initialize(mapload)
	. = ..()
	switch(dir) // TODO: do it in dmi
		if(NORTH)
			dir = SOUTH
		if(SOUTH)
			dir = NORTH
		if(EAST)
			dir = WEST
		if(WEST)
			dir = EAST

/obj/machinery/readybutton
	icon = 'modular_bandastation/aesthetics/keycard/icons/keycard.dmi'

/obj/machinery/readybutton/Initialize(mapload)
	. = ..()
	switch(dir) // TODO: do it in dmi
		if(NORTH)
			dir = SOUTH
		if(SOUTH)
			dir = NORTH
		if(EAST)
			dir = WEST
		if(WEST)
			dir = EAST
