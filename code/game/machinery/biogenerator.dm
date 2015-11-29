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
	result=/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh

/datum/biogen_recipe/food/monkeycube
	id="monkeycube"
	name="monkey cube"
	cost=250
	other_amounts=list(5)
	result=/obj/item/weapon/reagent_containers/food/snacks/monkeycube

/datum/biogen_recipe/nutrient
	category="Nutrients"

/datum/biogen_recipe/nutrient/ez
	id="ez"
	name="E-Z-Nutrient"
	reagent="eznutrient"
	cost=10
	amount_per_unit=10
	other_amounts=list(5)

/datum/biogen_recipe/nutrient/l4z
	id="l4z"
	name="Left 4 Zed"
	reagent="left4zed"
	cost=20
	amount_per_unit=10
	other_amounts=list(5)

/datum/biogen_recipe/nutrient/rh
	id="rh"
	name="Robust Harvest"
	reagent="robustharvest"
	cost=25
	amount_per_unit=10
	other_amounts=list(5)

/datum/biogen_recipe/nutrient/beez
	cost=40
	id="beez"
	name="Bottle of BeezEez"
	other_amounts=list(5)
	result=/obj/item/beezeez

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

/datum/biogen_recipe/leather/gadget
	cost=350
	id="gadget"
	name="Gadget Bag"
	result=/obj/item/weapon/storage/bag/gadgets

/datum/biogen_recipe/leather/ore
	cost=350
	id="ore"
	name="Mining Satchel"
	result=/obj/item/weapon/storage/bag/ore

/datum/biogen_recipe/leather/satchel
	cost=400
	id="satchel"
	name="Leather Satchel"
	result=/obj/item/weapon/storage/backpack/satchel

/datum/biogen_recipe/leather/briefcase
	cost=400
	id="briefcase"
	name="Leather Briefcase"
	result=/obj/item/weapon/storage/briefcase/biogen

/datum/biogen_recipe/paper
	category="Paper"

/datum/biogen_recipe/paper/papersheet
	cost=15
	id="papersheet"
	name="Paper Sheet"
	other_amounts=list(5,10)
	result=/obj/item/weapon/paper

/datum/biogen_recipe/paper/clipboard
	cost=75
	id="clipboard"
	name="Clipboard"
	result=/obj/item/weapon/clipboard

/datum/biogen_recipe/paper/cardboard
	cost=100
	id="cardboard"
	name="Cardboard Sheet"
	other_amounts=list(5,10)
	result=/obj/item/stack/sheet/cardboard

/datum/biogen_recipe/paper/giftwrap
	cost=300
	id="giftwrap"
	name="Gift Wrap"
	result=/obj/item/stack/package_wrap/gift

/datum/biogen_recipe/paper/packagewrap
	cost=350
	id="packagewrap"
	name="Package Wrap"
	result=/obj/item/stack/package_wrap

/datum/biogen_recipe/paper/paperbin
	cost=550 //100 from the cardboard, 30*15=450 from the paper
	id="paperbin"
	name="Paper Bin (30 sheets)"
	result=/obj/item/weapon/paper_bin

/datum/biogen_recipe/misc
	category="Misc."

/datum/biogen_recipe/misc/pest
	cost=40
	id="pest"
	name="Pest Spray"
	other_amounts=list(5)
	result=/obj/item/weapon/plantspray/pests

/datum/biogen_recipe/misc/candle
	cost=50
	id="candle"
	name="Red Candle"
	other_amounts=list(5)
	result=/obj/item/candle

/datum/biogen_recipe/misc/charcoal
	cost=100
	id="charcoal"
	name="Charcoal Sheet"
	other_amounts=list(5,10)
	result=/obj/item/stack/sheet/charcoal

/datum/biogen_recipe/misc/soap
	cost=250
	id="soap"
	name="Bar of Soap"
	result=/obj/item/weapon/soap/nanotrasen

/datum/biogen_recipe/misc/crayons
	cost=400
	id="crayons"
	name="Box of Crayons"
	result=/obj/item/weapon/storage/fancy/crayons

/datum/biogen_recipe/flooring
	category="Flooring"

/datum/biogen_recipe/flooring/carpet
	cost=10
	id="carpet"
	name="Piece of Carpet"
	other_amounts=list(5,10,20)
	result=/obj/item/stack/tile/carpet

/datum/biogen_recipe/flooring/arcade
	cost=10
	id="arcadecarpet"
	name="Piece of Arcade Carpet"
	other_amounts=list(5,10,20)
	result=/obj/item/stack/tile/arcade

/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = ""
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-stand"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/speed_coefficient = 15
	var/biomass_coefficient = 9
	var/processing = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/points = 0
	var/menustat = "menu"
	var/list/recipes[0]
	var/list/recipe_categories[0]

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	light_color = LIGHT_COLOR_CYAN
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

/obj/machinery/biogenerator/on_reagent_change()			//When the reagents change, change the icon as well.
	update_icon()

/obj/machinery/biogenerator/update_icon()
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

/obj/machinery/biogenerator/RefreshParts()
	var/manipcount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator)) manipcount += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser)) lasercount += SP.rating
	speed_coefficient = 2/manipcount
	biomass_coefficient = 3*lasercount

/obj/machinery/biogenerator/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return 1
	else if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>The biogenerator already occuped.</span>")
		else if(panel_open)
			to_chat(user, "<span class='rose'>The biogenerator's maintenance panel must be closed first.</span>")
		else
			user.before_take_item(O)
			O.loc = src
			beaker = O
			updateUsrDialog()
	else if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= 20)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
		else
			var/obj/item/weapon/storage/bag/B = O
			for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
				B.remove_from_storage(G,src)
				i++
				if(i >= 20)
					to_chat(user, "<span class='notice'>You fill the biogenerator to its capacity.</span>")
					break
			if(i<20)
				to_chat(user, "<span class='notice'>You empty the plant bag into the biogenerator.</span>")

	else if(!istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
		to_chat(user, "<span class='warning'>You cannot put this in [src.name]</span>")
	else
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= 20)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
		else
			user.before_take_item(O)
			O.loc = src
			to_chat(user, "<span class='notice'>You put [O.name] in [src.name]</span>")
	update_icon()
	return

/obj/machinery/biogenerator/crowbarDestroy(mob/user)
	if(beaker)
		to_chat(user, "<span class='warning'>A beaker is loaded, you cannot deconstruct \the [src].</span>")
		return
	return ..()

/obj/machinery/biogenerator/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(beaker)
		to_chat(user, "<span class='rose'>You can't open \the [src]'s maintenance panel while a beaker is loaded.</span>")
		return
	if(..())
		if(panel_open)
			overlays += "biogen-open"
		else
			overlays -= "biogen-open"
		update_icon()
		return 1
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
					// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\biogenerator.dm:89: dat += "<A href='?src=\ref[src];action=activate'>Activate Biogenerator!</A><BR>"
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
				// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\biogenerator.dm:108: dat += "You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.<BR>"
				dat += {"You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.<BR>
					<A href='?src=\ref[src];action=menu'>Return to menu</A>"}
				// END AUTOFIX
			if("complete")

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\biogenerator.dm:111: dat += "Operation complete.<BR>"
				dat += {"Operation complete.<BR>
					<A href='?src=\ref[src];action=menu'>Return to menu</A>"}
				// END AUTOFIX
			if("void")

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\biogenerator.dm:114: dat += "<FONT COLOR=red>Error: No growns inside.</FONT><BR>Please, put growns into reactor.<BR>"
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
		to_chat(usr, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return
	var/S = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount("nutriment") < 0.1)
			points += 1
		else points += I.reagents.get_reagent_amount("nutriment")*biomass_coefficient
		qdel(I)
	if(S)
		processing = 1
		update_icon()
		updateUsrDialog()
		playsound(get_turf(src), 'sound/machines/blender.ogg', 50, 1)
		use_power(S*30)
		sleep(speed_coefficient*(S+15))
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

	if(..()) return 1

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
