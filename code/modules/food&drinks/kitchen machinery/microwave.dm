/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/max_n_of_items = 10 // whatever fat fuck made this a global var needs to look at themselves in the mirror sometime
	var/efficiency = 0
	var/microwavepower = 1


// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/microwave/New()
	create_reagents(100)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/microwave(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/microwave/RefreshParts()
	var/E
	var/max_items = 10
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_items = 10 * M.rating
	efficiency = E
	max_n_of_items = max_items

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(operating)
		return
	if(!broken && dirty<100)
		if(default_deconstruction_screwdriver(user, "mw-o", "mw", O))
			return
		if(default_unfasten_wrench(user, O))
			return
		if(exchange_parts(user, O))
			return

	if(default_deconstruction_crowbar(O))
		return

	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/wirecutters)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"[user] starts to fix part of the microwave.", \
				"<span class='notice'>You start to fix part of the microwave...</span>" \
			)
			if (do_after(user,20))
				user.visible_message( \
					"[user] fixes part of the microwave.", \
					"<span class='notice'>You fix part of the microwave.</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/weldingtool)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"[user] starts to fix part of the microwave.", \
				"<span class='notice'>You start to fix part of the microwave...</span>" \
			)
			if (do_after(user,20))
				user.visible_message( \
					"[user] fixes the microwave.", \
					"<span class='notice'>You fix the microwave.</span>" \
				)
				src.icon_state = "mw"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags = OPENCONTAINER
				return 0 //to use some fuel
		else
			user << "<span class='warning'>It's broken!</span>"
			return 1
	else if(istype(O, /obj/item/weapon/reagent_containers/spray/))
		var/obj/item/weapon/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent("cleaner",clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent("cleaner",clean_spray.amount_per_transfer_from_this,1)
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			user.visible_message( \
				"[user] has cleaned the microwave.", \
				"<span class='notice'>You clean the microwave.</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = "mw"
			src.flags = OPENCONTAINER
			src.updateUsrDialog()
			return 1 // Disables the after-attack so we don't spray the floor/user.
		else
			user << "<span class='warning'>You need more space cleaner!<span>"
			return 1

	else if(istype(O, /obj/item/weapon/soap/)) // If they're trying to clean it then let them
		var/obj/item/weapon/soap/P = O
		user.visible_message( \
			"[user] starts to clean the microwave.", \
			"<span class='notice'>You start to clean the microwave...</span>" \
		)
		if (do_after(user, P.cleanspeed))
			user.visible_message( \
				"[user] has cleaned the microwave.", \
				"<span class='notice'>You clean the microwave.</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = "mw"
			src.flags = OPENCONTAINER

	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		user << "<span class='warning'>It's dirty!</span>"
		return 1

	else if(istype(O, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/T = O
		var/loaded = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in T.contents)
			if (contents.len>=max_n_of_items)
				user << "<span class='warning'>[src] is full, you cannot put more!</span>"
				return 1
			T.remove_from_storage(S, src)
			loaded++

		if(loaded)
			user << "<span class='notice'>You insert [loaded] items into [src].</span>"


	else if(istype(O,/obj/item/weapon/reagent_containers/food/snacks))
		if (contents.len>=max_n_of_items)
			user << "<span class='warning'>[src] is full, you cannot put more!</span>"
			return 1
		else
		//	user.unEquip(O)	//This just causes problems so far as I can tell. -Pete
			if(!user.drop_item())
				user << "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>"
				return 0
			O.loc = src
			user.visible_message( \
				"[user] has added \the [O] to \the [src].", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")

	else
		..()
	updateUsrDialog()

/obj/machinery/microwave/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/microwave/attack_ai(mob/user as mob)
	return 0

/obj/machinery/microwave/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	interact(user)

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu
	if(panel_open || !anchored)
		return
	var/dat = "<div class='statusDisplay'>"
	if(broken > 0)
		dat += "ERROR: 09734014-A2379-D18746 --Bad memory<BR>Contact your operator or use command line to rebase memory ///git checkout {HEAD} -a commit pull --rebase push {*NEW HEAD*}</div>"    //Thats how all the git fiddling looks to me
	else if(operating)
		dat += "Microwaving in progress!<BR>Please wait...!</div>"
	else if(dirty==100)
		dat += "ERROR: >> 0 --Response input zero<BR>Contact your operator of the device manifactor support.</div>"
	else
		var/list/items_counts = new
		for (var/obj/O in contents)
			items_counts[O.name]++

		for (var/O in items_counts)
			var/N = items_counts[O]
			dat += "[capitalize(O)]: [N]<BR>"

		if (items_counts.len==0)
			dat += "The microwave is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=\ref[src];action=cook'>Turn on</A>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A><BR>"
		dat += "Microwave Power: [microwavepower*200]W<BR>"
		dat += "<A href='?src=\ref[src];action=power;amount=1'>200W</A>"
		dat += "<A href='?src=\ref[src];action=power;amount=2'>400W</A>"
		dat += "<A href='?src=\ref[src];action=power;amount=3'>600W</A>"
		dat += "<A href='?src=\ref[src];action=power;amount=4'>800W</A>"
		dat += "<A href='?src=\ref[src];action=power;amount=5'>1000W</A><BR>"

	var/datum/browser/popup = new(user, "microwave", name, 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()

	if (prob(max(microwavepower*5/efficiency-5,dirty*5))) //a clean unupgraded microwave on lowest power has no risk of failure
		muck_start()
		if (!microwaving(4))
			muck_finish()
			return
		muck_finish()
		return

	else if (has_extra_item())
		if (!microwaving(4))
			broke()
			return

		broke()
		return

	else

		if(!microwaving(10))
			abort()
			return
		stop()

		for(var/obj/item/weapon/reagent_containers/food/snacks/F in contents)
			if(F.cooked_type)
				var/obj/item/weapon/reagent_containers/food/snacks/S = new F.cooked_type (get_turf(src))
				F.initialize_cooked_food(S, efficiency)
				feedback_add_details("food_made","[F.name]")
			else
				new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(src)
				if(dirty < 100)
					dirty++
			qdel(F)

		return

/obj/machinery/microwave/proc/microwaving(var/seconds as num)
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(max(14-2*microwavepower-2*efficiency,2)) // standard power means sleep(10). The higher the power and the better the efficiency, the faster the cooking
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	visible_message("The microwave turns on.", "<span class='italics'>You hear a microwave humming.</span>")
	operating = 1
	icon_state = "mw1"
	updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	operating = 0 // Turn it off again aferwards
	icon_state = "mw"
	updateUsrDialog()

/obj/machinery/microwave/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	abort()

/obj/machinery/microwave/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	usr << "<span class='notice'>You dispose of the microwave contents.</span>"
	updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	visible_message("<span class='warning'>The microwave gets covered in muck!</span>")
	dirty = 100 // Make it dirty so it can't be used util cleaned
	icon_state = "mwbloody" // Make it look dirty too
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in src)
		if(prob(50))
			new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(src)
			qdel(S)

/obj/machinery/microwave/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	icon_state = "mwb" // Make it look all busted up and shit
	visible_message("<span class='warning'>The microwave breaks!</span>") //Let them know they're stupid
	broken = 2 // Make it broken so it can't be used util fixed
	flags = null //So you can't add condiments
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/microwave/Topic(href, href_list)
	if(..() || panel_open)
		return

	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()
		if ("power")
			var/amount = text2num(href_list["amount"])
			if(amount<1 || amount>5)
				return
			microwavepower = amount
	updateUsrDialog()
	return
