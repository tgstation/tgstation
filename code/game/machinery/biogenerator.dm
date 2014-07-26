/datum/biogen_recipe
	var/id=""
	var/cost=0
	var/category=""
	var/name=""
	var/amount_per_unit=1
	var/list/other_amounts=list()
	var/reagent=null
	var/result=null

/datum/biogen_recipe/proc/Render(var/context)
	var/html = "<li><a href='?src=\ref[context];action=create;item=[id];num=1'>[amount_per_unit==1?"":"[amount_per_unit] "][name]</a> <FONT COLOR=blue>([cost])</FONT>"
	if(other_amounts.len)
		var/first=1
		html += " ("
		for(var/amount in other_amounts)
			if(!first)
				html +=" "
			html +="<A href='?src=\ref[context];action=create;item=[id];num=[amount]'>x[amount*amount_per_unit]</A>"
			first=0
		html += ")"
	html += "</li>"
	return html

/datum/biogen_recipe/food
	category="Food"

/datum/biogen_recipe/food/milk
	id="milk"
	name="milk"
	reagent="milk"
	cost=20
	amount_per_unit=10
	other_amounts=list(5)

/datum/biogen_recipe/food/meat
	id="meat"
	name="Slab of meat"
	cost=50
	other_amounts=list(5)
	result=/obj/item/weapon/reagent_containers/food/snacks/meat

/datum/biogen_recipe/nutrient
	category="Nutrients"

/datum/biogen_recipe/nutrient/ez
	id="ez"
	cost=10
	name="E-Z-Nutrient"
	other_amounts=list(5)
	result=/obj/item/nutrient/ez

/datum/biogen_recipe/nutrient/l4z
	id="l4z"
	cost=20
	name="Left 4 Zed"
	other_amounts=list(5)
	result=/obj/item/nutrient/l4z

/datum/biogen_recipe/nutrient/rh
	id="rh"
	cost=25
	name="Robust Harvest"
	other_amounts=list(5)
	result=/obj/item/nutrient/rh

/datum/biogen_recipe/leather
	category="Leather"

/datum/biogen_recipe/leather/wallet
	cost=100
	id="wallet"
	name="Wallet"
	result=/obj/item/weapon/storage/wallet

/datum/biogen_recipe/leather/gloves
	cost=250
	id="gloves"
	name="Botanical Gloves"
	result=/obj/item/clothing/gloves/botanic_leather

/datum/biogen_recipe/leather/belt
	cost=300
	id="belt"
	name="Utility Belt"
	result=/obj/item/weapon/storage/belt/utility

/datum/biogen_recipe/leather/plants
	cost=350
	id="plants"
	name="Plant Bag"
	result=/obj/item/weapon/storage/bag/plants

/datum/biogen_recipe/leather/satchel
	cost=400
	id="satchel"
	name="Leather Satchel"
	result=/obj/item/weapon/storage/backpack/satchel

/datum/biogen_recipe/misc
	category="Misc."

/datum/biogen_recipe/misc/pest
	cost=40
	id="pest"
	name="Pest Spray"
	other_amounts=list(5)
	result=/obj/item/weapon/pestspray

/datum/biogen_recipe/misc/beez
	cost=40
	id="beez"
	name="BeezEez"
	other_amounts=list(5)
	result=/obj/item/beezeez

/datum/biogen_recipe/misc/cardboard
	cost=200
	id="cardboard"
	name="Cardboard Sheet"
	other_amounts=list(5,10)
	result=/obj/item/stack/sheet/cardboard

/datum/biogen_recipe/misc/charcoal
	cost=100
	id="charcoal"
	name="Charcoal Sheet"
	other_amounts=list(5,10)
	result=/obj/item/stack/sheet/charcoal

/datum/biogen_recipe/misc/paper
	cost=75
	id="paper"
	name="Sheet of Paper"
	other_amounts=list(5,10)
	result=/obj/item/weapon/paper


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
	var/list/recipes[0]
	var/list/recipe_categories[0]

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)

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

/obj/machinery/biogenerator/New()
	. = ..()
	create_reagents(1000)
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/biogenerator,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/console_screen,\
		/obj/item/weapon/stock_parts/console_screen\
	)

	RefreshParts()

	for(var/biotype in typesof(/datum/biogen_recipe))
		var/datum/biogen_recipe/recipe = new biotype
		if(recipe.id=="") continue
		if(!(recipe.category in recipe_categories))
			recipe_categories[recipe.category]=list()
		recipe_categories[recipe.category] += recipe.id
		recipes[recipe.id]=recipe

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
			if(beaker)
				user << "\red A beaker is loaded, you cannot deconstruct [src]."
				return 1
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
						<A href='?src=\ref[src];action=detach'>Detach Container</A><BR><BR>"}

					for(var/cat in recipe_categories)
						dat += "<h2>[cat]</h2><ul>"
						for(var/rid in recipe_categories[cat])
							var/datum/biogen_recipe/recipe = recipes[rid]
							dat += recipe.Render(src)
						dat += "</ul>"

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
		playsound(get_turf(src), 'sound/machines/blender.ogg', 50, 1)
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

/obj/machinery/biogenerator/proc/create_product(var/item, var/num)
	var/datum/biogen_recipe/recipe=recipes[item]
	num=Clamp(num,1,10)
	if(check_cost(recipe.cost*num))
		return 0
	if(recipe.reagent)
		beaker.reagents.add_reagent(recipe.reagent,recipe.amount_per_unit*num)
	else
		if(istype(recipe.result,/obj/item/stack))
			var/obj/item/stack/stack=new recipe.result(src.loc)
			stack.amount=num*recipe.amount_per_unit
		else
			for(var/i=0;i<num;i++)
				new recipe.result(src.loc)
	processing = 0
	menustat = "complete"
	update_icon()
	return 1

/obj/machinery/biogenerator/Topic(href, href_list)
	if(stat & BROKEN) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.set_machine(src)

	//testing(href)

	switch(href_list["action"])
		if("activate")
			activate()
		if("detach")
			if(beaker)
				beaker.loc = src.loc
				beaker = null
				update_icon()
		if("create")
			create_product(href_list["item"],text2num(href_list["num"]))
		if("menu")
			menustat = "menu"
	updateUsrDialog()
