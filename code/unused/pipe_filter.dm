// *** pipefilter

/obj/machinery/pipefilter/New()
	..()
	p_dir = (NORTH|SOUTH|EAST|WEST) ^ turn(dir, 180)

	src.gas = new /datum/gas_mixture/()
	src.ngas = new /datum/gas_mixture/()

	src.f_gas = new /datum/gas_mixture/()
	src.f_ngas = new /datum/gas_mixture/()

	gasflowlist += src

/obj/machinery/pipefilter/buildnodes()
	var/turf/T = src.loc

	n1dir = turn(dir, 90)
	n2dir = turn(dir,-90)

	node1 = get_machine( level, T , n1dir )	// the main flow dir
	node2 = get_machine( level, T , n2dir )
	node3 = get_machine( level, T, dir )	// the ejector port

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()
	if(node3) vnode3 = node3.getline()

/obj/machinery/pipefilter/gas_flow()
	gas.copy_from(ngas)
	f_gas.copy_from(f_ngas)

/obj/machinery/pipefilter/process()
/*	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - gas.total_moles() / capmult)
		calc_delta( src, gas, ngas, vnode1, delta_gt)
	else
		leak_to_turf(1)
	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - gas.total_moles() / capmult)
		calc_delta( src, gas, ngas, vnode2, delta_gt)
	else
		leak_to_turf(2)
	if(vnode3)
		delta_gt = FLOWFRAC * ( vnode3.get_gas_val(src) - f_gas.total_moles() / capmult)
		calc_delta( src, f_gas, f_ngas, vnode3, delta_gt)
	else
		leak_to_turf(3)

	// transfer gas from ngas->f_ngas according to extraction rate, but only if we have power
	if(! (stat & NOPOWER) )
		use_power(min(src.f_per, 100),ENVIRON)
		var/datum/gas_mixture/ndelta = src.get_extract()
		ngas.sub_delta(ndelta)
		f_ngas.add_delta(ndelta)
	AutoUpdateAI(src)
	src.updateUsrDialog()*/ //TODO: FIX

/obj/machinery/pipefilter/get_gas_val(from)
	return ((from == vnode3) ? f_gas.total_moles() : gas.total_moles())/capmult

/obj/machinery/pipefilter/get_gas(from)
	return (from == vnode3) ? f_gas : gas

/obj/machinery/pipefilter/proc/leak_to_turf(var/port)
	var/turf/T

	switch(port)
		if(1)
			T = get_step(src, n1dir)
		if(2)
			T = get_step(src, n2dir)
		if(3)
			T = get_step(src, dir)
			if(T.density)
				T = src.loc
				if(T.density)
					return
			flow_to_turf(f_gas, f_ngas, T)
			return

	if(T.density)
		T = src.loc
		if(T.density)
			return

	flow_to_turf(gas, ngas, T)

/obj/machinery/pipefilter/proc/get_extract()
	/*
	var/datum/gas_mixture/ndelta = new()
	if (src.f_mask & GAS_O2)
		ndelta.oxygen = min(src.f_per, src.ngas.oxygen)
	if (src.f_mask & GAS_N2)
		ndelta.n2 = min(src.f_per, src.ngas.n2)
	if (src.f_mask & GAS_PL)
		ndelta.plasma = min(src.f_per, src.ngas.plasma)
	if (src.f_mask & GAS_CO2)
		ndelta.co2 = min(src.f_per, src.ngas.co2)
	if (src.f_mask & GAS_N2O)
		ndelta.sl_gas = min(src.f_per, src.ngas.sl_gas)
	return ndelta
	*/ //TODO: FIX

/obj/machinery/pipefilter/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/detective_scanner))
		return ..()
	if(istype(W, /obj/item/weapon/screwdriver))
		if(bypassed)
			user.show_message(text("\red Remove the foreign wires first!"), 1)
			return
		src.add_fingerprint(user)
		user.show_message(text("\red Now []securing the access system panel...", (src.locked) ? "un" : "re"), 1)
		sleep(30)
		locked =! locked
		user.show_message(text("\red Done!"),1)
		src.updateicon()
		return
	if(istype(W, /obj/item/weapon/cable_coil) && !bypassed)
		if(src.locked)
			user.show_message(text("\red You must remove the panel first!"),1)
			return
		var/obj/item/weapon/cable_coil/C = W
		if(C.use(4))
			user.show_message(text("\red You unravel some cable.."),1)
		else
			user.show_message(text("\red Not enough cable! <I>(Requires four pieces)</I>"),1)
		src.add_fingerprint(user)
		user.show_message(text("\red Now bypassing the access system... <I>(This may take a while)</I>"), 1)
		sleep(100)
		bypassed = 1
		src.updateicon()
		return
	if(istype(W, /obj/item/weapon/wirecutters) && bypassed)
		src.add_fingerprint(user)
		user.show_message(text("\red Now removing the bypass wires... <I>(This may take a while)</I>"), 1)
		sleep(50)
		bypassed = 0
		src.updateicon()
		return
	if(istype(W, /obj/item/weapon/card/emag) && (!emagged))
		emagged++
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has shorted out the [] with an electromagnetic card!", user, src), 1)
		src.overlays += image('icons/obj/pipes2.dmi', "filter-spark")
		sleep(6)
		src.updateicon()
		return src.attack_hand(user)
	return src.attack_hand(user)

// pipefilter interact/topic
/obj/machinery/pipefilter/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/pipefilter/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/pipefilter/attack_hand(mob/user as mob)
/*	if(stat & NOPOWER)
		user << browse(null, "window=pipefilter")
		user.machine = null
		return

	var/list/gases = list("O2", "N2", "Plasma", "CO2", "N2O")
	user.machine = src
	var/dat = "Filter Release Rate:<BR>\n<A href='?src=\ref[src];fp=-[num2text(src.maxrate, 9)]'>M</A> <A href='?src=\ref[src];fp=-100000'>-</A> <A href='?src=\ref[src];fp=-10000'>-</A> <A href='?src=\ref[src];fp=-1000'>-</A> <A href='?src=\ref[src];fp=-100'>-</A> <A href='?src=\ref[src];fp=-1'>-</A> [src.f_per] <A href='?src=\ref[src];fp=1'>+</A> <A href='?src=\ref[src];fp=100'>+</A> <A href='?src=\ref[src];fp=1000'>+</A> <A href='?src=\ref[src];fp=10000'>+</A> <A href='?src=\ref[src];fp=100000'>+</A> <A href='?src=\ref[src];fp=[num2text(src.maxrate, 9)]'>M</A><BR>\n"
	for (var/i = 1; i <= gases.len; i++)
		dat += "[gases[i]]: <A HREF='?src=\ref[src];tg=[1 << (i - 1)]'>[(src.f_mask & 1 << (i - 1)) ? "Releasing" : "Passing"]</A><BR>\n"
	if(gas.total_moles())
		var/totalgas = gas.total_moles()
		var/pressure = round(totalgas / gas.maximum * 100)
		var/nitrogen = gas.n2 / totalgas * 100
		var/oxygen = gas.oxygen / totalgas * 100
		var/plasma = gas.plasma / totalgas * 100
		var/co2 = gas.co2 / totalgas * 100
		var/no2 = gas.sl_gas / totalgas * 100

		dat += "<BR>Gas Levels: <BR>\nPressure: [pressure]%<BR>\nNitrogen: [nitrogen]%<BR>\nOxygen: [oxygen]%<BR>\nPlasma: [plasma]%<BR>\nCO2: [co2]%<BR>\nN2O: [no2]%<BR>\n"
	else
		dat += "<BR>Gas Levels: <BR>\nPressure: 0%<BR>\nNitrogen: 0%<BR>\nOxygen: 0%<BR>\nPlasma: 0%<BR>\nCO2: 0%<BR>\nN2O: 0%<BR>\n"
	dat += "<BR>\n<A href='?src=\ref[src];close=1'>Close</A><BR>\n"

	user << browse(dat, "window=pipefilter;size=300x365")*/ //TODO: FIX
	//onclose(user, "pipefilter")

/obj/machinery/pipefilter/Topic(href, href_list)
	..()
	if(usr.restrained() || usr.lying)
		return
	if ((((get_dist(src, usr) <= 1 || usr.telekinesis == 1) || istype(usr, /mob/living/silicon/ai)) && istype(src.loc, /turf)))
		usr.machine = src
		if (href_list["close"])
			usr << browse(null, "window=pipefilter;")
			usr.machine = null
			return
		if (src.allowed(usr) || src.emagged || src.bypassed)
			if (href_list["fp"])
				src.f_per = min(max(round(src.f_per + text2num(href_list["fp"])), 0), src.maxrate)
			else if (href_list["tg"])
				// toggle gas
				src.f_mask ^= text2num(href_list["tg"])
				src.updateicon()
		else
			usr.see("\red Access Denied ([src.name] operation restricted to authorized atmospheric technicians.)")
		AutoUpdateAI(src)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=pipefilter")
		usr.machine = null
		return

/obj/machinery/pipefilter/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(1,15))	//so all the filters don't come on at once
		updateicon()

/obj/machinery/pipefilter/proc/updateicon()
	src.overlays.Cut()
	if(stat & NOPOWER)
		icon_state = "filter-off"
	else
		icon_state = "filter"
		if(emagged)	//only show if powered because presumeably its the interface that has been fried
			src.overlays += image('icons/obj/pipes2.dmi', "filter-emag")
		if (src.f_mask & (GAS_N2O|GAS_PL))
			src.overlays += image('icons/obj/pipes2.dmi', "filter-tox")
		if (src.f_mask & GAS_O2)
			src.overlays += image('icons/obj/pipes2.dmi', "filter-o2")
		if (src.f_mask & GAS_N2)
			src.overlays += image('icons/obj/pipes2.dmi', "filter-n2")
		if (src.f_mask & GAS_CO2)
			src.overlays += image('icons/obj/pipes2.dmi', "filter-co2")
	if(!locked)
		src.overlays += image('icons/obj/pipes2.dmi', "filter-open")
		if(bypassed)	//should only be bypassed if unlocked
			src.overlays += image('icons/obj/pipes2.dmi', "filter-bypass")