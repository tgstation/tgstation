var/list/shipping_pads = list()

/obj/machinery/shipping_pad
	name = "shipping pad"
	icon = 'goon/icons/obj/cargo_pad.dmi'
	icon_state = "cargo_pad"
	desc = "Imports get teleported here."

/obj/machinery/shipping_pad/New()
	..()
	shipping_pads += src

/obj/machinery/shipping_pad/Destroy()
	shipping_pads -= src
	..()