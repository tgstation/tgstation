


/*
	Dear ninja gloves

	This isn't because I like you
	this is because your father is a bastard

	...
	I guess you're a little cool.
	 -Sayu
*/

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 120
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

/*
	This runs the gamut of what ninja gloves can do
	The other option would be a dedicated ninja touch bullshit proc on everything
	which would probably more efficient, but ninjas are pretty rare.
	This was mostly introduced to keep ninja code from contaminating other code;
	with this in place it would be easier to untangle the rest of it.

	For the drain proc, see events/ninja.dm
*/
/obj/item/clothing/gloves/space_ninja/Touch(var/atom/A,var/proximity)
	if(!candrain || draining)
		return 0
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return 0 // what
	var/obj/item/clothing/suit/space/space_ninja/suit = H.wear_suit
	if(!istype(suit))
		return 0
	if(isturf(A))
		return 0

	if(!proximity) // todo: you could add ninja stars or computer hacking here
		return 0

	A.add_fingerprint(H)

	// steal energy from powered things
	if(istype(A,/mob/living/silicon/robot))
		drain("CYBORG",A,suit)
		return 1

	if(istype(A, /obj/item/weapon/stock_parts/cell))
		drain("CELL", A,suit)
		return 1

	if(istype(A,/obj/machinery/power/apc))
		drain("APC",A,suit)
		return 1

	if(istype(A,/obj/structure/cable))
		drain("WIRE",A,suit)
		return 1

	if(istype(A,/obj/structure/grille))
		var/obj/structure/cable/C = locate() in A.loc
		if(C)
			drain("WIRE",C,suit)
		return 1

	if(istype(A,/obj/machinery/power/smes))
		drain("SMES",A,suit)
		return 1

	if(istype(A,/obj/mecha))
		drain("MECHA",A,suit)
		return 1

	if(istype(A,/obj/machinery/computer/rdconsole)) // download research
		drain("RESEARCH",A,suit)
		return 1

	if(istype(A,/obj/machinery/r_n_d/server))
		A.add_fingerprint(H)
		var/obj/machinery/r_n_d/server/S = A
		if(S.disabled)
			return 1
		if(S.shocked)
			S.shock(H,50)
			return 1
		drain("RESEARCH",A,suit)
		return 1


/obj/item/clothing/gloves/space_ninja/proc/drain(target_type as text, target, obj/suit)
	//Var Initialize
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/mob/living/carbon/human/U = S.affecting
	var/obj/item/clothing/gloves/space_ninja/G = S.n_gloves

	var/drain = 0//To drain from battery.
	var/maxcapacity = 0//Safety check for full battery.
	var/totaldrain = 0//Total energy drained.

	G.draining = 1

	if(target_type!="RESEARCH")//I lumped research downloading here for ease of use.
		U << "<span class='notice'>Now charging battery...</span>"

	switch(target_type)

		if("APC")
			var/obj/machinery/power/apc/A = target
			if(A.cell&&A.cell.charge)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1//Reached maximum battery capacity.
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from the APC.</span>"
				if(!A.emagged)
					flick("apc-spark", src)
					A.emagged = 1
					A.locked = 0
					A.update_icon()
			else
				U << "<span class='danger'>This APC has run dry of power. You must find another source.</span>"

		if("SMES")
			var/obj/machinery/power/smes/A = target
			if(A.charge)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.charge<drain)
						drain = A.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from the SMES cell.</span>"
			else
				U << "<span class='danger'>This SMES cell has run dry of power. You must find another source.</span>"

		if("CELL")
			var/obj/item/weapon/stock_parts/cell/A = target
			if(A.charge)
				if (G.candrain&&do_after(U,30))
					U << "<span class='notice'>Gained <B>[A.charge]</B> energy from the cell.</span>"
					if(S.cell.charge+A.charge>S.cell.maxcharge)
						S.cell.charge=S.cell.maxcharge
					else
						S.cell.charge+=A.charge
					A.charge = 0
					G.draining = 0
					A.corrupt()
					A.updateicon()
				else
					U << "<span class='danger'>Procedure interrupted. Protocol terminated.</span>"
			else
				U << "<span class='danger'>This cell is empty and of no use.</span>"

		if("MACHINERY")//Can be applied to generically to all powered machinery. I'm leaving this alone for now.
			var/obj/machinery/A = target
			if(A.powered())//If powered.

				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)

				var/area/A_Area = get_area(A)
				var/obj/machinery/power/apc/B = A_Area.get_apc() //find APC
				if(B)//If APC exists. Might not if the area is unpowered like Centcom.
					var/datum/powernet/PN = B.terminal.powernet
					while(G.candrain&&!maxcapacity&&!isnull(A))//And start a proc similar to drain from wire.
						drain = rand(G.mindrain,G.maxdrain)
						var/drained = 0
						if(PN&&do_after(U,10))
							drained = min(drain, PN.avail)
							PN.load += drained
							if(drained < drain)//if no power on net, drain apcs
								for(var/obj/machinery/power/terminal/T in PN.nodes)
									if(istype(T.master, /obj/machinery/power/apc))
										var/obj/machinery/power/apc/AP = T.master
										if(AP.operating && AP.cell && AP.cell.charge>0)
											AP.cell.charge = max(0, AP.cell.charge - 5)
											drained += 5
						else	break
						S.cell.charge += drained
						if(S.cell.charge>S.cell.maxcharge)
							totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
							S.cell.charge = S.cell.maxcharge
							maxcapacity = 1
						else
							totaldrain += drained
						spark_system.start()
						if(drained==0)	break
					U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from the power network.</span>"
				else
					U << "<span class='danger'>Power network could not be found. Aborting.</span>"
			else
				U << "<span class='danger'>This recharger is not providing energy. You must find another source.</span>"

		if("RESEARCH")
			var/obj/machinery/A = target
			U << "<span class='notice'>Hacking \the [A]...</span>"
			spawn(0)
				var/turf/location = get_turf(U)
				for(var/mob/living/silicon/ai/AI in player_list)
					AI << "<span class='userdanger'>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</span>."
			if(A:files&&A:files.known_tech.len)
				for(var/datum/tech/current_data in S.stored_research)
					U << "<span class='notice'>Checking \the [current_data.name] database.</span>"
					if(do_after(U, S.s_delay)&&G.candrain&&!isnull(A))
						for(var/datum/tech/analyzing_data in A:files.known_tech)
							if(current_data.id==analyzing_data.id)
								if(analyzing_data.level>current_data.level)
									U << "<span class='notice'>Database:</span> <b>UPDATED</b>."
									current_data.level = analyzing_data.level
								break//Move on to next.
					else	break//Otherwise, quit processing.
			U << "<span class='notice'>Data analyzed. Process finished.</span>"

		if("WIRE")
			var/obj/structure/cable/A = target
			var/datum/powernet/PN = A.powernet
			while(G.candrain&&!maxcapacity&&!isnull(A))
				drain = (round((rand(G.mindrain,G.maxdrain))/2))
				var/drained = 0
				if(PN&&do_after(U,10))
					drained = min(drain, PN.avail)
					PN.load += drained
					if(drained < drain)//if no power on net, drain apcs
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/AP = T.master
								if(AP.operating && AP.cell && AP.cell.charge>0)
									AP.cell.charge = max(0, AP.cell.charge - 5)
									drained += 5
				else	break
				S.cell.charge += drained
				if(S.cell.charge>S.cell.maxcharge)
					totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
					S.cell.charge = S.cell.maxcharge
					maxcapacity = 1
				else
					totaldrain += drained
				S.spark_system.start()
				if(drained==0)	break
			U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from the power network.</span>"

		if("MECHA")
			var/obj/mecha/A = target
			A.occupant_message("<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
			if(A.get_charge())
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.use(drain)
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from [src].</span>"
			else
				U << "<span class='danger'>The exosuit's battery has run dry. You must find another source of power.</span>"

		if("CYBORG")
			var/mob/living/silicon/robot/A = target
			A << "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>"
			G.draining = 1
			if(A.cell&&A.cell.charge)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from [A].</span>"
			else
				U << "<span class='danger'>Their battery has run dry of power. You must find another source.</span>"

		else//Else nothing :<

	G.draining = 0

	return


/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	U << "You <b>[candrain?"disable":"enable"]</b> special interaction."
	candrain=!candrain


/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	..()
	if(flags & NODROP)
		user << "The energy drain mechanism is: <B>[candrain?"active":"inactive"]</B>."
