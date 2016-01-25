/obj/machinery/nest
	name = "nest"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "nest"
	density = 1
	anchored = 1

/obj/machinery/nest/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/nest(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/nest/attackby(obj/item/O, mob/user, params)
	return