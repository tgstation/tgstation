/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = ""
	icon = 'biogenerator.dmi'
	icon_state = "biogen-stand"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/processing = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/points = 0
	var/menustat = "menu"

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		beaker = new /obj/item/weapon/reagent_containers/glass/large(src)

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
	else if(istype(O, /obj/item/weapon/plantbag))
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

/obj/machinery/biogenerator/proc/interact(mob/user as mob)
	if(stat & BROKEN)
		return
	user.machine = src
	var/dat = "<TITLE>Biogenerator</TITLE>Biogenerator:<BR>"
	if (processing)
		dat += "<FONT COLOR=red>Biogenerator is processing! Please wait...</FONT>"
	else
		dat += "Biomass: [points] points.<HR>"
		switch(menustat)
			if("menu")
				if (beaker)
					dat += "<A href='?src=\ref[src];action=activate'>Activate Biogenerator!</A><BR>"
					dat += "<A href='?src=\ref[src];action=detach'>Detach Container</A><BR><BR>"
					dat += "Food<BR>"
					dat += "<A href='?src=\ref[src];action=create;item=milk;cost=20'>10 milk</A> <FONT COLOR=blue>(20)</FONT><BR>"
					dat += "<A href='?src=\ref[src];action=create;item=meat;cost=50'>Slab of meat</A> <FONT COLOR=blue>(50)</FONT><BR>"
					dat += "Nutrient<BR>"
					dat += "<A href='?src=\ref[src];action=create;item=ez;cost=10'>E-Z-Nutrient</A> <FONT COLOR=blue>(10)</FONT><BR>"
					dat += "<A href='?src=\ref[src];action=create;item=l4z;cost=20'>Left 4 Zed</A> <FONT COLOR=blue>(20)</FONT><BR>"
					dat += "<A href='?src=\ref[src];action=create;item=rh;cost=25'>Robust Harvest</A> <FONT COLOR=blue>(25)</FONT><BR>"
					//dat += "Other<BR>"
					//dat += "<A href='?src=\ref[src];action=create;item=monkey;cost=500'>Monkey</A> <FONT COLOR=blue>(500)</FONT><BR>"
				else
					dat += "<BR><FONT COLOR=red>No beaker inside. Please insert a beaker.</FONT><BR>"
			if("nopoints")
				dat += "You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.<BR>"
				dat += "<A href='?src=\ref[src];action=menu'>Return to menu</A>"
			if("complete")
				dat += "Operation complete.<BR>"
				dat += "<A href='?src=\ref[src];action=menu'>Return to menu</A>"
			if("void")
				dat += "<FONT COLOR=red>Error: No growns inside.</FONT><BR>Please, put growns into reactor.<BR>"
				dat += "<A href='?src=\ref[src];action=menu'>Return to menu</A>"
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
		playsound(src.loc, 'blender.ogg', 50, 1)
		use_power(S*30)
		sleep(S+15)
		processing = 0
		update_icon()
	else
		menustat = "void"
	return

/obj/machinery/biogenerator/proc/create_product(var/item,var/cost)
	if(cost > points)
		menustat = "nopoints"
		return 0
	processing = 1
	update_icon()
	updateUsrDialog()
	points -= cost
	sleep(30)
	switch(item)
		if("milk")
			beaker.reagents.add_reagent("milk",10)
		if("meat")
			new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
		if("ez")
			new/obj/item/nutrient/ez(src.loc)
		if("l4z")
			new/obj/item/nutrient/l4z(src.loc)
		if("rh")
			new/obj/item/nutrient/rh(src.loc)
		if("monkey")
			new/mob/living/carbon/monkey(src.loc)
	processing = 0
	menustat = "complete"
	update_icon()
	return 1

/obj/machinery/biogenerator/Topic(href, href_list)
	if(stat & BROKEN) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.machine = src

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