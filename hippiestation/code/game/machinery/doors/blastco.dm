/obj/machinery/door/poddoor/shutters/blastco
	resistance_flags = INDESTRUCTIBLE

var/list/global/blastco_doors

/obj/machinery/door/poddoor/shutters/blastco/Initialize()
	. = ..()
	LAZYINITLIST(blastco_doors)
	LAZYADD(blastco_doors, src)
