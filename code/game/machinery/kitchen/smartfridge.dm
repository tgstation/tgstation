/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
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
	var/ispowered = 1 //starts powered
	var/isbroken = 0
	var/opened = 0.0

	machine_flags = SCREWTOGGLE | CROWDESTROY

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)


/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/smartfridge/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smartfridge,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/) || istype(O, /obj/item/weapon/grown) || istype(O,/obj/item/seeds/) || istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat/) || istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/))
		return 1
	else
		..()

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"

	l_color = "#000000"

/obj/machinery/smartfridge/seeds/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge_chem"
	req_one_access = list(access_chemistry, access_medical)


/obj/machinery/smartfridge/secure/medbay/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/))
		return 1
	if(istype(O,/obj/item/weapon/storage/pill_bottle/))
		return 1
	if(istype(O,/obj/item/weapon/reagent_containers/pill/))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

/obj/machinery/smartfridge/chemistry/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/storage/pill_bottle) || istype(O,/obj/item/weapon/reagent_containers))
		return 1
	return 0

/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"

/obj/machinery/smartfridge/extract/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0


/obj/machinery/smartfridge/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		if(!isbroken)
			icon_state = icon_on
	else
		spawn(rand(0, 15))
		src.ispowered = 0
		stat |= NOPOWER
		if(!isbroken)
			icon_state = icon_off


/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(!src.ispowered)
		user << "<span class='notice'>\The [src] is unpowered and useless.</span>"
		return

	if(accept_check(O))
		if(contents.len >= max_n_of_items)
			user << "<span class='notice'>\The [src] is full.</span>"
			return 1
		else
			user.before_take_item(O)
			O.loc = src
			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
								 "<span class='notice'>You add \the [O] to \the [src].")

	else if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/bag = O
		var/objects_loaded = 0
		for(var/obj/G in bag.contents)
			if(accept_check(G))
				if(contents.len >= max_n_of_items)
					user << "<span class='notice'>\The [src] is full.</span>"
					return 1
				else
					bag.remove_from_storage(G,src)
					if(item_quants[G.name])
						item_quants[G.name]++
					else
						item_quants[G.name] = 1
					objects_loaded++
		if(objects_loaded)

			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [bag].</span>", \
								 "<span class='notice'>You load \the [src] with \the [bag].</span>")
			if(bag.contents.len > 0)
				user << "<span class='notice'>Some items are refused.</span>"

	else
		user << "<span class='notice'>\The [src] smartly refuses [O].</span>"
		return 1

	updateUsrDialog()

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
	if(!src.ispowered)
		return

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\kitchen\smartfridge.dm:140: dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
				dat += {"<FONT color = 'blue'><B>[capitalize(O)]</B>:
					[N] </font>
					<a href='byond://?src=\ref[src];vend=[O];amount=1'>Vend</A> "}
				// END AUTOFIX
				if(N > 5)
					dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=5'>x5</A>)"
					if(N > 10)
						dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=10'>x10</A>)"
						if(N > 25)
							dat += "(<a href='byond://?src=\ref[src];vend=[O];amount=25'>x25</A>)"
				if(N > 1)
					dat += "(<a href='?src=\ref[src];vend=[O];amount=[N]'>All</A>)"
				dat += "<br>"

		dat += "</TT>"
	user << browse("<HEAD><TITLE>[src] Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=smartfridge")
	onclose(user, "smartfridge")
	return

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

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
