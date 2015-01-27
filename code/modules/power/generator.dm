
/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	density = 1
	anchored = 0

	use_power = 0
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator/New()
	..()

	spawn(1)
		reconnect()

/obj/item/weapon/paper/generator
	name = "paper - 'generator instructions'"
	info = "<h2>How to setup the Thermo-Generator</h2><ol> <li>To the top right is a room full of canisters; to the bottom there is a room full of pipes. Connect C02 canisters to the pipe room's top connector ports, the cansisters will help act as a buffer so only remove them when refilling the gas..</li> <li>Connect 3 plasma and 2 oxygen canisters to the bottom ports of the pipe room.</li> <li>Turn on all the pumps and valves in the room except for the one connected to the yellow pipe and red pipe, no adjustments to the pump strength needed.</li> <li>Look into the camera monitor to see the burn chamber. When it is full of plasma, press the igniter button.</li> <li>Setup the SMES cells in the North West of Engineering and set an input of half the max; and an output that is half the input.</li></ol>Well done, you should have a functioning generator generating power. If the generator stops working, and there is enough gas and it's hot and cold, it might mean there is too much pressure and you need to turn on the pump that is connected to the red and yellow pipes to release the pressure. Make sure you don't take out too much pressure though.<br>You optimize the generator you must work out how much power your station is using and lowering the circulation pumps enough so that the generator doesn't create excess power, and it will allow the generator to powering the station for a longer duration, without having to replace the canisters. "


//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator/proc/reconnect()
	circ1 = null
	circ2 = null
	if(src.loc && anchored)
		if(src.dir & (EAST|WEST))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)

			if(circ1 && circ2)
				if(circ1.dir != SOUTH || circ2.dir != NORTH)
					circ1 = null
					circ2 = null

		else if(src.dir & (NORTH|SOUTH))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,NORTH)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,SOUTH)

			if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
				circ1 = null
				circ2 = null

/obj/machinery/power/generator/proc/operable()
	return circ1 && circ2 && anchored && !(stat & (BROKEN|NOPOWER))

/obj/machinery/power/generator/proc/updateicon()
	overlays = 0

	if(!operable())
		return

	if(lastgenlev != 0)
		overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

/obj/machinery/power/generator/process()
	if(!operable())
		return

	updateDialog()

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()
	lastgen = 0

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/efficiency = 0.65
			var/energy_transfer = delta_temperature*air2_heat_capacity*air1_heat_capacity/(air2_heat_capacity+air1_heat_capacity)
			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer*efficiency*0.05

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

			//Transfer the air
			circ1.air2.merge(air1)
			circ2.air2.merge(air2)

			//Update the gas networks
			if(circ1.network2)
				circ1.network2.update = 1
			if(circ2.network2)
				circ2.network2.update = 1

	// update icon overlays and power usage only if displayed level has changed
	if(lastgen > 250000 && prob(10))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		lastgen *= 0.5
	var/genlev = max(0, min( round(11*lastgen / 250000), 11))
	if(lastgen > 100 && genlev == 0)
		genlev = 1
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()
	add_avail(lastgen)

/obj/machinery/power/generator/attack_ai(mob/user)
	src.add_hiddenprint(user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)

/obj/machinery/power/generator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "\blue You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor."
		//use_power = anchored
		reconnect()
	else
		..()

/obj/machinery/power/generator/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER) || !anchored) return
	interact(user)


/obj/machinery/power/generator/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.unset_machine()
		user << browse(null, "window=teg")
		return

	user.set_machine(src)

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	if(circ1 && circ2)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\generator.dm:142: t += "Output : [round(lastgen)] W<BR><BR>"
		t += {"Output : [round(lastgen)] W<BR>
<B>Primary Circulator (top or right)</B>
Inlet Pressure: [round(circ1.air1.return_pressure(), 0.1)] kPa
Inlet Temperature: [round(circ1.air1.temperature, 0.1)] K
Outlet Pressure: [round(circ1.air2.return_pressure(), 0.1)] kPa
Outlet Temperature: [round(circ1.air2.temperature, 0.1)] K<BR>
<B>Secondary Circulator (bottom or left)</B><BR>
Inlet Pressure: [round(circ2.air1.return_pressure(), 0.1)] kPa
Inlet Temperature: [round(circ2.air1.temperature, 0.1)] K
Outlet Pressure: [round(circ2.air2.return_pressure(), 0.1)] kPa
Outlet Temperature: [round(circ2.air2.temperature, 0.1)] K<BR>"}
		// END AUTOFIX
	else

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\generator.dm:157: t += "Unable to connect to circulators.<br>"
		t += {"Unable to connect to circulators.<br>Ensure both are in position and wrenched into place."}
		// END AUTOFIX


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\generator.dm:160: t += "<BR>"
	t += {"<BR>
<HR>
<A href='?src=\ref[src]'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A>"}
	// END AUTOFIX
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1


/obj/machinery/power/generator/Topic(href, href_list)
	..()
	if("close" in href_list)
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return 0
	if("reconnect" in href_list)
		reconnect()
	updateUsrDialog()
	return 1


/obj/machinery/power/generator/power_change()
	..()
	updateicon()


/obj/machinery/power/generator/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, -90)