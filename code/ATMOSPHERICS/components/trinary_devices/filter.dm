obj/machinery/atmospherics/trinary/filter
	icon = 'filter.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Gas filter"

	req_access = list(ACCESS_ATMOSPHERICS)

	var/locked = 1 // If it's not locked, no need for an access check.

	var/on = 0
	var/temp = null // -- TLE

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
-1: Nothing
 0: Carbon Molecules: Plasma Toxin, Oxygen Agent B
 1: Oxygen: Oxygen ONLY
 2: Nitrogen: Nitrogen ONLY
 3: Carbon Dioxide: Carbon Dioxide ONLY
 4: Sleeping Agent (N2O)
*/

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

	New()
		if(radio_controller)
			initialize()
		..()

	update_icon()
		if(node2 && node3 && node1)
			icon_state = "intact_[on?("on"):("off")]"
		else
			icon_state = "hintact_off"
			on = 0

		return

	New()
		..()

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = air3.return_pressure()

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles

		if(air1.temperature > 0)
			transfer_moles = pressure_delta*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas

		if(transfer_moles > 0)
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)

			if(!removed)
				return
			var/datum/gas_mixture/filtered_out = new
			filtered_out.temperature = removed.temperature

			switch(filter_type)
				if(0) //removing hydrocarbons
					filtered_out.toxins = removed.toxins
					removed.toxins = 0

				if(1) //removing O2
					filtered_out.oxygen = removed.oxygen
					removed.oxygen = 0

				if(2) //removing N2
					filtered_out.nitrogen = removed.nitrogen
					removed.nitrogen = 0

				if(3) //removing CO2
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0

				if(4)//removing N2O
					if(removed.trace_gases.len>0)
						for(var/datum/gas/trace_gas in removed.trace_gases)
							if(istype(trace_gas, /datum/gas/sleeping_agent))
								removed.trace_gases -= trace_gas
								filtered_out.trace_gases += trace_gas

				else
					filtered_out = null

			if(filtered_out)
				filtered_out.update_values()
			air2.merge(filtered_out)
			air3.merge(removed)

		if(network2)
			network2.update = 1

		if(network3)
			network3.update = 1

		if(network1)
			network1.update = 1

		return 1

	initialize()
		set_frequency(frequency)
		..()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)


obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(src.locked && !src.allowed(user))
		user << "\red Access denied."
		return

	var/dat
	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Carbon Molecules (e.g. Plasma)"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_type]<br><HR>
			<h4>Set Filter Type:</h4>
			<A href='?src=\ref[src];filterset=0'>Carbon Molecules (e.g Plasma)</A><BR>
			<A href='?src=\ref[src];filterset=1'>Oxygen</A><BR>
			<A href='?src=\ref[src];filterset=2'>Nitrogen</A><BR>
			<A href='?src=\ref[src];filterset=3'>Carbon Dioxide</A><BR>
			<A href='?src=\ref[src];filterset=4'>Nitrous Oxide</A><BR>
			<A href='?src=\ref[src];filterset=-1'>Nothing</A><BR>
			<HR><B>Desirable output pressure:</B>
			[src.target_pressure] | <a href='?src=\ref[src];set_press=1'>Change</a>
			"}
/*
		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return

	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
*/
	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")
	return

obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		src.filter_type = text2num(href_list["filterset"])
	if (href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["power"])
		on=!on
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return
