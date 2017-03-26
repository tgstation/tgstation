/obj/machinery/incubator
	name = "egg incubator"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "incubator"
	density = 1
	anchored = 0
	var/obj/item/weapon/reagent_containers/food/snacks/egg/incubated = null

/obj/machinery/incubator/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/incubator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/incubator/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/egg))
		user.drop_item(O)
		O.loc = src
		user << "You add [O] to [src]."
		icon_state = "incubator_e"
		incubated = O
		SSobj.processing |= incubated
		return
	if(default_deconstruction_screwdriver(user, "incubator", "incubator", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)
	return

/obj/machinery/incubator/attack_hand(mob/user)
	if(incubated)
		incubated.loc = get_turf(src)
		user << "You pull [incubated] out of [src]."
		SSobj.processing.Remove(incubated)
		incubated = null
		icon_state = "incubator"