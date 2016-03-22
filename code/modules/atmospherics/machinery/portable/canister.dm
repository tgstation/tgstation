#define CAN_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE * 10)
#define CAN_MIN_RELEASE_PRESSURE (ONE_ATMOSPHERE / 10)
#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon_state = "yellow"
	density = 1

	var/valve_open = FALSE
	var/obj/machinery/atmospherics/components/binary/passive_gate/pump
	var/release_log = ""

	volume = 1000
	var/filled = 0.5
	var/gas_type = ""
	var/release_pressure = ONE_ATMOSPHERE

	var/health = 100
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C

	var/update = 0
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/toxins,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"caution" = /obj/machinery/portable_atmospherics/canister,
	)

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "n2 canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "red"
	gas_type = "n2"
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "o2 canister"
	desc = "Oxygen. Necessary for human life."
	icon_state = "blue"
	gas_type = "o2"
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "co2 canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	icon_state = "black"
	gas_type = "co2"
/obj/machinery/portable_atmospherics/canister/toxins
	name = "plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	icon_state = "orange"
	gas_type = "plasma"
/obj/machinery/portable_atmospherics/canister/agent_b
	name = "agent b canister"
	desc = "Oxygen Agent B. You're not quite sure what it does."
	gas_type = "agent_b"
/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "n2o canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	icon_state = "redws"
	gas_type = "n2o"
/obj/machinery/portable_atmospherics/canister/air
	name = "air canister"
	desc = "Pre-mixed air."
	icon_state = "grey"

/obj/machinery/portable_atmospherics/canister/New(loc, datum/gas_mixture/existing_mixture)
	..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()

	pump = new(src, FALSE)
	pump.on = TRUE
	pump.stat = 0
	pump.build_network()

	update_icon()

/obj/machinery/portable_atmospherics/canister/Destroy()
	qdel(pump)
	pump = null
	return ..()

/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		air_contents.add_gas(gas_type)
		air_contents.gases[gas_type][MOLES] = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	air_contents.add_gases("o2","n2")
	air_contents.gases["o2"][MOLES] = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases["n2"][MOLES] = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

#define HOLDING 1
#define CONNECTED 2
#define EMPTY 4
#define LOW 8
#define FULL 16
#define DANGER 32
/obj/machinery/portable_atmospherics/canister/update_icon()
	if(stat & BROKEN)
		overlays.Cut()
		icon_state = "[initial(icon_state)]-1"
		return

	var/last_update = update
	update = 0

	if(holding)
		update |= HOLDING
	if(connected_port)
		update |= CONNECTED
	var/pressure = air_contents.return_pressure()
	if(pressure < 10)
		update |= EMPTY
	else if(pressure < ONE_ATMOSPHERE)
		update |= LOW
	else if(pressure < 15 * ONE_ATMOSPHERE)
		update |= FULL
	else
		update |= DANGER

	if(update == last_update)
		return

	overlays.Cut()
	if(update & HOLDING)
		overlays += "can-open"
	if(update & CONNECTED)
		overlays += "can-connector"
	if(update & EMPTY)
		overlays += "can-o0"
	else if(update & LOW)
		overlays += "can-o1"
	else if(update & FULL)
		overlays += "can-o2"
	else if(update & DANGER)
		overlays += "can-o3"
#undef HOLDING
#undef CONNECTED
#undef EMPTY
#undef LOW
#undef FULL
#undef DANGER

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(stat & BROKEN)
		return

	if(health <= 10)
		disconnect()
		var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
		var/turf/T = get_turf(src)
		T.assume_air(expelled_gas)
		air_update_turf()

		stat |= BROKEN
		density = 0
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		update_icon()
		investigate_log("was destroyed.", "atmos")

		if(holding)
			holding.loc = T
			holding = null

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(stat & BROKEN)
		return PROCESS_KILL
	if(!valve_open)
		pump.AIR1 = null
		pump.AIR2 = null
		return

	var/turf/T = get_turf(src)
	pump.AIR1 = air_contents
	pump.AIR2 = holding ? holding.air_contents : T.return_air()
	pump.target_pressure = release_pressure

	pump.process_atmos() // Pump gas.
	if(!holding)
		air_update_turf() // Update the environment if needed.
	update_icon()

/obj/machinery/portable_atmospherics/canister/blob_act()
	health = 0
	healthcheck()

/obj/machinery/portable_atmospherics/canister/bullet_act(obj/item/projectile/P)
	if((P.damage_type == BRUTE || P.damage_type == BURN))
		if(P.damage)
			health -= round(P.damage / 2)
			healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/ex_act(severity, target)
	switch(severity)
		if(1)
			if((stat & BROKEN) || prob(30))
				qdel(src)
				return
			else
				health = 0
		if(2)
			if(stat & BROKEN)
				qdel(src)
				return
			else
				health -= rand(40, 100)
		if(3)
			health -= rand(15, 40)
	healthcheck()

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/weapon/W, mob/user, params)
	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		investigate_log("was smacked with \a [W] by [key_name(user)].", "atmos")
		health -= W.force
		add_fingerprint(user)
		healthcheck()
	else
		..()

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
															datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "canister", name, 420, 405, master_ui, state)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = round(CAN_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(CAN_MIN_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(CAN_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding.air_contents.return_pressure())
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("relabel")
			var/label = input("New canister label:", name) as null|anything in label2types
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = new newtype(loc, air_contents)
					replacement.interact(usr)
					qdel(src)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = CAN_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = CAN_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([CAN_MIN_RELEASE_PRESSURE]-[CAN_MAX_RELEASE_PRESSURE] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = Clamp(round(pressure), CAN_MIN_RELEASE_PRESSURE, CAN_MAX_RELEASE_PRESSURE)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", "atmos")
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				if(!holding)
					var/plasma = air_contents.gases["plasma"]
					var/n2o = air_contents.gases["n2o"]
					if(n2o || plasma)
						message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) opened a canister that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""]! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						log_admin("[key_name(usr)] opened a canister that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""] at [x], [y], [z]")
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
			investigate_log(logmsg, "atmos")
			release_log += logmsg
			. = TRUE
		if("eject")
			if(holding)
				if(valve_open)
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transfering into the <span class='boldannounce'>air</span><br>", "atmos")
				holding.loc = get_turf(src)
				holding = null
				. = TRUE
	update_icon()
