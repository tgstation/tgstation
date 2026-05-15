/obj/machinery/puzzle/password/pin/viro
	desc = "A panel that controls Hazardous Gas Door. This one requires a PIN password, so let's start by typing in 1234..."
	password = "424242"
	single_use = FALSE
	pin_length = 6

/obj/machinery/puzzle/password/pin/viro/on_puzzle_complete()
	. = ..()
	for(var/obj/machinery/door/poddoor/viro/door in world)
		if(door.density)
			door.open()


/obj/machinery/door/poddoor/viro

	name = "Hazardous Gas Door"
	desc = "A airtight heavy duty blast door that opens mechanically. Leads to something dangerous."
