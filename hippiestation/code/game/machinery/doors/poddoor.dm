/obj/machinery/door/poddoor/open(ignorepower = 0)
	. = ..()
	playsound(src.loc, 'hippiestation/sound/machine/blast_door.ogg', 100, 1)

/obj/machinery/door/poddoor/close(ignorepower = 0)
	. = ..()
	playsound(src.loc, 'hippiestation/sound/machine/blast_door.ogg', 100, 1)