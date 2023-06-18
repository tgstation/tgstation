/obj/machinery/status_display
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/status_display/icons/status_display.dmi'

/obj/machinery/status_display/LateInitialize()
	. = ..()
	set_picture("default")

/obj/machinery/status_display/syndie
	name = "syndicate status display"

/obj/machinery/status_display/syndie/LateInitialize()
	. = ..()
	set_picture("synd")
