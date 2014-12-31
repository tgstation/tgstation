#define ICECREAM_VANILLA 1
#define ICECREAM_CHOCOLATE 2
#define ICECREAM_STRAWBERRY 3
#define ICECREAM_BLUE 4
#define CONE_WAFFLE 5
#define CONE_CHOC 6
#define STORAGE_CAPACITY 30

/obj/machinery/food_cart
	name = "food cart"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream, as well as other foods and drinks!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = 1
	anchored = 0
	use_power = 0
	var/food_stored = 0
	var/glasses = 0
	var/portion = 10
	var/list/stored_food = list()
	var/list/product_types = list()
	var/dispense_flavour = ICECREAM_VANILLA
	var/flavour_name = "vanilla"
	flags = OPENCONTAINER | NOREACT
	reagents = new()

/obj/machinery/food_cart/proc/get_ingredient_list(var/type)
	switch(type)
		if(ICECREAM_CHOCOLATE)
			return list("milk", "ice", "coco")
		if(ICECREAM_STRAWBERRY)
			return list("milk", "ice", "berryjuice")
		if(ICECREAM_BLUE)
			return list("milk", "ice", "singulo")
		if(CONE_WAFFLE)
			return list("flour", "sugar")
		if(CONE_CHOC)
			return list("flour", "sugar", "coco")
		else
			return list("milk", "ice")


/obj/machinery/food_cart/proc/get_flavour_name(var/flavour_type)
	switch(flavour_type)
		if(ICECREAM_CHOCOLATE)
			return "chocolate"
		if(ICECREAM_STRAWBERRY)
			return "strawberry"
		if(ICECREAM_BLUE)
			return "blue"
		if(CONE_WAFFLE)
			return "waffle"
		if(CONE_CHOC)
			return "chocolate"
		else
			return "vanilla"


/obj/machinery/food_cart/New()
	..()
	while(product_types.len < 6)
		product_types.Add(5)
	reagents.my_atom = src
	reagents.add_reagent("milk", 5)
	reagents.add_reagent("flour", 5)
	reagents.add_reagent("sugar", 5)
	reagents.add_reagent("ice", 5)

/obj/machinery/food_cart/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/food_cart/interact(mob/user as mob)
	var/dat
	dat += "<b>ICECREAM</b><br><div class='statusDisplay'>"
	dat += "<b>Dispensing: [flavour_name] icecream </b> <br><br>"
	dat += "<b>Vanilla icecream:</b> <a href='?src=\ref[src];select=[ICECREAM_VANILLA]'><b>Select</b></a> <a href='?src=\ref[src];make=[ICECREAM_VANILLA];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[ICECREAM_VANILLA];amount=5'><b>x5</b></a> [product_types[ICECREAM_VANILLA]] scoops left. (Ingredients: milk, ice)<br>"
	dat += "<b>Strawberry icecream:</b> <a href='?src=\ref[src];select=[ICECREAM_STRAWBERRY]'><b>Select</b></a> <a href='?src=\ref[src];make=[ICECREAM_STRAWBERRY];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[ICECREAM_STRAWBERRY];amount=5'><b>x5</b></a> [product_types[ICECREAM_STRAWBERRY]] dollops left. (Ingredients: milk, ice, berry juice)<br>"
	dat += "<b>Chocolate icecream:</b> <a href='?src=\ref[src];select=[ICECREAM_CHOCOLATE]'><b>Select</b></a> <a href='?src=\ref[src];make=[ICECREAM_CHOCOLATE];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[ICECREAM_CHOCOLATE];amount=5'><b>x5</b></a> [product_types[ICECREAM_CHOCOLATE]] dollops left. (Ingredients: milk, ice, coco powder)<br>"
	dat += "<b>Blue icecream:</b> <a href='?src=\ref[src];select=[ICECREAM_BLUE]'><b>Select</b></a> <a href='?src=\ref[src];make=[ICECREAM_BLUE];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[ICECREAM_BLUE];amount=5'><b>x5</b></a> [product_types[ICECREAM_BLUE]] dollops left. (Ingredients: milk, ice, singulo)<br></div>"
	dat += "<br><b>CONES</b><br><div class='statusDisplay'>"
	dat += "<b>Waffle cones:</b> <a href='?src=\ref[src];cone=[CONE_WAFFLE]'><b>Dispense</b></a> <a href='?src=\ref[src];make=[CONE_WAFFLE];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[CONE_WAFFLE];amount=5'><b>x5</b></a> [product_types[CONE_WAFFLE]] cones left. (Ingredients: flour, sugar)<br>"
	dat += "<b>Chocolate cones:</b> <a href='?src=\ref[src];cone=[CONE_CHOC]'><b>Dispense</b></a> <a href='?src=\ref[src];make=[CONE_CHOC];amount=1'><b>Make</b></a> <a href='?src=\ref[src];make=[CONE_CHOC];amount=5'><b>x5</b></a> [product_types[CONE_CHOC]] cones left. (Ingredients: flour, sugar, coco powder)<br></div>"
	dat += "<br><b>STORED INGREDIENTS AND DRINKS</b><br><div class='statusDisplay'>"
	dat += "Remaining glasses: [glasses]<br>"
	dat += "Portion: <a href='?src=\ref[src];portion=1'>[portion]</a><br>"
	dat += "<table><tr>"
	var/i = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		if(i % 3 == 0)
			dat += "</tr><tr>"
		dat += "<td>[R.name]: [R.volume] "
		dat += "<a href='?src=\ref[src];disposeI=[R.id]'>Purge</a>"
		if (glasses > 0)
			dat += "<a href='?src=\ref[src];pour=[R.id]'>Pour in a glass</a>"
		dat += "</td>"
		i++
	dat += "</tr></table></div><br><b>STORED FOOD</b><br><div class='statusDisplay'>"
	for(var/V in stored_food)
		if(stored_food[V] > 0)
			dat += "<b>[V]: [stored_food[V]]</b> <a href='?src=\ref[src];dispense=[V]'>Dispense</a><br>"
	dat += "</div><br><a href='?src=\ref[src];refresh=1'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "foodcart","Food Cart", 700, 600, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/food_cart/proc/isFull()
	return food_stored >= STORAGE_CAPACITY

/obj/machinery/food_cart/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/icecream))
		var/obj/item/weapon/reagent_containers/food/snacks/icecream/I = O
		if(!I.ice_creamed)
			if(product_types[dispense_flavour] > 0)
				src.visible_message("\icon[src] <span class='info'>[user] scoops delicious [flavour_name] icecream into [I].</span>")
				product_types[dispense_flavour] -= 1

				I.add_ice_cream(flavour_name)
			//	if(beaker)
			//		beaker.reagents.trans_to(I, 10)
				if(I.reagents.total_volume < 10)
					I.reagents.add_reagent("sugar", 10 - I.reagents.total_volume)
			else
				user << "<span class='warning'>There is not enough icecream left!</span>"
		else
			user << "<span class='notice'>[O] already has icecream in it.</span>"
		return 1
	else if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG = O
		if(!DG.reagents.total_volume) //glass is empty
			user.drop_item()
			qdel(DG)
			glasses++
			user << "<span class='notice'>The [src] accepts drinking glass, sterilizing it.</span>"
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		if(isFull())
			user << "<span class='warning'>The [src] is at full capacity.</span>"
		else
			var/obj/item/weapon/reagent_containers/food/snacks/S = O
			user.drop_item()
			S.loc = src
			if(stored_food[sanitize(S.name)])
				stored_food[sanitize(S.name)]++
			else
				stored_food[sanitize(S.name)] = 1
	else if(istype(O, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = O
		if(G.get_amount() >= 1)
			G.use(1)
			glasses += 4
			user << "<span class='notice'>The [src] accepts a sheet of glass.</span>"
	else if(istype(O, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = O
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in T.contents)
			if(isFull())
				user << "<span class='warning'>The [src] is at full capacity.</span>"
				break
			else
				T.remove_from_storage(S, src)
				if(stored_food[sanitize(S.name)])
					stored_food[sanitize(S.name)]++
				else
					stored_food[sanitize(S.name)] = 1
	else if(O.is_open_container())
		return
	else
		..()
	updateDialog()

/obj/machinery/food_cart/proc/make(var/mob/user, var/make_type, var/amount)
	for(var/R in get_ingredient_list(make_type))
		if(reagents.has_reagent(R, amount))
			continue
		amount = 0
		break
	if(amount)
		for(var/R in get_ingredient_list(make_type))
			reagents.remove_reagent(R, amount)
		product_types[make_type] += amount
		var/flavour = get_flavour_name(make_type)
		if(make_type > 4)
			src.visible_message("<span class='info'>[user] cooks up some [flavour] cones.</span>")
		else
			src.visible_message("<span class='info'>[user] whips up some [flavour] icecream.</span>")
	else
		user << "<span class='warning'>You don't have the ingredients to make this.</span>"

/obj/machinery/food_cart/Topic(href, href_list)
	if(..())
		return
	if(href_list["select"])
		dispense_flavour = text2num(href_list["select"])
		flavour_name = get_flavour_name(dispense_flavour)
		src.visible_message("<span class='notice'>[usr] sets [src] to dispense [flavour_name] flavoured icecream.</span>")

	if(href_list["cone"])
		var/dispense_cone = text2num(href_list["cone"])
		var/cone_name = get_flavour_name(dispense_cone)
		if(product_types[dispense_cone] >= 1)
			product_types[dispense_cone] -= 1
			var/obj/item/weapon/reagent_containers/food/snacks/icecream/I = new(src.loc)
			I.cone_type = cone_name
			I.icon_state = "icecream_cone_[cone_name]"
			I.desc = "Delicious [cone_name] cone, but no ice cream."
			src.visible_message("<span class='info'>[usr] dispenses a crunchy [cone_name] cone from [src].</span>")
		else
			usr << "<span class='warning'>There are no [cone_name] cones left!</span>"

	if(href_list["make"])
		var/amount = (text2num(href_list["amount"]))
		var/C = text2num(href_list["make"])
		make(usr, C, amount)

	if(href_list["disposeI"])
		reagents.del_reagent(href_list["disposeI"])

	if(href_list["dispense"])
		if(stored_food[href_list["dispense"]]-- <= 0)
			stored_food[href_list["dispense"]] = 0
		else
			for(var/obj/O in contents)
				if(sanitize(O.name) == href_list["dispense"])
					O.loc = src.loc
					break

	if(href_list["portion"])
		portion = max(0, min(50, input("How much drink do you want to dispense per glass?") as num))

	if(href_list["pour"])
		if(glasses-- <= 0)
			usr << "span class='warning'>There are no glasses left!</span>"
			glasses = 0
		else
			var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG = new(loc)
			reagents.trans_id_to(DG, href_list["pour"], portion)

	updateDialog()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null,"window=foodcart")
	return

/obj/item/weapon/reagent_containers/food/snacks/icecream
	name = "ice cream cone"
	desc = "Delicious waffle cone, but no ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone_waffle" //default for admin-spawned cones, href_list["cone"] should overwrite this all the time
	layer = 3.1
	var/ice_creamed = 0
	var/cone_type
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/icecream/New()
	create_reagents(20)
	reagents.add_reagent("nutriment", 5)

/obj/item/weapon/reagent_containers/food/snacks/icecream/proc/add_ice_cream(var/flavour_name)
	name = "[flavour_name] icecream"
	src.overlays += "icecream_[flavour_name]"
	desc = "Delicious [cone_type] cone with a dollop of [flavour_name] ice cream."
	ice_creamed = 1

#undef ICECREAM_VANILLA
#undef FLAVOUR_CHOCOLATE
#undef FLAVOUR_STRAWBERRY
#undef FLAVOUR_BLUE
#undef CONE_WAFFLE
#undef CONE_CHOC
#undef STORAGE_CAPACITY