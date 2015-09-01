/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/canister_color = "yellow"
	var/can_label = 1
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""
	var/update_flag = 0


/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "canister: \[N2O\]"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "canister: \[N2\]"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "red"
	canister_color = "red"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "canister: \[O2\]"
	desc = "Oxygen. Necessary for human life."
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/toxins
	name = "canister \[Plasma\]"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "canister \[CO2\]"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	icon_state = "black"
	canister_color = "black"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/air
	name = "canister \[Air\]"
	desc = "Pre-mixed air."
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/proc/check_change()
	var/old_flag = update_flag
	update_flag = 0
	if(holding)
		update_flag |= 1
	if(connected_port)
		update_flag |= 2

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < 10)
		update_flag |= 4
	else if(tank_pressure < ONE_ATMOSPHERE)
		update_flag |= 8
	else if(tank_pressure < 15*ONE_ATMOSPHERE)
		update_flag |= 16
	else
		update_flag |= 32

	if(update_flag == old_flag)
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/canister/update_icon()
/*
update_flag
1 = holding
2 = connected_port
4 = tank_pressure < 10
8 = tank_pressure < ONE_ATMOS
16 = tank_pressure < 15*ONE_ATMOS
32 = tank_pressure go boom.
*/

	if (destroyed)
		overlays = 0
		icon_state = text("[]-1", canister_color)
		return

	if(icon_state != "[canister_color]")
		icon_state = "[canister_color]"

	if(check_change()) //Returns 1 if no change needed to icons.
		return

	src.overlays = 0

	if(update_flag & 1)
		overlays += "can-open"
	if(update_flag & 2)
		overlays += "can-connector"
	if(update_flag & 4)
		overlays += "can-o0"
	if(update_flag & 8)
		overlays += "can-o1"
	else if(update_flag & 16)
		overlays += "can-o2"
	else if(update_flag & 32)
		overlays += "can-o3"
	return


/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)
		air_update_turf()

		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()
		investigate_log("was destroyed by heat/gunfire.", "atmos")

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process_atmos()
	if (destroyed)
		return PROCESS_KILL

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
				air_update_turf()
			src.update_icon()


	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

/obj/machinery/portable_atmospherics/canister/process()
	src.updateDialog()
	return ..()

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

/obj/machinery/portable_atmospherics/canister/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(Proj.damage)
			src.health -= round(Proj.damage / 2)
			healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/ex_act(severity, target)
	switch(severity)
		if(1.0)
			if(destroyed || prob(30))
				qdel(src)
			else
				src.health = 0
				healthcheck()
			return
		if(2.0)
			if(destroyed)
				qdel(src)
			else
				src.health -= rand(40, 100)
				healthcheck()
			return
		if(3.0)
			src.health -= rand(15,40)
			healthcheck()
			return
	return

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/weapon/W, mob/user, params)
	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("<span class='danger'>[user] hits \the [src] with a [W]!</span>")
		investigate_log("was smacked with \a [W] by [key_name(user)]", "atmos")
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
			user << "<span class='notice'>You pulse-pressurize your jetpack from the tank.</span>"
		return

	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_tk(mob/user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(mob/user)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/interact(mob/user, ui_key = "main")
	if (src.destroyed || !user)
		return

	SSnano.try_update_ui(user, src, ui_key, null, src.get_ui_data())

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if (src.destroyed)
		return

	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "canister.tmpl", "Canister", 480, 400, 0)

/obj/machinery/portable_atmospherics/canister/get_ui_data()
	var/data = list()
	data["name"] = src.name
	data["canLabel"] = src.can_label ? 1 : 0
	data["portConnected"] = src.connected_port ? 1 : 0
	data["tankPressure"] = round(src.air_contents.return_pressure() ? src.air_contents.return_pressure() : 0)
	data["releasePressure"] = round(src.release_pressure ? src.release_pressure : 0)
	data["minReleasePressure"] = round(ONE_ATMOSPHERE/10)
	data["maxReleasePressure"] = round(10*ONE_ATMOSPHERE)
	data["valveOpen"] = src.valve_open ? 1 : 0

	data["hasHoldingTank"] = src.holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = src.holding.name, "tankPressure" = round(src.holding.air_contents.return_pressure()))
	return data

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict.
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=canister")
		onclose(usr, "canister")
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.set_machine(src)

		if(href_list["toggle"])
			var/logmsg
			if (valve_open)
				if (holding)
					logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the [holding]<br>"
				else
					logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the <span class='boldannounce'>air</span><br>"
			else
				if (holding)
					logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting the transfer into the [holding]<br>"
				else
					logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting the transfer into the <span class='boldannounce'>air</span><br>"
					if(air_contents.toxins > 0)
						message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) opened a canister that contains plasma! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						log_admin("[key_name(usr)] opened a canister that contains plasma at [x], [y], [z]")
					var/datum/gas/sleeping_agent = locate(/datum/gas/sleeping_agent) in air_contents.trace_gases
					if(sleeping_agent && (sleeping_agent.moles > 1))
						message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) opened a canister that contains N2O! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						log_admin("[key_name(usr)] opened a canister that contains N2O at [x], [y], [z]")
			investigate_log(logmsg, "atmos")
			release_log += logmsg
			valve_open = !valve_open

		if (href_list["remove_tank"])
			if(holding)
				if (valve_open)
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transfering into the <span class='boldannounce'>air</span><br>", "atmos")
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
					"\[Plasma\]" = "orange", \
					"\[CO2\]" = "black", \
					"\[Air\]" = "grey", \
					"\[CAUTION\]" = "yellow", \
				)
				var/label = input("Choose canister label", "Gas canister") as null|anything in colors
				if (label)
					src.canister_color = colors[label]
					src.icon_state = colors[label]
					src.name = "canister: [label]"
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

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

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1
