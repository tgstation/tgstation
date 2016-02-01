/obj/machinery/nest
	name = "nest"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "nest"
	density = 0
	anchored = 0

/obj/machinery/nest/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/nest(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/nest/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "nest", "nest", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)
	return