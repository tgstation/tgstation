/obj/machinery/incubator
	name = "egg incubator"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "trough"
	density = 1
	anchored = 1
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
		SSobj.processing.Add(O)
	return

/obj/machinery/incubator/attack_hand(mob/user)
	if(incubated)
		incubated.loc = get_turf(src)
		user << "You pull [incubated] out of [src]."
		SSobj.processing.Remove(incubated)
		incubated = null