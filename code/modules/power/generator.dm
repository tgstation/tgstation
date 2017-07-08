// dummy generator object for testing

/*/obj/machinery/power/generator/verb/set_amount(var/g as num)
	set src in view(1)

	gen_amount = g

*/

/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1
	use_power = NO_POWER_USE

	var/obj/machinery/atmospherics/components/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/components/binary/circulator/hot_circ

	//note: these currently only support EAST and WEST
	var/cold_dir = WEST
	var/hot_dir = EAST

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"


/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	var/obj/machinery/atmospherics/components/binary/circulator/circpath = /obj/machinery/atmospherics/components/binary/circulator
	cold_circ = locate(circpath) in get_step(src, cold_dir)
	hot_circ = locate(circpath) in get_step(src, hot_dir)
	connect_to_network()
	SSair.atmos_machinery += src

	if(cold_circ)
		switch(cold_dir)
			if(EAST)
				cold_circ.side = circpath.CIRC_RIGHT
			if(WEST)
				cold_circ.side = circpath.CIRC_LEFT
		cold_circ.update_icon()

	if(hot_circ)
		switch(hot_dir)
			if(EAST)
				hot_circ.side = circpath.CIRC_RIGHT
			if(WEST)
				hot_circ.side = circpath.CIRC_LEFT
		hot_circ.update_icon()

	if(!cold_circ || !hot_circ)
		stat |= BROKEN

	update_icon()
	
/obj/machinery/power/generator/Destroy()
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/power/generator/update_icon()

	if(stat & (NOPOWER|BROKEN))
		cut_overlays()
	else
		cut_overlays()

		var/L = min(round(lastgenlev/100000),11)
		if(L != 0)
			add_overlay(image('icons/obj/power.dmi', "teg-op[L]"))

		add_overlay("teg-oc[lastcirc]")


#define GENRATE 800		// generator output coefficient from Q

/obj/machinery/power/generator/process_atmos()

	if(!cold_circ || !hot_circ)
		return

	if(powernet)
		//to_chat(world, "cold_circ and hot_circ pass")

		var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
		var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

		//to_chat(world, "hot_air = [hot_air]; cold_air = [cold_air];")

		if(cold_air && hot_air)

			//to_chat(world, "hot_air = [hot_air] temperature = [hot_air.temperature]; cold_air = [cold_air] temperature = [hot_air.temperature];")

			//to_chat(world, "coldair and hotair pass")
			var/cold_air_heat_capacity = cold_air.heat_capacity()
			var/hot_air_heat_capacity = hot_air.heat_capacity()

			var/delta_temperature = hot_air.temperature - cold_air.temperature

			//to_chat(world, "delta_temperature = [delta_temperature]; cold_air_heat_capacity = [cold_air_heat_capacity]; hot_air_heat_capacity = [hot_air_heat_capacity]")

			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				var/efficiency = 0.65

				var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

				var/heat = energy_transfer*(1-efficiency)
				lastgen += energy_transfer*efficiency

				//to_chat(world, "lastgen = [lastgen]; heat = [heat]; delta_temperature = [delta_temperature]; hot_air_heat_capacity = [hot_air_heat_capacity]; cold_air_heat_capacity = [cold_air_heat_capacity];")

				hot_air.temperature = hot_air.temperature - energy_transfer/hot_air_heat_capacity
				cold_air.temperature = cold_air.temperature + heat/cold_air_heat_capacity

				//to_chat(world, "POWER: [lastgen] W generated at [efficiency*100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")

				//add_avail(lastgen) This is done in process now
		// update icon overlays only if displayed level has changed

		if(hot_air)
			var/datum/gas_mixture/hot_circ_air1 = hot_circ.AIR1
			hot_circ_air1.merge(hot_air)

		if(cold_air)
			var/datum/gas_mixture/cold_circ_air1 = cold_circ.AIR1
			cold_circ_air1.merge(cold_air)
			
		update_icon()

	var/circ = "[cold_circ && cold_circ.last_pressure_delta > 0 ? "1" : "0"][hot_circ && hot_circ.last_pressure_delta > 0 ? "1" : "0"]"
	if(circ != lastcirc)
		lastcirc = circ
		update_icon()

	src.updateDialog()
	
/obj/machinery/power/generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	..()

/obj/machinery/power/generator/attack_hand(mob/user)
	if(..())
		user << browse(null, "window=teg")
		return
	interact(user)

/obj/machinery/power/generator/proc/get_menu(include_link = 1)
	var/t = ""
	if(!powernet)
		t += "<span class='bad'>Unable to connect to the power network!</span>"
	else if(cold_circ && hot_circ)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.AIR1
		var/datum/gas_mixture/cold_circ_air2 = cold_circ.AIR2
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.AIR1
		var/datum/gas_mixture/hot_circ_air2 = hot_circ.AIR2

		t += "<div class='statusDisplay'>"
		
		var/displaygen = lastgenlev
		if(displaygen < 1000000) //less than a MW
			displaygen /= 1000
			t += "Output: [round(displaygen,0.01)] kW"
		else
			displaygen /= 1000000
			t += "Output: [round(displaygen,0.01)] MW"
		
		t += "<BR>"

		t += "<B><font color='blue'>Cold loop</font></B><BR>"
		t += "Temperature Inlet: [round(cold_circ_air2.temperature, 0.1)] K / Outlet: [round(cold_circ_air1.temperature, 0.1)] K<BR>"
		t += "Pressure Inlet: [round(cold_circ_air2.return_pressure(), 0.1)] kPa /  Outlet: [round(cold_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "<B><font color='red'>Hot loop</font></B><BR>"
		t += "Temperature Inlet: [round(hot_circ_air2.temperature, 0.1)] K / Outlet: [round(hot_circ_air1.temperature, 0.1)] K<BR>"
		t += "Pressure Inlet: [round(hot_circ_air2.return_pressure(), 0.1)] kPa / Outlet: [round(hot_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "</div>"
	else
		t += "<span class='bad'>Unable to locate all parts!</span>"
	if(include_link)
		t += "<BR><A href='?src=\ref[src];close=1'>Close</A>"

	return t

/obj/machinery/power/generator/interact(mob/user)

	user.set_machine(src)
	var/datum/browser/popup = new(user, "teg", "Thermo-Electric Generator", 460, 300)
	popup.set_content(get_menu())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return 1


/obj/machinery/power/generator/Topic(href, href_list)
	if(..())
		return
	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return 0
	return 1


/obj/machinery/power/generator/power_change()
	..()
	update_icon()
