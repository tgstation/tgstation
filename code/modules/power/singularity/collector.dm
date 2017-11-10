#define RAD_COLLECTOR_THRESHOLD				80		// radiation needs to be over this amount to get power
#define RAD_COLLECTOR_COEFFICIENT			100		// internal power is increased by (pulse_strength-RAD_COLLECTOR_THRESHOLD)*RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_BASE_PRESSURE			300
#define RAD_COLLECTOR_PRESSURE_COEFFICIENT	0.15	// power output is * by 1 + ((pressure / BASE_PRESSURE - 1) * PRESSURE_COEFFICIENT)
#define RAD_COLLECTOR_TEMP_COEFFICIENT		0.3		// power output is * by 1 + (temperature / T20C - 1) * TEMP_COEFFICIENT

#define RAD_COLLECTOR_STORED_OUT			0.04	// (this*100)% of stored power outputted per tick.
													// Doesn't actualy change output total,
													// lower numbers just means collectors output for longer in absence of a source

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
//	use_power = NO_POWER_USE
	max_integrity = 350
	integrity_failure = 80
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/last_power = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1

	var/pressure_ratio = 1
	var/plasma_ratio = 1
	var/temperature_ratio = 1
	var/total_ratio = 1

/obj/machinery/power/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/rad_collector/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_EXTREME_INSULATION, FALSE, FALSE)

/obj/machinery/power/rad_collector/Destroy()
	return ..()

/obj/machinery/power/rad_collector/process()
	if(loaded_tank)
		var/datum/gas_mixture/air_contents = loaded_tank.air_contents
		if(!air_contents.gases[/datum/gas/plasma])
			investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_SINGULO)
			eject()
		else
			var/pressure = air_contents.return_pressure()
			var/total_moles = air_contents.total_moles()
			var/temperature = air_contents.temperature

			pressure_ratio = 1 + ((pressure / RAD_COLLECTOR_BASE_PRESSURE - 1) * RAD_COLLECTOR_PRESSURE_COEFFICIENT)
			plasma_ratio = air_contents.gases[/datum/gas/plasma][MOLES]/total_moles
			temperature_ratio = 1 + (T20C / temperature - 1) * RAD_COLLECTOR_TEMP_COEFFICIENT
			// Temperature < TCMB should not be possible. If you see a "division by zero" runtime here, blame gas mixture code.

			total_ratio = pressure_ratio * plasma_ratio * temperature_ratio


			air_contents.gases[/datum/gas/plasma][MOLES] -= 0.001*drainratio
			air_contents.garbage_collect()

			var/power_produced = min(last_power, (last_power*RAD_COLLECTOR_STORED_OUT)+1000) //Produces at least 1000 watts if it has more than that stored
			add_avail(power_produced * total_ratio)
			last_power-=power_produced

/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			"<span class='notice'>You turn the [src.name] [active? "on":"off"].</span>")
			var/fuel
			if(loaded_tank)
				fuel = loaded_tank.air_contents.gases[/datum/gas/plasma]
			fuel = fuel ? fuel[MOLES] : 0
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_SINGULO)
			return
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return

/obj/machinery/power/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(loaded_tank)
		if(!silent)
			to_chat(user, "<span class='warning'>Remove the plasma tank first!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/rad_collector/default_unfasten_wrench(mob/user, obj/item/wrench/W, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		to_chat(user, "<span class='notice'>[W] detects that [DisplayPower(last_power)] is being processed.</span>")
		return TRUE
	else if(istype(W, /obj/item/device/analyzer) && loaded_tank)
		atmosanalyzer_scan(loaded_tank.air_contents, user)
	else if(istype(W, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to the floor first!</span>")
			return TRUE
		if(loaded_tank)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded!</span>")
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return
		loaded_tank = W
		update_icons()
	else if(istype(W, /obj/item/crowbar))
		if(loaded_tank)
			if(locked)
				to_chat(user, "<span class='warning'>The controls are locked!</span>")
				return TRUE
			eject()
			return TRUE
		else
			to_chat(user, "<span class='warning'>There isn't a tank loaded!</span>")
			return TRUE
	else if(istype(W, /obj/item/wrench))
		default_unfasten_wrench(user, W, 0)
		return TRUE
	else if(W.GetID())
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
			else
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is active!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
			return TRUE
	else
		return ..()


/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		eject()
		stat |= BROKEN

/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = src.loaded_tank
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icons()

/obj/machinery/power/rad_collector/rad_act(pulse_strength)
	if(loaded_tank && active && pulse_strength > RAD_COLLECTOR_THRESHOLD)
		last_power += (pulse_strength-RAD_COLLECTOR_THRESHOLD)*RAD_COLLECTOR_COEFFICIENT

/obj/machinery/power/rad_collector/proc/update_icons()
	cut_overlays()
	if(loaded_tank)
		add_overlay("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay("on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icons()
	return

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_BASE_PRESSURE
#undef RAD_COLLECTOR_PRESSURE_COEFFICIENT
#undef RAD_COLLECTOR_TEMP_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
