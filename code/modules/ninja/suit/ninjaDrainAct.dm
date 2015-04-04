
/*

Contents:
- Assorted ninjaDrainAct() procs
- What is Object Oriented Programming

They *could* go in their appropriate files, but this is supposed to be modular

*/


//Needs to return the amount drained from the atom, if no drain, 0
/atom/proc/ninjaDrainAct()
	return 0




//APC//
/obj/machinery/power/apc/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	var/maxcapacity = 0 //Safety check for batteries
	var/drain = 0 //Drain amount from batteries

	. = 0

	if(cell && cell.charge)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(G.candrain && cell.charge> 0 && !maxcapacity)
			drain = rand(G.mindrain, G.maxdrain)

			if(cell.charge < drain)
				drain = cell.charge

			if(S.cell.charge + drain > S.cell.maxcharge)
				drain = S.cell.maxcharge - S.cell.charge
				maxcapacity = 1//Reached maximum battery capacity.

			if (do_after(H,10))
				spark_system.start()
				playsound(loc, "sparks", 50, 1)
				cell.charge -= drain
				S.cell.charge += drain
				. += drain
			else
				break

		if(!emagged)
			flick("apc-spark", G)
			emagged = 1
			locked = 0
			update_icon()





//SMES//
/obj/machinery/power/smes/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	var/maxcapacity = 0 //Safety check for batteries
	var/drain = 0 //Drain amount from batteries

	. = 0

	if(charge)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(G.candrain && charge > 0 && !maxcapacity)
			drain = rand(G.mindrain, G.maxdrain)

			if(charge < drain)
				drain = charge

			if(S.cell.charge + drain > S.cell.maxcharge)
				drain = S.cell.maxcharge - S.cell.charge
				maxcapacity = 1

			if (do_after(H,10))
				spark_system.start()
				playsound(loc, "sparks", 50, 1)
				charge -= drain
				S.cell.charge += drain
				. += drain

			else
				break


//CELL//
/obj/item/weapon/stock_parts/cell/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	. = 0

	if(charge)
		if(G.candrain && do_after(H,30))
			. = charge
			if(S.cell.charge + charge > S.cell.maxcharge)
				S.cell.charge = S.cell.maxcharge
			else
				S.cell.charge += charge
			charge = 0
			corrupt()
			updateicon()


//RDCONSOLE//
/obj/machinery/computer/rdconsole/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	. = DRAIN_RD_HACK_FAILED

	H << "<span class='notice'>Hacking \the [src]...</span>"
	spawn(0)
		var/turf/location = get_turf(H)
		for(var/mob/living/silicon/ai/AI in player_list)
			AI << "<span class='userdanger'>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</span>."

	if(files && files.known_tech.len)
		for(var/datum/tech/current_data in S.stored_research)
			H << "<span class='notice'>Checking \the [current_data.name] database.</span>"
			if(do_after(H, S.s_delay) && G.candrain && src)
				for(var/datum/tech/analyzing_data in files.known_tech)
					if(current_data.id == analyzing_data.id)
						if(analyzing_data.level > current_data.level)
							H << "<span class='notice'>Database:</span> <b>UPDATED</b>."
							current_data.level = analyzing_data.level
							. = DRAIN_RD_HACKED
						break//Move on to next.
			else
				break//Otherwise, quit processing.

	H << "<span class='notice'>Data analyzed. Process finished.</span>"


//RD SERVER//
//Shamelessly copypasted from above, since these two used to be the same proc, but with MANY colon operators
/obj/machinery/r_n_d/server/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	. = DRAIN_RD_HACK_FAILED

	H << "<span class='notice'>Hacking \the [src]...</span>"
	spawn(0)
		var/turf/location = get_turf(H)
		for(var/mob/living/silicon/ai/AI in player_list)
			AI << "<span class='userdanger'>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</span>."

	if(files && files.known_tech.len)
		for(var/datum/tech/current_data in S.stored_research)
			H << "<span class='notice'>Checking \the [current_data.name] database.</span>"
			if(do_after(H, S.s_delay) && G.candrain && src)
				for(var/datum/tech/analyzing_data in files.known_tech)
					if(current_data.id == analyzing_data.id)
						if(analyzing_data.level > current_data.level)
							H << "<span class='notice'>Database:</span> <b>UPDATED</b>."
							current_data.level = analyzing_data.level
							. = DRAIN_RD_HACKED
						break//Move on to next.
			else
				break//Otherwise, quit processing.

	H << "<span class='notice'>Data analyzed. Process finished.</span>"


//WIRE//
/obj/structure/cable/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	var/maxcapacity = 0 //Safety check
	var/drain = 0 //Drain amount

	. = 0

	var/datum/powernet/PN = powernet
	while(G.candrain && !maxcapacity && src)
		drain = (round((rand(G.mindrain, G.maxdrain))/2))
		var/drained = 0
		if(PN && do_after(H,10))
			drained = min(drain, PN.avail)
			PN.load += drained
			if(drained < drain)//if no power on net, drain apcs
				for(var/obj/machinery/power/terminal/T in PN.nodes)
					if(istype(T.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/AP = T.master
						if(AP.operating && AP.cell && AP.cell.charge > 0)
							AP.cell.charge = max(0, AP.cell.charge - 5)
							drained += 5
		else
			break

		S.cell.charge += drained
		if(S.cell.charge > S.cell.maxcharge)
			. += (drained-(S.cell.charge - S.cell.maxcharge))
			S.cell.charge = S.cell.maxcharge
			maxcapacity = 1
		else
			. += drained
		S.spark_system.start()

//MECH//
/obj/mecha/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	var/maxcapacity = 0 //Safety check
	var/drain = 0 //Drain amount
	. = 0

	occupant_message("<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
	if(get_charge())
		while(G.candrain && cell.charge > 0 && !maxcapacity)
			drain = rand(G.mindrain,G.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(S.cell.charge + drain > S.cell.maxcharge)
				drain = S.cell.maxcharge - S.cell.charge
				maxcapacity = 1
			if (do_after(H,10))
				spark_system.start()
				playsound(loc, "sparks", 50, 1)
				cell.use(drain)
				S.cell.charge += drain
				. += drain
			else
				break

//BORG//
/mob/living/silicon/robot/ninjaDrainAct(var/obj/item/clothing/suit/space/space_ninja/S, var/mob/living/carbon/human/H, var/obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return 0

	var/maxcapacity = 0 //Safety check
	var/drain = 0 //Drain amount
	. = 0

	src << "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>"

	if(cell && cell.charge)
		while(G.candrain && cell.charge > 0 && !maxcapacity)
			drain = rand(G.mindrain,G.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(S.cell.charge+drain > S.cell.maxcharge)
				drain = S.cell.maxcharge - S.cell.charge
				maxcapacity = 1
			if (do_after(H,10))
				spark_system.start()
				playsound(loc, "sparks", 50, 1)
				cell.charge -= drain
				S.cell.charge += drain
				. += drain
			else
				break



