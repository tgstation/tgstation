/obj/machinery/status_display
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/status_display/icons/status_display.dmi'
	text_color = "#A0F000"
	header_text_color = "#AAFF00"

/obj/machinery/status_display/LateInitialize()
	. = ..()
	set_picture("default")

/obj/machinery/status_display/supply
	text_color = "#F06000"
	header_text_color = "#FF6600"

/obj/machinery/status_display/shuttle
	text_color = "#0060F0"
	header_text_color = "#0066FF"

/obj/machinery/status_display/syndie
	name = "syndicate status display"
	text_color = "#F00000"
	header_text_color = "#FF0000"

/obj/machinery/status_display/syndie/LateInitialize()
	. = ..()
	set_picture("synd")
