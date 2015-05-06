/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON

	m_amt = 0 // fuk u
	w_type = NOT_RECYCLABLE

	var/datum/gas_mixture/air_contents
	var/datum/gas_mixture/pumping = new //used in transfering air around

	var/list/gases_to_create = list()

	var/on=1

	var/max_external_pressure=10000 // 10,000kPa ought to do it.
	var/internal_pressure=4500 // Bottleneck

	var/light_color = "#FFFFFF"

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/miner/New()
	..()
	air_contents = new
	air_contents.set_volume(1000)
	air_contents.set_temperature(T20C)
	AddAir()
	update_icon()

/obj/machinery/atmospherics/miner/wrenchAnchor(mob/user)
	..()
	if(on)
		on = 0
		update_icon()

// Critical equipment.
/obj/machinery/atmospherics/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/atmospherics/miner/blob_act()
	return

/obj/machinery/atmospherics/miner/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/miner/attack_ghost(var/mob/user)
	return

/obj/machinery/atmospherics/miner/attack_hand(var/mob/user)
	..()
	if(anchored)
		on=!on
		update_icon()

/obj/machinery/atmospherics/miner/attack_ai(var/mob/user)
	..()
	on=!on
	update_icon()

// Add air here.  DO NOT CALL UPDATE_VALUES OR UPDATE_ICON.
/obj/machinery/atmospherics/miner/proc/AddAir()
	for(var/gasid in gases_to_create)
		air_contents.set_gas(gasid, internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature), 0)
	return

/obj/machinery/atmospherics/miner/update_icon()
	src.overlays = 0
	if(stat & NOPOWER)
		return
	if(on)
		var/new_icon_state="on"
		var/new_color = light_color
		if(stat & BROKEN)
			new_icon_state="broken"
			new_color="#FF0000"
		var/image/I = image(icon, icon_state=new_icon_state, dir=src.dir)
		I.color=new_color
		overlays += I

/obj/machinery/atmospherics/miner/process()
	if(stat & NOPOWER)
		return
	if (!on)
		return

	var/oldstat=stat
	if(!istype(loc,/turf/simulated))
		stat |= BROKEN
	else
		stat &= ~BROKEN
	if(stat!=oldstat)
		update_icon()
	if(stat & BROKEN)
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.pressure

	pumping.copy_from(air_contents)

	var/pressure_delta = 10000

	// External pressure bound
	pressure_delta = min(pressure_delta, (max_external_pressure - environment_pressure))

	// Internal pressure bound (screwed up calc, won't be used anyway)
	//pressure_delta = min(pressure_delta, (internal_pressure - environment_pressure))

	if(pressure_delta > 0.1)
		var/transfer_moles = pressure_delta*environment.volume/(pumping.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = pumping.remove(transfer_moles)

		loc.assume_air(removed)

/obj/machinery/atmospherics/miner/sleeping_agent
	name = "\improper N2O Gas Miner"
	light_color = "#FFCCCC"

	gases_to_create = list(NITROUS_OXIDE)

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	light_color = "#CCFFCC"

	gases_to_create = list(NITROGEN)

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	light_color = "#007FFF"

	gases_to_create = list(OXYGEN)

/obj/machinery/atmospherics/miner/plasma
	name = "\improper Plasma Gas Miner"
	light_color = "#FF0000"

	gases_to_create = list(PLASMA)

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	light_color = "#CDCDCD"

	gases_to_create = list(CARBON_DIOXIDE)

/obj/machinery/atmospherics/miner/air
	name = "\improper Air Miner"
	desc = "Convenient, huh?"

	gases_to_create = list(OXYGEN,
							NITROGEN)

/obj/machinery/atmospherics/miner/air/fake
	desc = "You fucking <em>cheater</em>."
	light_color = "#70DBDB"

	gases_to_create = list(CARBON_DIOXIDE)

	on = 0
