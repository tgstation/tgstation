/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/canister_color = "yellow"
	var/can_label = 1
	var/filled = 0.5 // Mapping var: Set to 0 for empty, 1 to full, anywhere between.
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""
	var/busy = 0
	m_amt=10*CC_PER_SHEET_METAL
	w_type = RECYK_METAL

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Bio)\]"
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/update_icon()
	overlays = null

	if (destroyed)
		icon_state = "[canister_color]-1"
	else
		icon_state = canister_color
		overlays = new/list()

		if (holding)
			overlays.Add("can-open")

		if (connected_port)
			overlays.Add("can-connector")

		var/tank_pressure = air_contents.return_pressure()

		if (tank_pressure < 10)
			overlays.Add("can-o0")
		else if (tank_pressure < ONE_ATMOSPHERE)
			overlays.Add("can-o1")
		else if (tank_pressure < 15 * ONE_ATMOSPHERE)
			overlays.Add("can-o2")
		else
			overlays.Add("can-o3")

	return


/obj/machinery/portable_atmospherics/canister/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(get_turf(src), 'sound/effects/spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
			src.update_icon()

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	if(air_contents.temperature > PLASMA_FLASHPOINT)
		air_contents.zburn()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 200
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		src.health -= round(Proj.damage / 2)
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(iswelder(W) && src.destroyed)
		if(weld(W, user))
			user << "\blue You salvage whats left of \the [src]"
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src.loc)
			M.amount = 3
			del src
		return

	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("\red [user] hits the [src] with a [W]!")
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			user << "You pulse-pressurize your jetpack from the tank."
		return

	..()

	nanomanager.update_uis(src) // Update all NanoUIs attached to src



/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if (src.destroyed)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["minReleasePressure"] = round(ONE_ATMOSPHERE/10)
	data["maxReleasePressure"] = round(10*ONE_ATMOSPHERE)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "canister.tmpl", "Canister", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict. // yeah but without SOME sort of Topic check any dick can mess with them via exploits as he pleases -walter0o
	if (!istype(src.loc, /turf))
		return 0

	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr)) // exploit protection -walter0o
		usr << browse(null, "window=canister")
		onclose(usr, "canister")
		return

	if(href_list["toggle"])
		var/datum/gas/sleeping_agent/S = locate() in src.air_contents.trace_gases

		if (valve_open)
			if (holding)
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
			else
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the <font color='red'><b>air</b></font><br>"
		else
			if (holding)
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the [holding]<br>"
			else
				if(src.air_contents.toxins > 0 || (istype(S)))
					message_admins("[usr.real_name] ([formatPlayerPanel(usr,usr.ckey)]) opened a canister that contains \[[src.air_contents.toxins > 0 ? "Toxins" : ""] [istype(S) ? " N2O" : ""]\] at [formatJumpTo(loc)]!")
					log_admin("[usr]([ckey(usr.key)]) opened a canister that contains \[[src.air_contents.toxins > 0 ? "Toxins" : ""] [istype(S) ? " N2O" : ""]\] at [loc.x], [loc.y], [loc.z]")
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the <font color='red'><b>air</b></font><br>"
		valve_open = !valve_open

	if (href_list["remove_tank"])
		if(holding)
			if(valve_open)
				if(src.air_contents.toxins > 0 || (istype(S)))
					message_admins("[usr.real_name] ([formatPlayerPanel(usr,usr.ckey)]) opened a canister that contains \[[src.air_contents.toxins > 0 ? "Toxins" : ""] [istype(S) ? " N2O" : ""]\] at [formatJumpTo(loc)]!")
					log_admin("[usr]([ckey(usr.key)]) opened a canister that contains \[[src.air_contents.toxins > 0 ? "Toxins" : ""] [istype(S) ? " N2O" : ""]\] at [loc.x], [loc.y], [loc.z]")

			if(istype(holding, /obj/item/weapon/tank))
				holding.manipulated_by = usr.real_name
			holding.loc = loc
			holding = null

	if (href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		if(diff > 0)
			release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
		else
			release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

	if (href_list["relabel"])
		if (can_label)
			var/list/colors = list(\
				"\[N2O\]" = "redws", \
				"\[N2\]" = "red", \
				"\[O2\]" = "blue", \
				"\[Toxin (Bio)\]" = "orange", \
				"\[CO2\]" = "black", \
				"\[Air\]" = "grey", \
				"\[CAUTION\]" = "yellow", \
			)
			var/label = input("Choose canister label", "Gas canister") as null|anything in colors
			if (label)
				src.canister_color = colors[label]
				src.icon_state = colors[label]
				src.name = "Canister: [label]"

	src.add_fingerprint(usr)
	update_icon()

	return 1

/obj/machinery/portable_atmospherics/canister/toxins/New(loc)
	..(loc)
	air_contents.adjust(tx = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/oxygen/New(loc)
	..(loc)
	src.air_contents.adjust((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New(loc)
	..(loc)
	var/datum/gas/sleeping_agent/sleeping_agent = new
	sleeping_agent.moles = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.adjust(traces = list(sleeping_agent))
	update_icon()

/*
//Dirty way to fill room with gas. However it is a bit easier to do than creating some floor/engine/n2o -rastaf0
/obj/machinery/portable_atmospherics/canister/sleeping_agent/roomfiller/New()
	..()
	var/datum/gas/sleeping_agent/trace_gas = air_contents.trace_gases[1]
	trace_gas.moles = 9*4000
	spawn(10)
		var/turf/simulated/location = src.loc
		if (istype(src.loc))
			while (!location.air)
				sleep(10)
			location.assume_air(air_contents)
			air_contents = new
	return 1
*/

/obj/machinery/portable_atmospherics/canister/nitrogen/New(loc)
	..(loc)
	air_contents.adjust(n2 = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New(loc)
	..(loc)
	air_contents.adjust(co2 = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/air/New(loc)
	..(loc)

	air_contents.adjust(\
		(O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature),\
		n2 = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)\
	)

	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)

	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	user << "<span class='notice'>You start to slice away at \the [src]...</span>"
	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 50))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0
