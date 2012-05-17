
// the inlet stage of the gas turbine electricity generator
/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = "turbine_gens"

	New()
		..()
		gas_contained = new
		inturf = get_step(src, dir)
		spawn(5)
			turbine = locate() in get_step(src, get_dir(inturf, src))
			if(!turbine)
				stat |= BROKEN

	Topic(href, href_list)
		if(..())
			return

		if( href_list["view"] )
			usr.client.eye = src

		src.add_fingerprint(usr)
		src.updateUsrDialog()

#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800

	process()
		if(!starter)
			return
		overlays = null
		if(stat & BROKEN)
			return
		if(!turbine)
			stat |= BROKEN
			return
		rpm = 0.9* rpm + 0.1 * rpmtarget
		var/datum/gas_mixture/environment = inturf.return_air()
		var/transfer_moles = environment.total_moles/10
		//var/transfer_moles = rpm/10000*capacity
		var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
		gas_contained.merge(removed)
		rpm = max(0, rpm - (rpm*rpm)/COMPFRICTION)
		if(starter && !(stat & NOPOWER))
			use_power(2800)
			if(rpm<1000)
				rpmtarget = 1000
		else
			if(rpm<1000)
				rpmtarget = 0
		if(rpm>50000)
			overlays += image('pipes.dmi', "comp-o4", FLY_LAYER)
		else if(rpm>10000)
			overlays += image('pipes.dmi', "comp-o3", FLY_LAYER)
		else if(rpm>2000)
			overlays += image('pipes.dmi', "comp-o2", FLY_LAYER)
		else if(rpm>500)
			overlays += image('pipes.dmi', "comp-o1", FLY_LAYER)
		 //TODO: DEFERRED

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	directwired = 1
	var/turf/simulated/outturf
	var/lastgen

	New()
		..()
		outturf = get_step(src, dir)
		spawn(5)
			compressor = locate() in get_step(src, get_dir(outturf, src))
			if(!compressor)
				stat |= BROKEN


#define TURBPRES 9000000
#define TURBGENQ 20000
#define TURBGENG 0.8

	process()
		overlays = null
		if(stat & BROKEN)
			return
		if(!compressor)
			stat |= BROKEN
			return
		if(!compressor.starter)
			return
		lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) *TURBGENQ

		add_avail(lastgen)
		var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles)/4
		newrpm = max(0, newrpm)

		if(!compressor.starter || newrpm > 1000)
			compressor.rpmtarget = newrpm

		if(compressor.gas_contained.total_moles>0)
			var/oamount = min(compressor.gas_contained.total_moles, (compressor.rpm+100)/35000*compressor.capacity)
			var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
			outturf.assume_air(removed)

		if(lastgen > 100)
			overlays += image('pipes.dmi', "turb-o", FLY_LAYER)

		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.interact(M)
		AutoUpdateAI(src)

	attack_ai(mob/user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	proc/interact(mob/user)
		if ( (get_dist(src, user) > 1 ) || (stat & (NOPOWER|BROKEN)) && (!istype(user, /mob/living/silicon/ai)) )
			user.machine = null
			user << browse(null, "window=turbine")
			return
		user.machine = src

		var/t = "<TT><B>Gas Turbine Generator</B><HR>"
		t += "Generated power : [round(lastgen)] W<BR>"
		t += "Turbine: [round(compressor.rpm)] RPM<BR>"
		t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"
		t += "<HR>"
		t += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A>"

		user << browse(t, "window=turbine")
		onclose(user, "turbine")
		return

	Topic(href, href_list)
		..()
		if(stat & BROKEN)
			return
		if (usr.stat || usr.restrained() )
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			if(!istype(usr, /mob/living/silicon/ai))
				usr << "\red You don't have the dexterity to do this!"
				return
		if (( usr.machine==src && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			if( href_list["close"] )
				usr << browse(null, "window=turbine")
				usr.machine = null
				return
			else if( href_list["str"] )
				compressor.starter = !compressor.starter
			spawn(0)
				for(var/mob/M in viewers(1, src))
					if ((M.client && M.machine == src))
						src.interact(M)
		else
			usr << browse(null, "window=turbine")
			usr.machine = null
		return

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine"
	icon = 'computer.dmi'
	icon_state = "airtunnel0e"
	anchored = 1
	density = 1
	var/list/obj/machinery/compressor/compressors
	var/list/obj/machinery/door/poddoor/doors
	var/vent_network = "turbine_gens"

	New()
		..()
		compressors = new/list()
		spawn(5)
			for(var/obj/machinery/compressor/C in world)
				if(src.vent_network == C.comp_id)
					compressors.Add(C)
			for(var/obj/machinery/door/poddoor/D in world)
				if(src.vent_network == D.networkTag)
					doors.Add(D)

/*
/obj/machinery/computer/turbine_computer/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/turbine_control/M = new /obj/item/weapon/circuitboard/turbine_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/turbine_control/M = new /obj/item/weapon/circuitboard/turbine_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return
*/

	attack_hand(var/mob/user as mob)
		interact()
		return

	proc/interact()
		if ( (get_dist(src, usr) > 1 ) || (stat & (NOPOWER|BROKEN)) && (!istype(usr, /mob/living/silicon/ai)) )
			usr.machine = null
			usr << browse(null, "window=turbinecomp")
			return
		usr.machine = src

		var/dat = "<TT><B>Gas turbine remote control system</B><HR>"

		if(src.doors.len)
			var/closed = 0
			for(var/obj/machinery/door/poddoor/D in src.doors)
				if(D.density)
					closed = 1
			dat += "Connected vent status: <font color=blue>[closed ? "<b>Closed</b> <a href='?src=\ref[src];opendoors=1'>\[Open\]</a>" : "<b>Open</b> <a href='?src=\ref[src];closedoors=1'>\[Close\]</a>"]</font>"
		else
			dat += "<font color=red><b>No vents connected.</b></font>"

		if(src.compressors.len)
			for(var/obj/machinery/compressor/C in compressors)
				dat += "Turbine status: [C.starter ? "<A href='?src=\ref[C];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[C];str=1'>On</A>"]<BR>"
				dat += "Turbine speed: [C.rpm]rpm<BR>"
				dat += "Power currently being generated: [C.turbine.lastgen]W<BR>"
				dat += "Internal gas temperature: [C.gas_contained.temperature]K<BR>"
				dat += "<A href='?src=\ref[src];view=1'>View</A><BR>"
				dat += "<HR>"
		else
			dat += "\red<B>No compatible attached compressors found."
		dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A><BR>"

		usr << browse(dat, "window=turbinecomp;size=400x500")
		onclose(usr, "turbinecomp")

	Topic(href, href_list)
		if(..())
			return

		if (href_list["opendoors"])
			for(var/obj/machinery/door/poddoor/D in src.doors)
				spawn(0)
					D.open()
		if (href_list["closedoors"])
			for(var/obj/machinery/door/poddoor/D in src.doors)
				spawn(0)
					D.close()
		else if( href_list["close"] )
			usr << browse(null, "window=turbinecomp")
			usr.machine = null
			return

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return

	process()
		src.updateDialog()
		return