var/list/shipping_pads = list()

/obj/machinery/shipping_pad
	name = "shipping pad"
	icon = 'goon/icons/obj/cargo_pad.dmi'
	icon_state = "cargo_pad"
	desc = "Imports get teleported here."
	anchored = 1

/obj/machinery/shipping_pad/New()
	..()
	shipping_pads += src
	var/area/A = get_area(src)
	name = "[A.name] Shipping Pad [rand(100,999)]"

/obj/machinery/shipping_pad/Destroy()
	shipping_pads -= src
	..()