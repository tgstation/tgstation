#define STORAGE_CAPACITY 30
#define LIQUID_CAPACIY 200
#define MIXER_CAPACITY 100

/obj/machinery/food_cart
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	var/food_stored = 0
	var/glasses = 0
	var/portion = 10
	var/selected_drink
	var/list/stored_food = list()
	container_type = OPENCONTAINER
	var/obj/item/weapon/reagent_containers/mixer

/obj/machinery/food_cart/New()
	..()
	create_reagents(LIQUID_CAPACIY)
	reagents.set_reacting(FALSE)
	mixer = new /obj/item/weapon/reagent_containers(src, MIXER_CAPACITY)
	mixer.name = "Mixer"

/obj/machinery/food_cart/Destroy()
	if(mixer)
		qdel(mixer)
		mixer = null
	return ..()

/obj/machinery/food_cart/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/food_cart/interact(mob/user)
	var/dat
	dat += "<br><b>STORED INGREDIENTS AND DRINKS</b><br><div class='statusDisplay'>"
	dat += "Remaining glasses: [glasses]<br>"
	dat += "Portion: <a href='?src=\ref[src];portion=1'>[portion]</a><br>"
	for(var/datum/reagent/R in reagents.reagent_list)
		dat += "[R.name]: [R.volume] "
		dat += "<a href='?src=\ref[src];disposeI=[R.id]'>Purge</a>"
		if (glasses > 0)
			dat += "<a href='?src=\ref[src];pour=[R.id]'>Pour in a glass</a>"
		dat += "<a href='?src=\ref[src];mix=[R.id]'>Add to the mixer</a><br>"
	dat += "</div><br><b>MIXER CONTENTS</b><br><div class='statusDisplay'>"
	for(var/datum/reagent/R in mixer.reagents.reagent_list)
		dat += "[R.name]: [R.volume] "
		dat += "<a href='?src=\ref[src];transfer=[R.id]'>Transfer back</a>"
		if (glasses > 0)
			dat += "<a href='?src=\ref[src];m_pour=[R.id]'>Pour in a glass</a>"
		dat += "<br>"
	dat += "</div><br><b>STORED FOOD</b><br><div class='statusDisplay'>"
	for(var/V in stored_food)
		if(stored_food[V] > 0)
			dat += "<b>[V]: [stored_food[V]]</b> <a href='?src=\ref[src];dispense=[V]'>Dispense</a><br>"
	dat += "</div><br><a href='?src=\ref[src];refresh=1'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "foodcart","Food Cart", 500, 350, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/food_cart/proc/isFull()
	return food_stored >= STORAGE_CAPACITY

/obj/machinery/food_cart/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG = O
		if(!DG.reagents.total_volume) //glass is empty
			if(!user.drop_item())
				return
			qdel(DG)
			glasses++
			to_chat(user, "<span class='notice'>The [src] accepts the drinking glass, sterilizing it.</span>")
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		if(isFull())
			to_chat(user, "<span class='warning'>The [src] is at full capacity.</span>")
		else
			var/obj/item/weapon/reagent_containers/food/snacks/S = O
			if(!user.drop_item())
				return
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
			to_chat(user, "<span class='notice'>The [src] accepts a sheet of glass.</span>")
	else if(istype(O, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = O
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in T.contents)
			if(isFull())
				to_chat(user, "<span class='warning'>The [src] is at full capacity.</span>")
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
		. = ..()
	updateDialog()

/obj/machinery/food_cart/Topic(href, href_list)
	if(..())
		return

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
		portion = Clamp(input("How much drink do you want to dispense per glass?") as num, 0, 50)

	if(href_list["pour"] || href_list["m_pour"])
		if(glasses-- <= 0)
			to_chat(usr, "<span class='warning'>There are no glasses left!</span>")
			glasses = 0
		else
			var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG = new(loc)
			if(href_list["pour"])
				reagents.trans_id_to(DG, href_list["pour"], portion)
			if(href_list["m_pour"])
				mixer.reagents.trans_id_to(DG, href_list["m_pour"], portion)

	if(href_list["mix"])
		if(reagents.trans_id_to(mixer, href_list["mix"], portion) == 0)
			to_chat(usr, "<span class='warning'>The [mixer] is full!</span>")

	if(href_list["transfer"])
		if(mixer.reagents.trans_id_to(src, href_list["transfer"], portion) == 0)
			to_chat(usr, "<span class='warning'>The [src] is full!</span>")

	updateDialog()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null,"window=foodcart")
	return

/obj/machinery/food_cart/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)

#undef STORAGE_CAPACITY
#undef LIQUID_CAPACIY
#undef MIXER_CAPACITY
