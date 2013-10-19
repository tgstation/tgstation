/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = ""
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-stand"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/opened = 0.0
	var/processing = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/points = 0
	var/menustat = "menu"

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/biogenerator
		component_parts += new /obj/item/weapon/stock_parts/manipulator
		component_parts += new /obj/item/weapon/stock_parts/manipulator
		component_parts += new /obj/item/weapon/stock_parts/matter_bin
		component_parts += new /obj/item/weapon/stock_parts/matter_bin
		component_parts += new /obj/item/weapon/stock_parts/micro_laser
		component_parts += new /obj/item/weapon/stock_parts/micro_laser
		component_parts += new /obj/item/weapon/stock_parts/micro_laser
		component_parts += new /obj/item/weapon/stock_parts/scanning_module
		component_parts += new /obj/item/weapon/stock_parts/scanning_module
		component_parts += new /obj/item/weapon/stock_parts/console_screen
		component_parts += new /obj/item/weapon/stock_parts/console_screen
		RefreshParts()


	on_reagent_change()			//When the reagents change, change the icon as well.
		update_icon()

	update_icon()
		if(!src.beaker)
			icon_state = "biogen-empty"
		else if(!src.processing)
			icon_state = "biogen-stand"
		else
			icon_state = "biogen-work"
		return


/obj/machinery/biogenerator/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "\red The biogenerator already occuped."
		else
			user.before_take_item(O)
			O.loc = src
			beaker = O
			updateUsrDialog()
	else if(processing)
		user << "\red The biogenerator is currently processing."
	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= 10)
			user << "\red The biogenerator is already full! Activate it."
		else
			for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
				G.loc = src
				i++
				if(i >= 10)
					user << "\blue You fill the biogenerator to its capacity."
					break
			if(i<10)
				user << "\blue You empty the plant bag into the biogenerator."
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
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			del(src)
			return 1

	else if(!istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
		user << "\red You cannot put this in [src.name]"
	else
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= 10)
			user << "\red The biogenerator is full! Activate it."
		else
			user.before_take_item(O)
			O.loc = src
			user << "\blue You put [O.name] in [src.name]"
	update_icon()
	return

/obj/machinery/biogenerator/interact(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)
	var/dat = "<TITLE>Biogenerator</TITLE>Biogenerator:<BR>"
	if (processing)
		dat += "<FONT COLOR=red>Biogenerator is processing! Please wait...</FONT>"
	else
		dat += "Biomass: [points] points.<HR>"
		switch(menustat)
			if("menu")
				if (beaker)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\biogenerator.dm:89: dat += "<A href='?src=\ref[src];action=activate'>Activate Biogenerator!</A><BR>"
					dat += {"<A href='?src=\ref[src];action=activate'>Activate Biogenerator!</A><BR>
						<A href='?src=\ref[src];action=detach'>Detach Container</A><BR><BR>
						Food<BR>
						<A href='?src=\ref[src];action=create;item=milk'>10 milk</A> <FONT COLOR=blue>(20)</FONT> | <A href='?src=\ref[src];action=create;item=milk5'>50 milk</A><BR>
						<A href='?src=\ref[src];action=create;item=meat'>Slab of meat</A> <FONT COLOR=blue>(50)</FONT> | <A href='?src=\ref[src];action=create;item=meat5'>x5</A><BR>
						Nutrient<BR>
						<A href='?src=\ref[src];action=create;item=ez'>E-Z-Nutrient</A> <FONT COLOR=blue>(10)</FONT> | <A href='?src=\ref[src];action=create;item=ez5'>x5</A><BR>
						<A href='?src=\ref[src];action=create;item=l4z'>Left 4 Zed</A> <FONT COLOR=blue>(20)</FONT> | <A href='?src=\ref[src];action=create;item=l4z5'>x5</A><BR>
						<A href='?src=\ref[src];action=create;item=rh'>Robust Harvest</A> <FONT COLOR=blue>(25)</FONT> | <A href='?src=\ref[src];action=create;item=rh5'>x5</A><BR>
						Leather<BR>
						<A href='?src=\ref[src];action=create;item=wallet'>Wallet</A> <FONT COLOR=blue>(100)</FONT><BR>
						<A href='?src=\ref[src];action=create;item=cardboard'>Cardboard Sheet</A> <FONT COLOR=blue>(200)</FONT> | <A href='?src=\ref[src];action=create;item=cardboard5'>x5</A><BR>
						<A href='?src=\ref[src];action=create;item=gloves'>Botanical gloves</A> <FONT COLOR=blue>(250)</FONT><BR>
						<A href='?src=\ref[src];action=create;item=tbelt'>Utility belt</A> <FONT COLOR=blue>(300)</FONT><BR>
						<A href='?src=\ref[src];action=create;item=plants'>Plant Bag</A> <FONT COLOR=blue>(350)</FONT><BR>
						<A href='?src=\ref[src];action=create;item=satchel'>Leather Satchel</A> <FONT COLOR=blue>(400)</FONT><BR>"}
					// END AUTOFIX
					//dat += "Other<BR>"
					//dat += "<A href='?src=\ref[src];action=create;item=monkey'>Monkey</A> <FONT COLOR=blue>(500)</FONT><BR>"
				else
					dat += "<BR><FONT COLOR=red>No beaker inside. Please insert a beaker.</FONT><BR>"
			if("nopoints")

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\biogenerator.dm:108: dat += "You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.<BR>"
				dat += {"You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.<BR>
					<A href='?src=\ref[src];action=menu'>Return to menu</A>"}
				// END AUTOFIX
			if("complete")

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\biogenerator.dm:111: dat += "Operation complete.<BR>"
				dat += {"Operation complete.<BR>
					<A href='?src=\ref[src];action=menu'>Return to menu</A>"}
				// END AUTOFIX
			if("void")

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\biogenerator.dm:114: dat += "<FONT COLOR=red>Error: No growns inside.</FONT><BR>Please, put growns into reactor.<BR>"
				dat += {"<FONT COLOR=red>Error: No growns inside.</FONT><BR>Please, put growns into reactor.<BR>
					<A href='?src=\ref[src];action=menu'>Return to menu</A>"}
				// END AUTOFIX
	user << browse(dat, "window=biogenerator")
	onclose(user, "biogenerator")
	return

/obj/machinery/biogenerator/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/biogenerator/proc/activate()
	if (usr.stat != 0)
		return
	if (src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		usr << "\red The biogenerator is in the process of working."
		return
	var/S = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount("nutriment") < 0.1)
			points += 1
		else points += I.reagents.get_reagent_amount("nutriment")*10
		del(I)
	if(S)
		processing = 1
		update_icon()
		updateUsrDialog()
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		use_power(S*30)
		sleep(S+15)
		processing = 0
		update_icon()
	else
		menustat = "void"
	return

/obj/machinery/biogenerator/proc/check_cost(var/cost)
	if (cost > points)
		menustat = "nopoints"
		return 1
	else
		points -= cost
		processing = 1
		update_icon()
		updateUsrDialog()
		sleep(30)
		return 0

/obj/machinery/biogenerator/proc/create_product(var/item)
	switch(item)
		if("milk")
			if (check_cost(20)) return 0
			else beaker.reagents.add_reagent("milk",10)
		if("meat")
			if (check_cost(50)) return 0
			else new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
		if("milk5")
			if (check_cost(100)) return 0
			else beaker.reagents.add_reagent("milk",50)
		if("meat5")
			if (check_cost(250)) return 0
			else
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
		if("ez")
			if (check_cost(10)) return 0
			else new/obj/item/nutrient/ez(src.loc)
		if("l4z")
			if (check_cost(20)) return 0
			else new/obj/item/nutrient/l4z(src.loc)
		if("rh")
			if (check_cost(25)) return 0
			else new/obj/item/nutrient/rh(src.loc)
		if("ez5") //It's not an elegant method, but it's safe and easy. -Cheridan
			if (check_cost(50)) return 0
			else
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
		if("l4z5")
			if (check_cost(100)) return 0
			else
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
		if("rh5")
			if (check_cost(125)) return 0
			else
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
		if("wallet")
			if (check_cost(100)) return 0
			else new/obj/item/weapon/storage/wallet(src.loc)
		if("cardboard")
			if (check_cost(200)) return 0
			else new /obj/item/stack/sheet/cardboard(src.loc)
		if("cardboard5")
			if (check_cost(1000)) return 0
			else
				new /obj/item/stack/sheet/cardboard(src.loc)
				new /obj/item/stack/sheet/cardboard(src.loc)
				new /obj/item/stack/sheet/cardboard(src.loc)
				new /obj/item/stack/sheet/cardboard(src.loc)
				new /obj/item/stack/sheet/cardboard(src.loc)
		if("gloves")
			if (check_cost(250)) return 0
			else new/obj/item/clothing/gloves/botanic_leather(src.loc)
		if("tbelt")
			if (check_cost(300)) return 0
			else new/obj/item/weapon/storage/belt/utility(src.loc)
		if("plants")
			if (check_cost(350))return 0
			else new/obj/item/weapon/storage/bag/plants(src.loc)
		if("satchel")
			if (check_cost(400)) return 0
			else new/obj/item/weapon/storage/backpack/satchel(src.loc)
		//if("monkey")
		//	if (check_cost(500)) return 0
		//	else new/mob/living/carbon/monkey(src.loc)
	processing = 0
	menustat = "complete"
	update_icon()
	return 1

/obj/machinery/biogenerator/Topic(href, href_list)
	if(stat & BROKEN) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.set_machine(src)

	switch(href_list["action"])
		if("activate")
			activate()
		if("detach")
			if(beaker)
				beaker.loc = src.loc
				beaker = null
				update_icon()
		if("create")
			create_product(href_list["item"],text2num(href_list["cost"]))
		if("menu")
			menustat = "menu"
	updateUsrDialog()
