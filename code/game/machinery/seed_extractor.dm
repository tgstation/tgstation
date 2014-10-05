/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/opened = 0.0

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/seed_extractor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/seed_extractor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)

	// Fruits and vegetables.
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O, /obj/item/weapon/grown))

		user.drop_item(O)

		var/datum/seed/new_seed_type
		if(istype(O, /obj/item/weapon/grown))
			var/obj/item/weapon/grown/F = O
			new_seed_type = seed_types[F.plantname]
		else
			var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
			new_seed_type = seed_types[F.plantname]

		if(new_seed_type)
			user << "<span class='notice'>You extract some seeds from [O].</span>"
			var/produce = rand(1,4)
			for(var/i = 0;i<=produce;i++)
				var/obj/item/seeds/seeds = new(get_turf(src))
				seeds.seed_type = new_seed_type.name
				seeds.update_seed()
		else
			user << "[O] doesn't seem to have any usable seeds inside it."

		del(O)

	//Grass.
	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		user << "<span class='notice'>You extract some seeds from the [S.name].</span>"
		S.use(1)
		new /obj/item/seeds/grassseed(loc)

	if(O)
		var/obj/item/F = O
		if(F.nonplant_seed_type)
			user.drop_item()
			var/t_amount = 0
			var/t_max = rand(1,4)
			while(t_amount < t_max)
				new F.nonplant_seed_type(src.loc)
				t_amount++
			del(F)

	else if (istype(O, /obj/item/weapon/screwdriver))
		if (!opened)
			src.opened = 1
			user << "You open the maintenance hatch of [src]."
			//src.icon_state = "autolathe_t"
		else
			src.opened = 0
			user << "You close the maintenance hatch of [src]."
			//src.icon_state = "autolathe"
			return 1
	else if(istype(O, /obj/item/weapon/crowbar))
		if (opened)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			del(src)
			return 1

	return
