//The newest tool in the Mechanic's arsenal, the Rapid Machinery Component Exchanger (RMCE)
//It can load up a maximum of ten machinery modules and can replace machinery modules without even having to rebuild them
//Useful if you want to replace a large amount of modules quickly and painlessly

/obj/item/device/component_exchanger
	name = "rapid machinery component exchanger"
	desc = "A tool used to replace machinery components without having to deconstruct them. It can load up to ten components at once"
	icon = 'icons/obj/device.dmi'
	icon_state = "comp_exchanger"
	gender = NEUTER
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	m_amt = 0 //So the autolathe doesn't try to eat it
	g_amt = 0
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=2;engineering=4;materials=5;programming=3"
	var/list/componentstorage = list()
	var/maxcomponents = 20
	var/emagged = 0 //So we can emag it for "improved" functionality

//Do a quick check-up of what is loaded
/obj/item/device/component_exchanger/attack_self(var/mob/user)

	self_interact_menu(user)

/obj/item/device/component_exchanger/attackby(var/atom/A, mob/user)

	if(istype(A, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/P = A
		if(componentstorage.len < maxcomponents) //We have room
			user.visible_message("<span class='notice'>[user] slots \a [P] into \the [src]'s component storage</span>", \
			"<span class='notice'>You slot \a [P] into \the [src]'s component storage</span>")
			user.drop_item(P)
			componentstorage += P //Add it to the proper component storage list
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1) //User feedback
		else
			user << "<span class='warning'>\The [src] is full.</span>"
	else if(istype(A, /obj/item/weapon/storage/bag/gadgets))
		var/obj/item/weapon/storage/bag/gadgets/G = A
		if(!contents)
			user << "<span class='warning'>\The [G] is empty.</span>"
		for(var/obj/item/weapon/stock_parts/S in G.contents)
			if(componentstorage.len < maxcomponents)
				componentstorage += S
			else
				user << "<span class='notice'>You fill \the [src] to its capacity with \the [G]'s contents.</span>"
				return
		user << "<span class='notice'>You fill up \the [src] with \the [G]'s contents.</span>"

//Redirect the attack only if it's a machine, otherwise don't bother
/obj/item/device/component_exchanger/preattack(var/atom/A, var/mob/user, proximity_flag)

	if(!Adjacent(user))
		return

	if(istype(A, /obj/machinery))

		var/obj/machinery/M = A

		if(!M.panel_open)
			user << "<span class='warning'>The maintenance hatch of \the [M] is closed, you can't just stab \the [src] into it and hope it'll work.</span>"
			return

		user.visible_message("<span class='notice'>[user] starts setting up \a [src] in \the [M]'s maintenance hatch</span>", \
		"<span class='notice'>You carefully insert \the [src] through \the [M]'s maintenance hatch, it starts scanning the machine's components.</span>")

		if(do_after(user, 30)) //3 seconds to obtain a complete reading of the machine's components

			if(!Adjacent(user))
				user << "<span class='warning'>An error message flashes on \the [src]'s HUD, stating its scan was disrupted.</span>"
				return

			if(!M.component_parts) //This machine does not use components
				user << "<span class='warning'>A massive error dump scrolls through \the [src]'s HUD. It looks like \the [M] has yet to be made compatible with this tool.</span>"
				return

			playsound(get_turf(src), 'sound/machines/Ping.ogg', 50, 1) //User feedback
			user << "<span class='notice'>\The [src] pings softly. A small message appears on its HUD, instructing to not move until finished."

			component_interaction(M, user) //Our job is done here, we transfer to the second proc (it needs to be recalled if needed)

			return
	return

/obj/item/device/component_exchanger/proc/component_interaction(obj/machinery/M, mob/user)

	if(!Adjacent(user)) //We aren't hugging the machine, so don't bother. This'll prop up often
		user << "<span class='warning'>A blue screen suddenly flashes on \the [src]'s HUD. It appears the critical failure was caused by suddenly yanking it out of \the [M]'s maintenance hatch.</span>"
		return //Done, done and done, pull out

	//Recurring option menu, what do we wish to do ?
	var/interactoption = alert("Select desired operation", "RMCE V.12 Ready", "Output Information", "Replace Component", "Finish Operation")

	if(interactoption == "Finish Operation") //Simplest case, the user wants out

		user.visible_message("<span class='notice'>[user] pulls \the [src] out of \the [M]'s maintenance hatch.</span>", \
		"<span class='notice'>A fancy log-out screen appears and \the [src]'s systems shut down. You pull it out of \the [M] carefully.</span>")
		return //Done

	if(interactoption == "Output Information") //This also acts as a data dumping tool, if needed

		var/dat
		var/ratingpool //Used to give an estimation of the machine's quality rating
		var/componentamount //Since the fucking circuit board is counted as a component, we can't use component_parts.len

		dat += "<B>Scanning results for \the [M] :</B><BR><BR>"
		if(M.component_parts.len)
			for(var/obj/item/weapon/stock_parts/P in M.component_parts)
				dat += "<B>Detected :</B> [P] of effective quality rating [P.rating].<BR>"
				ratingpool += P.rating
				componentamount++
			if(ratingpool)
				dat += "<BR>Effective quality rating of machine components : [ratingpool/componentamount].<BR>"
		else
			dat += "No components detected. Please ensure the scanning unit is still functional.<BR>" //Shouldn't happen
		dat += "<BR><I>Note : You will be returned to the input menu shortly.</I>"

		user.visible_message("<span class='notice'>[user] looks at \the [src]'s HUD as it starts a full data scan on \the [M].</span>", \
		"<span class='notice'>You take a closer look at \the [src]'s HUD as it starts data scanning \the [M].</span>")
		if(do_after(user, 50)) //Shouldn't be interrupted
			user << browse(dat, "window=componentanal") //Send them the data, in a window
			onclose(user, "componentanal")

			spawn(30)
				component_interaction(M, user)
			return
		else
			user << "<span class='warning'>A blue screen suddenly flashes on \the [src]'s HUD. It appears the critical failure was caused by suddenly yanking it out of \the [M]'s maintenance hatch.</span>"

	if(interactoption == "Replace Component")

		user.visible_message("<span class='notice'>[user] carefully fits \the [src] into \the [M] as it rattles and starts remplacing components.</span>", \
		"<span class='notice'>\The [src]'s HUD flashes, a message appears stating it has started scanning and replacing \the [M]'s components.</span>")

		for(var/obj/item/weapon/stock_parts/P in M.component_parts)
			if(!Adjacent(user)) //Make sure the user doesn't move
				user << "<span class='warning'>A blue screen suddenly flashes on \the [src]'s HUD. It appears the critical failure was caused by suddenly yanking it out of \the [M]'s maintenance hatch.</span>"
				return
			//Yes, an istype list. We don't have helpers for this, and this coder is not that sharp
			if(istype(P, /obj/item/weapon/stock_parts/capacitor))
				for(var/obj/item/weapon/stock_parts/capacitor/R in componentstorage)
					if(R.rating > P.rating && P in M.component_parts) //Kind of a hack, but makes sure we don't replace components that already were
						sleep(10) //One second per component
						perform_indiv_replace(P, R, M)
						//Do not break in case we find even better
			if(istype(P, /obj/item/weapon/stock_parts/scanning_module))
				for(var/obj/item/weapon/stock_parts/scanning_module/R in componentstorage)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(10) //One second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/manipulator))
				for(var/obj/item/weapon/stock_parts/manipulator/R in componentstorage)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(10) //One second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
				for(var/obj/item/weapon/stock_parts/micro_laser/R in componentstorage)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(10) //One second per component
						perform_indiv_replace(P, R, M)
			if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
				for(var/obj/item/weapon/stock_parts/matter_bin/R in componentstorage)
					if(R.rating > P.rating && P in M.component_parts)
						sleep(10) //One second per component
						perform_indiv_replace(P, R, M)
			//Good thing there's only a few stock parts types

		M.RefreshParts()
		user.visible_message("<span class='notice'>[user] pulls \the [src] out of \the [M] as it finishes remplacing components.</span>", \
		"<span class='notice'>You pull \the [src] out of \the [M] as a message flashes on its HUD stating it has finished remplacing components and will return to the input screen shortly.</span>")

		spawn(30)
			component_interaction(M, user)

//So we don't copy the same thing a thousand fucking times
/obj/item/device/component_exchanger/proc/perform_indiv_replace(var/obj/item/weapon/stock_parts/P, var/obj/item/weapon/stock_parts/R, var/obj/machinery/M)

	//Move the old part into our component exchanger
	componentstorage += P
	M.component_parts -= P
	//Move the new part into the machine
	M.component_parts += R
	componentstorage -= R
	//Update the machine's parts
	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1) //User feedback

//Option menu if you interact with the component exchanger
/obj/item/device/component_exchanger/proc/self_interact_menu(var/mob/user)


	var/self_option = alert("Select desired operation", "RMCE V.12 Ready", "Unload Components", "Scan Loaded Components", "Finish Operation")

	if(user.get_active_hand() != src) //Object not in active hand anymore
		return

	if(self_option == "Finish Operation")

		user << "<span class='notice'>A fancy log-out screen appears and \the [src]'s systems shut down.</span>"
		return //Done

	if(self_option == "Scan Loaded Components")

		var/dat
		var/ratingpool //Used to give an estimation of the machine's quality rating

		dat += "<B>Scanning results for internal component storage :</B><BR><BR>"
		if(componentstorage.len)
			for(var/obj/item/weapon/stock_parts/P in componentstorage)
				dat += "<B>Detected :</B> [P] of effective quality rating [P.rating].<BR>"
				ratingpool += P.rating
			if(ratingpool)
				dat += "<BR>Effective quality rating of machine components : [ratingpool/componentstorage.len].<BR>"
			dat += "Currently loaded with [componentstorage.len] out of [maxcomponents] possible components.<BR>"
		else
			dat += "No components detected. Please check the component container or insert a component for testing.<BR>"
		dat += "<BR><I>Note : You will be returned to the input menu shortly.</I>"

		user.visible_message("<span class='notice'>[user] looks at \the [src]'s HUD as it starts a full data scan on its component container.</span>", \
		"<span class='notice'>You take a closer look at \the [src]'s HUD as it starts data scanning its component container.</span>")
		spawn(20)
			user << browse(dat, "window=componentanal") //Send them the data, in a window
			onclose(usr, "componentanal")

			spawn(30)
				self_interact_menu(user)
	if(self_option == "Unload Components")

		var/self_option_second = alert("Select desired operation", "RMCE V.12 Ready", "Unload Component", "Unload All Components")

		if(self_option_second == "Unload Component")

			if(!componentstorage.len)
				user << "<span class='warning'>An error message flashes on \the [src]'s HUD, indicating that its component storage is empty and that it will return to the input menu shortly.</span>"
				spawn(30)
					self_interact_menu(user)
				return
			var/obj/item/weapon/stock_parts/componentpick = input("Select a component to be unloaded", "Component Unloading", componentstorage[1]) in componentstorage
			componentpick.loc = get_turf(src)
			componentstorage -= componentpick
			user.visible_message("<span class='notice'>[user] waits as \the [src] drops \a [componentpick] from its component container.</span>", \
			"<span class='notice'>You wait as \the [src] drops \a [componentpick] from its component container. A message flashes to indicate it will return to the input menu shortly.</span>")
			spawn(30)
				self_interact_menu(user)

		if(self_option_second == "Unload All Components")

			var/confirmalert = alert("Confirm component storage unloading", "RMCE V.12 Warning", "Confirm", "Abort")
			if(confirmalert == "Confirm")
				if(!componentstorage.len)
					user << "<span class='warning'>An error message flashes on \the [src]'s HUD, indicating that its component storage is empty and that it will return to the input menu shortly.</span>"
					spawn(30)
						self_interact_menu(user)
					return
				user.visible_message("<span class='notice'>[user] waits as \the [src] starts emptying its component container on the ground.</span>", \
				"<span class='notice'>You wait as \the [src] starts emptying its component container. A message flashes to indicate it will return to the input menu shortly after it is finished.</span>")
				for(var/obj/item/weapon/stock_parts/P in componentstorage)
					spawn(5)
					P.loc = get_turf(src)
					componentstorage -= P
				spawn(30)
					self_interact_menu(user)
			if(confirmalert == "Abort") //Tad more complex than a return
				user << "<span class='notice'>A message flashes on \the [src]'s HUD, stating the component storage unloading has been aborted and that it will return to the input menu shortly.</span>"
				spawn(30)
					self_interact_menu(user)
