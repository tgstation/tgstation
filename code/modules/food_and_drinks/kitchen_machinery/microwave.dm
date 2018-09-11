/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASSTABLE
	var/operating = FALSE // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/max_n_of_items = 10 // whatever fat fuck made this a global var needs to look at themselves in the mirror sometime
	var/efficiency = 0
	var/datum/looping_sound/microwave/soundloop

//Microwaving doesn't use recipes, instead it calls the microwave_act of the objects. For food, this creates something based on the food's cooked_type

/*******************
*   Initialising
********************/

/obj/machinery/microwave/Initialize()
	. = ..()
	create_reagents(100)
	soundloop = new(list(src), FALSE)

/obj/machinery/microwave/RefreshParts()
	var/E
	var/max_items = 10
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		max_items = 10 * M.rating
	efficiency = E
	max_n_of_items = max_items

/obj/machinery/microwave/examine(mob/user)
	..()
	if(!operating)
		to_chat(user, "<span class='notice'>Alt-click [src] to turn it on.</span>")

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(obj/item/O, mob/user, params)
	if(operating)
		return
	if(!broken && dirty<100)
		if(default_deconstruction_screwdriver(user, "mw-o", "mw", O))
			return
		if(default_unfasten_wrench(user, O))
			return

	if(default_deconstruction_crowbar(O))
		return

	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/wirecutters)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"[user] starts to fix part of the microwave.", \
				"<span class='notice'>You start to fix part of the microwave...</span>" \
			)
			if (O.use_tool(src, user, 20))
				user.visible_message( \
					"[user] fixes part of the microwave.", \
					"<span class='notice'>You fix part of the microwave.</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weldingtool)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"[user] starts to fix part of the microwave.", \
				"<span class='notice'>You start to fix part of the microwave...</span>" \
			)
			if (O.use_tool(src, user, 20))
				user.visible_message( \
					"[user] fixes the microwave.", \
					"<span class='notice'>You fix the microwave.</span>" \
				)
				src.icon_state = "mw"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.container_type = OPENCONTAINER
				return 0 //to use some fuel
		else
			to_chat(user, "<span class='warning'>It's broken!</span>")
			return 1
	else if(istype(O, /obj/item/reagent_containers/spray/))
		var/obj/item/reagent_containers/spray/clean_spray = O
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
			src.container_type = OPENCONTAINER
			src.updateUsrDialog()
			return 1 // Disables the after-attack so we don't spray the floor/user.
		else
			to_chat(user, "<span class='warning'>You need more space cleaner!</span>")
			return 1

	else if(istype(O, /obj/item/soap/)) // If they're trying to clean it then let them
		var/obj/item/soap/P = O
		user.visible_message( \
			"[user] starts to clean the microwave.", \
			"<span class='notice'>You start to clean the microwave...</span>" \
		)
		if (do_after(user, P.cleanspeed, target = src))
			user.visible_message( \
				"[user] has cleaned the microwave.", \
				"<span class='notice'>You clean the microwave.</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = "mw"
			src.container_type = OPENCONTAINER

	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		to_chat(user, "<span class='warning'>It's dirty!</span>")
		return 1

	else if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/item/reagent_containers/food/snacks/S in T.contents)
			if (contents.len>=max_n_of_items)
				to_chat(user, "<span class='warning'>[src] is full, you can't put anything in!</span>")
				return 1
			if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
				loaded++

		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] items into [src].</span>")


	else if(O.w_class <= WEIGHT_CLASS_NORMAL && !istype(O, /obj/item/storage) && user.a_intent == INTENT_HELP)
		if (contents.len>=max_n_of_items)
			to_chat(user, "<span class='warning'>[src] is full, you can't put anything in!</span>")
			return 1
		else
			if(!user.transferItemToLoc(O, src))
				to_chat(user, "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>")
				return 0

			user.visible_message( \
				"[user] has added \the [O] to \the [src].", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")

	else
		..()
	updateUsrDialog()

/obj/machinery/microwave/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE) && !(operating || broken > 0 || panel_open || !anchored || dirty == 100))
		cook()

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/ui_interact(mob/user) // The microwave Menu
	. = ..()
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
			if(istype(O, /obj/item/stack/))
				var/obj/item/stack/S = O
				items_counts[O.name] += S.amount
			else
				items_counts[O.name]++

		for (var/O in items_counts)
			var/N = items_counts[O]
			dat += "[capitalize(O)]: [N]<BR>"

		if (items_counts.len==0)
			dat += "The microwave is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=[REF(src)];action=cook'>Turn on</A>"
		dat += "<A href='?src=[REF(src)];action=dispose'>Eject ingredients</A><BR>"

	var/datum/browser/popup = new(user, "microwave", name, 300, 300)
	popup.set_content(dat)
	popup.open()

/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()

	if (prob(max(5/efficiency-5,dirty*5))) //a clean unupgraded microwave has no risk of failure
		muck_start()
		if (!microwaving(4))
			muck_finish()
			return
		muck_finish()
		return

	else
		if(has_extra_item() && prob(min(dirty*5,100)) && !microwaving(4))
			broke()
			return

		if(!microwaving(10))
			abort()
			return
		stop()

		var/metal = 0
		for(var/obj/item/O in contents)
			O.microwave_act(src)
			if(O.materials[MAT_METAL])
				metal += O.materials[MAT_METAL]

		if(metal)
			visible_message("<span class='warning'>Sparks fly around [src]!</span>")
			if(prob(max(metal/2, 33)))
				explosion(loc,0,1,2)
			broke()
			return

		dropContents()
		return

/obj/machinery/microwave/proc/microwaving(seconds as num)
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(max(12-2*efficiency,2)) // standard microwave means sleep(10). The better the efficiency, the faster the cooking
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O, /obj/item/reagent_containers/food) && \
				!istype(O, /obj/item/grown) \
			)
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	visible_message("The microwave turns on.", "<span class='italics'>You hear a microwave humming.</span>")
	soundloop.start()
	operating = TRUE
	icon_state = "mw1"
	updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	operating = FALSE // Turn it off again aferwards
	icon_state = "mw"
	updateUsrDialog()
	soundloop.stop()

/obj/machinery/microwave/proc/stop()
	abort()

/obj/machinery/microwave/proc/dispose()
	for (var/obj/O in contents)
		O.forceMove(drop_location())
	to_chat(usr, "<span class='notice'>You dispose of the microwave contents.</span>")
	updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	visible_message("<span class='warning'>The microwave gets covered in muck!</span>")
	dirty = 100 // Make it dirty so it can't be used util cleaned
	icon_state = "mwbloody" // Make it look dirty too
	operating = FALSE // Turn it off again aferwards
	updateUsrDialog()
	for(var/obj/item/reagent_containers/food/snacks/S in src)
		if(prob(50))
			new /obj/item/reagent_containers/food/snacks/badrecipe(src)
			qdel(S)
	soundloop.stop()

/obj/machinery/microwave/proc/broke()
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	icon_state = "mwb" // Make it look all busted up and shit
	visible_message("<span class='warning'>The microwave breaks!</span>") //Let them know they're stupid
	broken = 2 // Make it broken so it can't be used util fixed
	flags_1 = null //So you can't add condiments
	operating = FALSE // Turn it off again aferwards
	updateUsrDialog()
	soundloop.stop()

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
	updateUsrDialog()
