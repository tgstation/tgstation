//The newest tool in the Mechanic's arsenal, the Rapid Machinery Component Exchanger (RMCE)
//It can load up a maximum of twenty-one machinery modules and can replace machinery modules without even having to rebuild them
//Useful if you want to replace a large amount of modules quickly and painlessly

/obj/item/weapon/storage/component_exchanger
	name = "rapid machinery component exchanger"
	desc = "A tool used to replace machinery components without having to deconstruct the entire machine. It can load up to twenty-one components at once"
	icon = 'icons/obj/device.dmi'
	icon_state = "comp_exchanger"
	gender = NEUTER
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	starting_materials = null
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=2;engineering=4;materials=5;programming=3"
	var/emagged = 0 //So we can emag it for "improved" functionality
	var/working = 0 //Busy check to make sure the user doesn't try to multi-task (this causes serious problems)

	allow_quick_gather = 1
	use_to_pickup = 1
	allow_quick_empty = 1
	storage_slots = 21
	can_hold = list("/obj/item/weapon/stock_parts")

/obj/item/weapon/storage/component_exchanger/attackby(var/atom/A, mob/user)
	if(istype(A, /obj/item/weapon/storage/bag/gadgets))
		var/obj/item/weapon/storage/bag/gadgets/G = A
		if(!contents)
			to_chat(user, "<span class='warning'>\The [G] is empty.</span>")
		for(var/obj/item/weapon/stock_parts/S in G.contents)
			if(src.contents.len < storage_slots)
				src.contents += S
			else
				to_chat(user, "<span class='notice'>You fill \the [src] to its capacity with \the [G]'s contents.</span>")
				return
		to_chat(user, "<span class='notice'>You fill up \the [src] with \the [G]'s contents.</span>")
		return 1
	else
		..()

//Redirect the attack only if it's a machine, otherwise don't bother
/obj/item/weapon/storage/component_exchanger/preattack(var/atom/A, var/mob/user, proximity_flag)

	if(!Adjacent(user))
		return

	if(istype(A, /obj/machinery))

		var/obj/machinery/M = A

		if(!M.panel_open)
			to_chat(user, "<span class='warning'>The maintenance hatch of \the [M] is closed, you can't just stab \the [src] into it and hope it'll work.</span>")
			return

		if(working) //We are already using the RMCE
			to_chat(user, "<span class='warning'>You are aleady using \the [src] on another machine. You'll have to pull it out or wait.</span>")
			return

		user.visible_message("<span class='notice'>[user] starts setting up \the [src] in \the [M]'s maintenance hatch</span>", \
		"<span class='notice'>You carefully insert \the [src] through \the [M]'s maintenance hatch, it starts scanning the machine's components.</span>")

		working = 1

		if(do_after(user, A, 20)) //Two seconds to obtain a complete reading of the machine's components

			if(!M.Adjacent(user))
				to_chat(user, "<span class='warning'>An error message flashes on \the [src]'s HUD, stating its scan was disrupted.</span>")
				working = 0
				return

			if(!M.component_parts) //This machine does not use components
				to_chat(user, "<span class='warning'>A massive error dump scrolls through \the [src]'s HUD. It looks like \the [M] has yet to be made compatible with this tool.</span>")
				working = 0
				return

			playsound(get_turf(src), 'sound/machines/Ping.ogg', 50, 1) //User feedback
			to_chat(user, "<span class='notice'>\The [src] pings softly. A small message appears on its HUD, instructing to not move until finished.")

			component_interaction(M, user) //Our job is done here, we transfer to the second proc (it needs to be recalled if needed)

			return

		else //Interrupted in some way
			to_chat(user, "<span class='warning'>An error message flashes on \the [src]'s HUD, stating its scan was disrupted.</span>")
			working = 0

			return
	return

/obj/item/weapon/storage/component_exchanger/proc/component_interaction(obj/machinery/M, mob/user)


	if(!M.Adjacent(user)) //We aren't hugging the machine, so don't bother. This'll prop up often
		to_chat(user, "<span class='warning'>A blue screen suddenly flashes on \the [src]'s HUD. It appears the critical failure was caused by suddenly yanking it out of \the [M]'s maintenance hatch.</span>")
		working = 0
		return //Done, done and done, pull out

	//Recurring option menu, what do we wish to do ?
	var/interactoption = alert("Select desired operation", "RMCE V.12 Ready", "Output Information", "Replace Component", "Finish Operation")

	if(interactoption == "Finish Operation") //Simplest case, the user wants out

		user.visible_message("<span class='notice'>[user] pulls \the [src] out of \the [M]'s maintenance hatch.</span>", \
		"<span class='notice'>A fancy log-out screen appears and \the [src]'s systems shut down. You pull it out of \the [M] carefully.</span>")
		working = 0
		return //Done

	if(interactoption == "Output Information") //This also acts as a data dumping tool, if needed

		var/ratingpool //Used to give an estimation of the machine's quality rating
		var/componentamount //Since the fucking circuit board is counted as a component, we can't use component_parts.len

		to_chat(user, "<span class='notice'><B>Scanning results for \the [M] :</B></span>")
		if(M.component_parts.len)
			for(var/obj/item/weapon/stock_parts/P in M.component_parts)
				sleep(5) //Slow the fuck down, we don't want to kill the user's UI, you can't read that fast anyways
				to_chat(user, "<span class='notice'><B>Detected :</B> [P] of effective quality rating [P.rating].</span>")
				ratingpool += P.rating
				componentamount++
			if(ratingpool)
				sleep(5)
				to_chat(user, "<span class='notice'><B>Effective quality rating of machine components : [ratingpool/componentamount].<B></span>")
		else
			sleep(5)
			to_chat(user, "<span class='warning'>No components detected. Please ensure the scanning unit is still functional.</span>")//Shouldn't happen

		sleep(5)
		to_chat(user, "<span class='info'>Note : You will be returned to the input menu shortly.</span>")

		spawn(5)
			component_interaction(M, user)
		return

	if(interactoption == "Replace Component")

		user.visible_message("<span class='notice'>[user] carefully fits \the [src] into \the [M] as it rattles and starts replacing components.</span>", \
		"<span class='notice'>\The [src]'s HUD flashes, a message appears stating it has started scanning and replacing \the [M]'s components.</span>")

		for(var/obj/item/weapon/stock_parts/P in M.component_parts)
			if(!Adjacent(user)) //Make sure the user doesn't move
				to_chat(user, "<span class='warning'>A blue screen suddenly flashes on \the [src]'s HUD. It appears the critical failure was caused by suddenly yanking it out of \the [M]'s maintenance hatch.</span>")
				return
			//Yes, an istype list. We don't have helpers for this, and this coder is not that sharp
			if(istype(P, /obj/item/weapon/stock_parts/capacitor))
				for(var/obj/item/weapon/stock_parts/capacitor/R in src.contents)
					if(R.rating > P.rating && P in M.component_parts) //Kind of a hack, but makes sure we don't replace components that already were
						sleep(5) //Half a second per component
						perform_indiv_replace(P, R, M)
						//Do not break in case we find even better
			if(istype(P, /obj/item/weapon/stock_parts/scanning_module))
				for(var/obj/item/weapon/stock_parts/scanning_module/R in src.contents)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(5) //Half a second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/manipulator))
				for(var/obj/item/weapon/stock_parts/manipulator/R in src.contents)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(5) //Half a second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
				for(var/obj/item/weapon/stock_parts/micro_laser/R in src.contents)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(5) //Half a second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
				for(var/obj/item/weapon/stock_parts/matter_bin/R in src.contents)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(5) //Half a second per component
						perform_indiv_replace(P, R, M)
			//Good thing there's only a few stock parts types

		M.RefreshParts()
		user.visible_message("<span class='notice'>[user]'s [name] stops rattling as it finishes working on \the [M]'s components.</span>", \
		"<span class='notice'>A message flashes on \the [src]'s HUD stating it has finished replacing [M]'s components and will return to the input screen shortly.</span>")

		spawn(5)
			component_interaction(M, user)

//So we don't copy the same thing a thousand fucking times
/obj/item/weapon/storage/component_exchanger/proc/perform_indiv_replace(var/obj/item/weapon/stock_parts/P, var/obj/item/weapon/stock_parts/R, var/obj/machinery/M)


	//Move the old part into our component exchanger
	M.component_parts -= P
	handle_item_insertion(P, 1)
	//Move the new part into the machine
	remove_from_storage(R, M)
	M.component_parts += R
	//Update the machine's parts
	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1) //User feedback
