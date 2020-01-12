/obj/machinery/door/unpowered/wooddoor
	icon = 'fallout/icons/structure/wasteland_doors.dmi'
	name = "wooden door"
	icon_state = "room1"
	opacity = 1
	density = TRUE
	explosion_block = 1

/obj/machinery/door/unpowered/wooddoor/update_icon()
	if(density)
		icon_state = "room1"
	else
		icon_state = "room0"

/obj/machinery/door/unpowered/wooddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("roomc0", src)
		if("closing")
			flick("roomc1", src)
