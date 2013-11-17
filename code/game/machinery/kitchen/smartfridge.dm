// -------------------------
//  SmartFridge.  Much todo
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	var/global/max_n_of_items = 999 // Sorry but the BYOND infinite loop detector doesn't look things over 1000.
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/item_quants = list()
/*
/obj/machinery/smartfridge/power_change()
	..()
	update_icon()
*/
/obj/machinery/smartfridge/update_icon()
	if(!stat)
		icon_state = icon_on
	else
		icon_state = icon_off



/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat)
		return 0

	if(contents.len >= max_n_of_items)
		user << "<span class='notice'>\The [src] is full.</span>"
		return 0

	if(accept_check(O))
		load(O)
		user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", "<span class='notice'>You add \the [O] to \the [src].")
		updateUsrDialog()
		return 1

	var/loaded = 0

	if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/P = O
		for(var/obj/G in P.contents)
			if(contents.len >= max_n_of_items)
				break
			if(accept_check(G))
				load(G)
				loaded++
	else if(istype(O, /obj/item/weapon/tray))
		var/obj/item/weapon/tray/T = O
		for(var/obj/item/snack in T)
			if(contents.len >= max_n_of_items)
				break
			if(accept_check(snack))
				T.carrying -= snack
				load(snack)
				loaded++
	else
		user << "<span class='notice'>\The [src] smartly refuses [O].</span>"
		updateUsrDialog()
		return 0

	// this is a little backwards but it avoids duplication.
	// this code follows storage items and trays only.
	if(loaded)
		if(contents.len >= max_n_of_items)
			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [O].</span>", \
							 "<span class='notice'>You fill \the [src] with \the [O].</span>")
		else
			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [O].</span>", \
								 "<span class='notice'>You load \the [src] with \the [O].</span>")
		if(O.contents.len > 0)
			user << "<span class='notice'>Some items are refused.</span>"
	else
		user << "There is nothing in [O] to put in [src]."
		return 0

	updateUsrDialog()
	return 1



/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/proc/load(var/obj/item/O as obj)
	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		M.before_take_item(O)
	else if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src
	var/n = O.name

	if(item_quants[n])
		item_quants[n]++
	else
		item_quants[n] = 1

/obj/machinery/smartfridge/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user as mob)
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/interact(mob/user as mob)
	if(stat)
		return

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]
				dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
				dat += " [N] </font>"
				dat += "<a href='byond://?src=\ref[src];vend=[O];amount=1'>Vend</A> "
				if(N > 5)
					dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=5'>x5</A>)"
					if(N > 10)
						dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=10'>x10</A>)"
						if(N > 25)
							dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=25'>x25</A>)"
				if(N > 1)
					dat += "(<a href='?src=\ref[src];vend=[O];amount=[N]'>All</A>)"
				/*
				if((findtext(O,"seeds") || findtext(O,"mycelium")) && N>1)
					var/max_bags = round((N-1)/7)+1
					dat += "(<a href='?src=\ref[src];bagvend=[O];amount=1'>1 Bag</A>)"
					if(max_bags > 2) // at least 14
						dat += "(<a href='?src=\ref[src];bagvend=[O];amount=2'>2 Bags</A>)"
						if(max_bags > 5) // at least 35
							dat += "(<a href='?src=\ref[src];bagvend=[O];amount=5'>5 Bags</A>)"
					if(max_bags > 1)
						dat += "(<a href='?src=\ref[src];bagvend=[O];amount=[max_bags]'>Bag All</A>)"
				*/
				dat += "<br>"

		dat += "</TT>"
	user << browse("<HEAD><TITLE>[src] Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=smartfridge")
	onclose(user, "smartfridge")
	return

/obj/machinery/smartfridge/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)
	/*
	if(href_list["bagvend"]) // bag seeds and dispense
		var/N = href_list["bagvend"]
		var/amount = text2num(href_list["amount"])

		if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
			return

		item_quants[N] = max(item_quants[N] - amount*7, 0)

		var/i = amount * 7
		var/j = 0
		var/obj/item/weapon/storage/bag/seeds/SB = new(loc)
		for(var/obj/O in contents)
			if(name_filter(O.name) == N)
				O.loc = SB
				i--
				j++
				if(i <= 0)
					break
				if(j >= 7)
					j = 0
					SB.update_icon()
					SB = new(loc)
		SB.update_icon()

		src.updateUsrDialog()
		return
	*/
	var/N = href_list["vend"]
	var/amount = text2num(href_list["amount"])

	if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
		return

	item_quants[N] = max(item_quants[N] - amount, 0)

	var/i = amount
	for(var/obj/O in contents)
		if(O.name == N)
			O.loc = src.loc
			i--
			if(i <= 0)
				break

	src.updateUsrDialog()
	return

// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(var/obj/item/O as obj)
	if(!istype(O,/obj/item/weapon/reagent_containers) || !O.reagents || !O.reagents.reagent_list.len)
		return 0
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1


// -------------------------------------
// Xenobiology Slime-Extract Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/extract
	name = "smart slime extract storage"
	desc = "A refrigerated storage unit for slime extracts."

/obj/machinery/smartfridge/extract/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0

// -----------------------------
// Chemistry Medical Smartfridge
// -----------------------------
/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	var/list/spawn_meds = list(/obj/item/weapon/reagent_containers/pill/inaprovaline = 12,/obj/item/weapon/reagent_containers/pill/antitox = 1,
								/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 1, /obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 1)

/obj/machinery/smartfridge/chemistry/New()
	..()
	for(var/typekey in spawn_meds)
		var/amount = spawn_meds[typekey]
		if(isnull(amount)) amount = 1
		while(amount)
			var/obj/item/I = new typekey(src)
			load(I)
			amount--

/obj/machinery/smartfridge/chemistry/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		if(O.contents.len)
			for(var/obj/item/I in O)
				if(!accept_check(I))
					return 0
			return 1
		return 0
	if(!istype(O,/obj/item/weapon/reagent_containers))
		return 0
	if(istype(O,/obj/item/weapon/reagent_containers/pill)) // empty pill prank ok
		return 1
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return 0
	if(istype(O,/obj/item/weapon/reagent_containers/syringe) || istype(O,/obj/item/weapon/reagent_containers/glass/bottle) || istype(O,/obj/item/weapon/reagent_containers/glass/beaker) || istype(O,/obj/item/weapon/reagent_containers/spray))
		return 1
	return 0

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	spawn_meds = list(/obj/item/weapon/reagent_containers/syringe/antiviral = 4, /obj/item/weapon/reagent_containers/glass/bottle/cold = 1, /obj/item/weapon/reagent_containers/glass/bottle/flu_virion = 1, /obj/item/weapon/reagent_containers/glass/bottle/mutagen = 1, /obj/item/weapon/reagent_containers/glass/bottle/synaptizine = 1)