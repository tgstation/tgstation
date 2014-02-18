/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below flow out through these vents."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"

	m_amt=10*CC_PER_SHEET_METAL
	w_type = RECYK_METAL

	var/datum/gas_mixture/air_contents

	var/on=1

	var/max_external_pressure=10000 // 10,000kPa ought to do it.
	var/internal_pressure=4500 // Bottleneck

	var/light_color = "#FFFFFF"

/obj/machinery/atmospherics/miner/New()
	..()
	air_contents = new
	air_contents.volume=1000
	AddAir()
	air_contents.update_values()
	update_icon()

// Add air here.  DO NOT CALL UPDATE_VALUES OR UPDATE_ICON.
/obj/machinery/atmospherics/miner/proc/AddAir()
	return

/obj/machinery/atmospherics/miner/update_icon()
	src.overlays = 0
	if(stat & (BROKEN|NOPOWER))
		return
	overlays += image(on?"on":"off",color=light_color)

/obj/machinery/atmospherics/miner/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if (!on)
		return

	if(!istype(loc,/turf/simulated))
		on = 0
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	var/datum/gas_mixture/pumped = new
	pumped.copy_from(air_contents)

	var/pressure_delta = 10000

	pressure_delta = min(pressure_delta, (internal_pressure - environment_pressure))

	if(pressure_delta > 0.1)
		var/transfer_moles = pressure_delta*environment.volume/(pumped.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = pumped.remove(transfer_moles)

		loc.assume_air(removed)

/obj/machinery/atmospherics/miner/sleeping_agent
	name = "\improper N2O Gas Miner"
	light_color = "#FFCCCC"

	AddAir()
		var/datum/gas/sleeping_agent/trace_gas = new
		air_contents.trace_gases += trace_gas
		trace_gas.moles = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	light_color = "#CCFFCC"

	AddAir()
		air_contents.nitrogen = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	light_color = "#007FFF"

	AddAir()
		air_contents.oxygen = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	light_color = "#FF0000"

	AddAir()
		air_contents.toxins = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	light_color = "#CDCDCD"

	AddAir()
		air_contents.carbon_dioxide = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)


/obj/machinery/atmospherics/miner/air
	name = "\improper Air Miner"
	desc = "You fucking cheater."
	light_color = "#70DBDB"

	on = 0

	AddAir()
		air_contents.carbon_dioxide = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)