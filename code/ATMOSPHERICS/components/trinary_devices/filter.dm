#define FILTER_NOTHING			-1
#define FILTER_PLASMA			0
#define FILTER_OXYGEN			1
#define FILTER_NITROGEN			2
#define FILTER_CARBONDIOXIDE	3
#define FILTER_NITROUSOXIDE		4

/obj/machinery/atmospherics/trinary/filter
	icon_state = "filter_off"
	density = 0

	name = "gas filter"

	req_access = list(access_atmospherics)

	can_unwrench = 1

	var/on = 0
	var/temp = null

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
-1: Nothing
 0: Plasma: Plasma Toxin, Oxygen Agent B
 1: Oxygen: Oxygen ONLY
 2: Nitrogen: Nitrogen ONLY
 3: Carbon Dioxide: Carbon Dioxide ONLY
 4: Sleeping Agent (N2O)
*/

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/filter/flipped
	icon_state = "filter_off_f"
	flipped = 1

/obj/machinery/atmospherics/trinary/filter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/obj/machinery/atmospherics/trinary/filter/icon_addintact(var/obj/machinery/atmospherics/node, var/connected)
	var/image/img = getpipeimage('icons/obj/atmospherics/trinary_devices.dmi', "cap", get_dir(src,node), node.pipe_color)
	overlays += img
	return ..()

/obj/machinery/atmospherics/trinary/filter/icon_addbroken(var/connected)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_exposed", direction)
			overlays += getpipeimage('icons/obj/atmospherics/trinary_devices.dmi', "cap", direction)

/obj/machinery/atmospherics/trinary/filter/update_icon()
	overlays.Cut()
	..()

/obj/machinery/atmospherics/trinary/filter/update_icon_nopipes()

	if(!(stat & NOPOWER) && on && nodes[1] && nodes[2] && nodes[3])
		icon_state = "filter_on[flipped?"_f":""]"
		return

	icon_state = "filter_off[flipped?"_f":""]"

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(stat & NOPOWER)
		on = 0
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	var/datum/gas_mixture/air3 = airs[3]

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
			if(FILTER_PLASMA)
				filtered_out.toxins = removed.toxins
				removed.toxins = 0

				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			if(FILTER_OXYGEN)
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0

			if(FILTER_NITROGEN)
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0

			if(FILTER_CARBONDIOXIDE)
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0

			if(FILTER_NITROUSOXIDE)
				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/sleeping_agent))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			else
				filtered_out = null


		air2.merge(filtered_out)
		air3.merge(removed)

	update_airs(air1, air2, air3)
	update_parents()

	return 1

/obj/machinery/atmospherics/trinary/filter/atmosinit()
	set_frequency(frequency)
	return ..()

/obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob)
	if(..())
		return

	if(!src.allowed(user))
		user << "<span class='danger'>Access denied.</span>"
		return

	ui_interact(user)

/obj/machinery/atmospherics/trinary/filter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return

	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "atmos_filter.tmpl", name, 400, 320, 0)

/obj/machinery/atmospherics/trinary/filter/get_ui_data()
	var/data = list()
	data["on"] = on
	data["pressure_set"] = round(target_pressure*100) //Nano UI can't handle rounded non-integers, apparently.
	data["max_pressure"] = MAX_OUTPUT_PRESSURE
	data["filter_type"] = filter_type
	return data

/obj/machinery/atmospherics/trinary/filter/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		src.filter_type = text2num(href_list["filterset"])
		var/filtering_name = "nothing"
		switch(filter_type)
			if(FILTER_PLASMA)
				filtering_name = "plasma"
			if(FILTER_OXYGEN)
				filtering_name = "oxygen"
			if(FILTER_NITROGEN)
				filtering_name = "nitrogen"
			if(FILTER_CARBONDIOXIDE)
				filtering_name = "carbon dioxide"
			if(FILTER_NITROUSOXIDE)
				filtering_name = "nitrous oxide"
		investigate_log("was set to filter [filtering_name] by [key_name(usr)]", "atmos")
	if (href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		switch(href_list["set_press"])
			if ("max")
				target_pressure = MAX_OUTPUT_PRESSURE
			if ("set")
				target_pressure = max(0, min(MAX_OUTPUT_PRESSURE, safe_input("Pressure control", "Enter new output pressure (0-[MAX_OUTPUT_PRESSURE] kPa)", target_pressure)))
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")
	if(href_list["power"])
		on=!on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return
