/obj/machinery/trough
	name = "trough"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "trough"
	density = 1
	anchored = 0
	var/list/feed = list()
	var/starting_reagent = "water"

/obj/machinery/trough/examine(mob/user)
	..()
	user.show_message("The liquid level is [reagents.total_volume].",1)
	user.show_message("The amount of meals left is [feed.len].",1)

/obj/machinery/trough/New()
	..()
	create_reagents(200)
	reagents.add_reagent("water", 100)
	for(var/i in 1 to 20)
		feed += new /obj/item/weapon/reagent_containers/food/snacks/grown/corn(null)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/trough(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/trough/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/reagent_containers))
		if(istype(O, /obj/item/weapon/reagent_containers/glass/))
			var/obj/item/weapon/reagent_containers/glass/G = O
			G.reagents.trans_to(src,G.reagents.total_volume)
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
			user << "You add [O] to [src]."
			user.drop_item(O)
			O.loc = src
			feed.Add(O)
	if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/P = O
		for(var/obj/G in P.contents)
			if(istype(G,/obj/item/weapon/reagent_containers/food/snacks))
				feed.Add(G)
		user << "You empty food from [P] into [src]."
	if(default_deconstruction_screwdriver(user, "trough", "trough", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)
	return