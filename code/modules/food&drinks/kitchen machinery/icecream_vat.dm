#define ICECREAM_VANILLA 1
#define FLAVOUR_CHOCOLATE 2
#define FLAVOUR_STRAWBERRY 3
#define FLAVOUR_BLUE 4
#define CONE_WAFFLE 5
#define CONE_CHOC 6
#define INGR_MILK 7
#define INGR_FLOUR 8
#define INGR_SUGAR 9
#define INGR_ICE 10
#define MUCK 11

var/list/ingredients_source = list(
"berryjuice" = FLAVOUR_STRAWBERRY,\
"coco" = FLAVOUR_CHOCOLATE,\
"singulo" = FLAVOUR_BLUE,\
"milk" = INGR_MILK,\
"soymilk" = INGR_MILK,\
"ice" = INGR_ICE,\
"flour" = INGR_FLOUR,\
"sugar" = INGR_SUGAR,\
)

/proc/get_icecream_flavour_string(var/flavour_type)
	switch(flavour_type)
		if(FLAVOUR_CHOCOLATE)
			return "chocolate"
		if(FLAVOUR_STRAWBERRY)
			return "strawberry"
		if(FLAVOUR_BLUE)
			return "blue"
		if(CONE_WAFFLE)
			return "waffle"
		if(CONE_CHOC)
			return "chocolate"
		if(INGR_MILK)
			return "milk"
		if(INGR_FLOUR)
			return "flour"
		if(INGR_SUGAR)
			return "sugar"
		if(INGR_ICE)
			return "ice"
		if(MUCK)
			return "muck"
		else
			return "vanilla"

/obj/machinery/icecream_vat
	name = "icecream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = 1
	anchored = 0
	var/list/ingredients = list()
	var/dispense_flavour = ICECREAM_VANILLA
	var/obj/item/weapon/reagent_containers/glass/held_container

/obj/machinery/icecream_vat/New()
	..()

	while(ingredients.len < 11)
		ingredients.Add(5)

/obj/machinery/icecream_vat/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/icecream_vat/interact(mob/user as mob)
	var/dat
	dat += "<a href='?src=\ref[src];dispense=[ICECREAM_VANILLA]'><b>Dispense vanilla icecream</b></a> There is [ingredients[ICECREAM_VANILLA]] scoops of vanilla icecream left (made from milk and ice).<br>"
	dat += "<a href='?src=\ref[src];dispense=[FLAVOUR_STRAWBERRY]'><b>Dispense strawberry icecream</b></a> There is [ingredients[FLAVOUR_STRAWBERRY]] dollops of strawberry flavouring left (obtained from berry juice.<br>"
	dat += "<a href='?src=\ref[src];dispense=[FLAVOUR_CHOCOLATE]'><b>Dispense chocolate icecream</b></a> There is [ingredients[FLAVOUR_CHOCOLATE]] dollops of chocolate flavouring left (obtained from cocoa powder).<br>"
	dat += "<a href='?src=\ref[src];dispense=[FLAVOUR_BLUE]'><b>Dispense blue icecream</b></a> There is [ingredients[FLAVOUR_BLUE]] dollops of blue flavouring left (obtained from bluespace tomato singulo).<br>"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];cone=[CONE_WAFFLE]'><b>Dispense waffle cones</b></a> There are [ingredients[CONE_WAFFLE]] waffle cones left. <br>"
	dat += "<a href='?src=\ref[src];cone=[CONE_CHOC]'><b>Dispense chocolate cones</b></a> There are [ingredients[CONE_CHOC]] chocolate cones left.<br>"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];make=[CONE_WAFFLE]'><b>Make waffle cones</b></a> There is [ingredients[INGR_FLOUR]]/[ingredients[INGR_SUGAR]] of flour and sugar left.<br>"
	dat += "<a href='?src=\ref[src];make=[CONE_CHOC]'><b>Make chocolate cones</b></a> There is [ingredients[FLAVOUR_CHOCOLATE]]/[ingredients[CONE_WAFFLE]] of chocolate flavouring and waffle cones left.<br>"
	dat += "<a href='?src=\ref[src];make=[ICECREAM_VANILLA]'><b>Make vanilla icecream</b></a> There is [ingredients[INGR_MILK]]/[ingredients[INGR_ICE]] of milk and ice left.<br>"
	dat += "<br>"
	if(held_container)
		dat += "<a href='?src=\ref[src];eject=1'>Eject [held_container]</a> "
	else
		dat += "No beaker inserted. "
	dat += "<a href='?src=\ref[src];refresh=1'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "icecreamvat","Icecream Vat", 700, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/icecream_vat/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers))
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/icecream))
			var/obj/item/weapon/reagent_containers/food/snacks/icecream/I = O
			if(!I.ice_creamed)
				if(ingredients[ICECREAM_VANILLA] > 0)
					var/flavour_name = get_icecream_flavour_string(dispense_flavour)
					if(ingredients[dispense_flavour] > 0)
						src.visible_message("\icon[src] <span class='info'>[user] scoops delicious [flavour_name] flavoured icecream into [I].</span>")
						ingredients[dispense_flavour] -= 1
						ingredients[ICECREAM_VANILLA] -= 1

						I.add_ice_cream(dispense_flavour)
						if(held_container)
							held_container.reagents.trans_to(I, 10)
						if(I.reagents.total_volume < 10)
							I.reagents.add_reagent("sugar", 10 - I.reagents.total_volume)
					else
						user << "<span class='warning'>There is not enough [flavour_name] flavouring left! Insert more of the required ingredients.</span>"
				else
					user << "<span class='warning'>There is not enough icecream left! Insert more milk and ice.</span>"
			else
				user << "<span class='notice'>[O] already has icecream in it.</span>"
		else if(istype(O, /obj/item/weapon/reagent_containers/glass))
			if(held_container)
				user << "<span class='notice'>You must remove [held_container] from [src] first.</span>"
			else
				user << "<span class='info'>You insert [O] into [src].</span>"
				user.drop_item()
				O.loc = src
				held_container = O
		else
			var/obj/item/weapon/reagent_containers/R = O
			if(R.reagents)
				src.visible_message("<span class='info'>[user] has emptied all of [R] into [src].</span>")
				for (var/datum/reagent/current_reagent in R.reagents.reagent_list)
					if(ingredients_source[current_reagent.id])
						add(ingredients_source[current_reagent.id], current_reagent.volume / 2)
					else
						add(MUCK, current_reagent.volume / 5)
				R.reagents.clear_reagents()
		return 1
	else
		..()

/obj/machinery/icecream_vat/proc/add(var/add_type, var/amount)
	if(add_type <= ingredients.len)
		ingredients[add_type] += amount
		updateDialog()

/obj/machinery/icecream_vat/proc/make(var/mob/user, var/make_type)
	switch(make_type)
		if(CONE_WAFFLE)
			if(ingredients[INGR_FLOUR] > 0 && ingredients[INGR_SUGAR] > 0)
				var/amount = max( min(ingredients[INGR_FLOUR], ingredients[INGR_SUGAR]), 5)
				ingredients[INGR_FLOUR] -= amount
				ingredients[INGR_SUGAR] -= amount
				ingredients[CONE_WAFFLE] += amount
				src.visible_message("<span class='info'>[user] cooks up some waffle cones.</span>")
			else
				user << "<span class='notice'>You require sugar and flour to make waffle cones.</span>"
		if(CONE_CHOC)
			if(ingredients[FLAVOUR_CHOCOLATE] > 0 && ingredients[CONE_WAFFLE] > 0)
				var/amount = min(ingredients[CONE_WAFFLE], ingredients[FLAVOUR_CHOCOLATE])
				ingredients[CONE_WAFFLE] -= amount
				ingredients[FLAVOUR_CHOCOLATE] -= amount
				ingredients[CONE_CHOC] += amount
				src.visible_message("<span class='info'>[user] cooks up some chocolate cones.</span>")
			else
				user << "<span class='notice'>You require waffle cones and chocolate flavouring to make chocolate cones.</span>"
		if(ICECREAM_VANILLA)
			if(ingredients[INGR_ICE] > 0 && ingredients[INGR_MILK] > 0)
				var/amount = min(ingredients[INGR_ICE], ingredients[INGR_MILK])
				ingredients[INGR_ICE] -= amount
				ingredients[INGR_MILK] -= amount
				ingredients[ICECREAM_VANILLA] += amount
				src.visible_message("<span class='info'>[user] whips up some vanilla icecream.</span>")
			else
				user << "<span class='notice'>You require milk and ice to make vanilla icecream.</span>"
	updateDialog()

/obj/machinery/icecream_vat/Topic(href, href_list)
	if(..())
		return
	if(href_list["dispense"])
		dispense_flavour = text2num(href_list["dispense"])
		src.visible_message("\blue[usr] sets [src] to dispense [get_icecream_flavour_string(dispense_flavour)] flavoured icecream.")

	if(href_list["cone"])
		var/dispense_cone = text2num(href_list["cone"])
		if(ingredients[dispense_cone] <= ingredients.len)
			var/cone_name = get_icecream_flavour_string(dispense_cone)
			if(ingredients[dispense_cone] >= 1)
				ingredients[dispense_cone] -= 1
				var/obj/item/weapon/reagent_containers/food/snacks/icecream/I = new(src.loc)
				I.cone_type = cone_name
				I.icon_state = "icecream_cone_[cone_name]"
				I.desc = "Delicious [cone_name] cone, but no ice cream."
				src.visible_message("<span class='info'>[usr] dispenses a crunchy [cone_name] cone from [src].</span>")
			else
				usr << "<span class='warning'>There are no [cone_name] cones left!</span>"
		updateDialog()

	if(href_list["make"])
		make( usr, text2num(href_list["make"]) )
		updateDialog()

	if(href_list["eject"])
		if(held_container)
			held_container.loc = src.loc
			held_container = null
		updateDialog()

	if(href_list["refresh"])
		updateDialog()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null,"window=icecreamvat")
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

/obj/item/weapon/reagent_containers/food/snacks/icecream/proc/add_ice_cream(var/flavour)
	var/flavour_name = get_icecream_flavour_string(flavour)
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
#undef INGR_MILK
#undef INGR_FLOUR
#undef INGR_SUGAR
#undef INGR_ICE
#undef MUCK
