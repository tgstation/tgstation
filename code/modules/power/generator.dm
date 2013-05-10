
//updated by cael_aislinn on 5/3/2013 to be rotateable, moveable and generally more flexible
/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	density = 1
	anchored = 0

	use_power = 1
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator/New()
	..()

	spawn(1)
		reconnect()

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

/obj/machinery/power/generator/proc/updateicon()
	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
	else
		overlays.Cut()

		if(lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")



/obj/machinery/power/generator/process()

	//world << "Generator process ran"

	if(!circ1 || !circ2 || !anchored || stat & (BROKEN|NOPOWER))
		return

	//world << "circ1 and circ2 pass"

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()

	lastgen = 0

	//world << "hot_air = [hot_air]; cold_air = [cold_air];"

	if(air1 && air2)

		//world << "hot_air = [hot_air] temperature = [air2.temperature]; cold_air = [cold_air] temperature = [air2.temperature];"

		//world << "coldair and hotair pass"
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		//world << "delta_temperature = [delta_temperature]; air1_heat_capacity = [air1_heat_capacity]; air2_heat_capacity = [air2_heat_capacity]"

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/efficiency = 0.65
			var/energy_transfer = delta_temperature*air2_heat_capacity*air1_heat_capacity/(air2_heat_capacity+air1_heat_capacity)
			var/heat = energy_transfer*(1-efficiency)

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

	lastgen = circ1.ReturnPowerGeneration() + circ2.ReturnPowerGeneration()
	if(lastgen > 0)
		add_avail(lastgen)

	else
		add_load(-lastgen)

	// update icon overlays and power usage only if displayed level has changed
	var/genlev = max(0, min( round(11*lastgen / 100000), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	updateDialog()

/obj/machinery/power/generator/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)

/obj/machinery/power/generator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "\blue You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor."
		use_power = anchored
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
		t += "Output : [round(lastgen)] W<BR><BR>"

		t += "<B>Primary Circulator (top/right)</B><BR>"
		t += "Inlet Pressure: [round(circ1.air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ1.air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ1.air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ1.air2.temperature, 0.1)] K<BR>"
		t += "Turbine Status: <A href='?src=\ref[src];turbine1=1'>[circ1.turbine_pumping ? "Pumping" : "Generating"]</a><br><br>"

		t += "<B>Secondary Circulator (bottom/left)</B><BR>"
		t += "Inlet Pressure: [round(circ2.air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ2.air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ2.air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ2.air2.temperature, 0.1)] K<BR>"
		t += "Turbine Status: <A href='?src=\ref[src];turbine2=1'>[circ2.turbine_pumping ? "Pumping" : "Generating"]</a><br>"

	else
		t += "Unable to connect to circulators.<br>"
		t += "Ensure both are in position and wrenched into place."

	t += "<BR>"
	t += "<HR>"
	t += "<A href='?src=\ref[src]'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A>"

	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1


/obj/machinery/power/generator/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return 0

	if( href_list["turbine2"] )
		if(circ2)
			circ2.turbine_pumping = !circ2.turbine_pumping

	if( href_list["turbine1"] )
		if(circ1)
			circ1.turbine_pumping = !circ1.turbine_pumping

	updateDialog()
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