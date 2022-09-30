//radiation needs to be over this amount to get power
#define RAD_COLLECTOR_THRESHOLD 80
//amount of joules created for each rad point over RAD_COLLECTOR_THRESHOLD
#define RAD_COLLECTOR_COEFFICIENT 200

/obj/machinery/power/energy_accumulator/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	req_access = list(ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)
	max_integrity = 350
	integrity_failure = 0.2
	rad_insulation = RAD_EXTREME_INSULATION
	///Stores the loaded tank instance
	var/obj/item/tank/internals/plasma/loaded_tank = null
	///Is the collector working?
	var/active = FALSE
	///Is the collector locked with an id?
	var/locked = FALSE
	///Amount of gas removed per tick
	var/drain_ratio = 0.5
	///Multiplier for the amount of gas removed per tick
	var/power_production_drain = 0.001

/obj/machinery/power/energy_accumulator/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/rad_collector/process(delta_time)
	if(!loaded_tank)
		return
	var/datum/gas_mixture/tank_mix = loaded_tank.return_air()
	if(!tank_mix.gases[/datum/gas/plasma])
		investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_SINGULO)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
		return
	var/gasdrained = min(power_production_drain * drain_ratio * delta_time, tank_mix.gases[/datum/gas/plasma][MOLES])
	tank_mix.gases[/datum/gas/plasma][MOLES] -= gasdrained
	tank_mix.assert_gas(/datum/gas/tritium)
	tank_mix.gases[/datum/gas/tritium][MOLES] += gasdrained
	tank_mix.garbage_collect()

	. = ..()

/obj/machinery/power/energy_accumulator/rad_collector/interact(mob/user)
	if(!anchored)
		return
	if(locked)
		to_chat(user, span_warning("The controls are locked!"))
		return
	toggle_power()
	user.visible_message(span_notice("[user.name] turns the [src.name] [active? "on":"off"]."), \
	span_notice("You turn the [src.name] [active? "on":"off"]."))
	var/datum/gas_mixture/tank_mix = loaded_tank?.return_air()
	var/fuel
	if(loaded_tank)
		fuel = tank_mix.gases[/datum/gas/plasma]
	fuel = fuel ? fuel[MOLES] : 0
	investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_SINGULO)

/obj/machinery/power/energy_accumulator/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(!loaded_tank)
		return ..()
	if(!silent)
		to_chat(user, span_warning("Remove the plasma tank first!"))
	return FAILED_UNFASTEN

/obj/machinery/power/energy_accumulator/rad_collector/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, span_warning("[src] needs to be secured to the floor first!"))
			return TRUE
		if(loaded_tank)
			to_chat(user, span_warning("There's already a plasma tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(item, src))
			return
		loaded_tank = item
		update_appearance()
	else if(item.GetID())
		if(!allowed(user))
			to_chat(user, span_danger("Access denied."))
			return TRUE
		if(!active)
			to_chat(user, span_warning("The controls can only be locked when \the [src] is active!"))
			return TRUE
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
		return TRUE
	else
		return ..()

/obj/machinery/power/energy_accumulator/rad_collector/wrench_act(mob/living/user, obj/item/item)
	. = ..()
	default_unfasten_wrench(user, item)
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/screwdriver_act(mob/living/user, obj/item/item)
	if(..())
		return TRUE
	if(!loaded_tank)
		default_deconstruction_screwdriver(user, icon_state, icon_state, item)
		return TRUE
	to_chat(user, span_warning("Remove the plasma tank first!"))
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/crowbar_act(mob/living/user, obj/item/I)
	if(loaded_tank)
		if(!locked)
			eject()
			return TRUE
		to_chat(user, span_warning("The controls are locked!"))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	to_chat(user, span_warning("There isn't a tank loaded!"))
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/return_analyzable_air()
	if(!loaded_tank)
		return null
	return loaded_tank.return_analyzable_air()

/obj/machinery/power/energy_accumulator/rad_collector/examine(mob/user)
	. = ..()
	if(!active)
		. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>.\"")
	. += span_notice("[src]'s display states that it has stored <b>[display_joules(get_stored_joules())]</b>, and is processing <b>[display_power(get_power_output())]</b>.")

/obj/machinery/power/energy_accumulator/rad_collector/atom_break(damage_flag)
	. = ..()
	if(.)
		eject()

/obj/machinery/power/energy_accumulator/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/tank = loaded_tank
	if (!tank)
		return
	tank.forceMove(drop_location())
	tank.layer = initial(tank.layer)
	tank.plane = initial(tank.plane)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_appearance()

/obj/machinery/power/energy_accumulator/rad_collector/rad_act(pulse_strength)
	. = ..()
	if(loaded_tank && active && pulse_strength > RAD_COLLECTOR_THRESHOLD)
		stored_energy += joules_to_energy((pulse_strength-RAD_COLLECTOR_THRESHOLD)*RAD_COLLECTOR_COEFFICIENT)

/obj/machinery/power/energy_accumulator/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		. += "ptank"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += loaded_tank ? "on" : "error"

/obj/machinery/power/energy_accumulator/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_appearance()
	return

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
