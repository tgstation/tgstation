//Particle Catchers. Works by eating nuclear particles and singulo energy to produce power. Encourages fusion and more creative SM setups (like CO2 + BZ for mass particles)
//Subject to heavy rebalancing as radiation as a whole is being adjusted ig

//radiation needs to be over this amount to get power
#define RAD_COLLECTOR_EFFICIENCY 80
#define RAD_COLLECTOR_COEFFICIENT 100
//(this*100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_STORED_OUT 0.04
//Produces at least 1000 watts if it has more than that stored
#define RAD_COLLECTOR_OUTPUT min(stored_energy, (stored_energy*RAD_COLLECTOR_STORED_OUT)+1000)

//FUSION PARTICLE "REWORK"... HERE. TODO: Make this actually subtract valid amounts of energy from the object firing them. Then again...
/obj/projectile/energy/nuclear_particle
	var/stored_energy

/obj/projectile/energy/nuclear_particle/Initialize(mapload)
	. = ..()
	if(!stored_energy) //Will generate a random value on every initialise
		stored_energy = rand(150,30000) //SUPER lethal. Eeyikes!
		damage = max((stored_energy*0.1),80) //Yeowch-tier

//replacing this dumbass machine with something more fun.

/obj/machinery/power/rad_collector //Still use this for compat reasons
	name = "Particle Capture Array"
	desc = "A device which uses a large plasma-glass sheet to 'catch' particles, harvesting their stored energy. Do not taunt. Can be loaded with a variety of gases to produce additional power."
	icon = 'monkestation/icons/obj/engine/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/rad_collector
	rad_insulation = RAD_EXTREME_INSULATION
	///Stores the loaded tank instance
	var/obj/item/tank/internals/plasma/loaded_tank = null
	///The amount of energy that is currently inside the machine before being converted to electricity
	var/stored_energy = 0 // stored_energy += (pulse_strength-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT
	///Is the collector working?
	var/active = FALSE
	///Is the collector locked with an id?
	var/locked = FALSE
	///Amount of gas removed per tick
	var/drain_ratio = 0.5
	///Multiplier for the amount of gas removed per tick
	var/power_production_drain = 0.001
	//Multiplier for tanks and gases insidee
	var/power_coeff = 1

/obj/machinery/power/rad_collector/anchored/Initialize(mapload) 
	. = ..()
	set_anchored(TRUE)

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(eat_some_bullets)) //Specifically handles the next part...

/obj/machinery/power/rad_collector/Destroy()
	return ..()

/obj/machinery/power/rad_collector/should_have_node()
	return anchored

/obj/machinery/power/rad_collector/proc/eat_some_bullets(datum/source, obj/projectile/projectile)
	if(istype(projectile,/obj/projectile/energy/nuclear_particle))
		var/obj/projectile/energy/nuclear_particle/proj = projectile
		var/final_output = (proj.stored_energy += power_coeff)
		stored_energy += (final_output*1.4) //2.5 yields ~145KW/s avg per collector.
		return

/obj/machinery/power/rad_collector/process(seconds_per_tick)
	if(loaded_tank)
		var/datum/gas_mixture/tank_mix = loaded_tank.return_air()
		if(active)
			for(var/id in tank_mix.gases)
				if(tank_mix.gases[id][MOLES] >= 10) //Stops cheesing.
					power_coeff += (GLOB.meta_gas_info[id][META_GAS_SPECIFIC_HEAT]) //250 (plasma), 2000 (hypernobi), etc etc
					var/gasdrained = min(power_production_drain * drain_ratio * seconds_per_tick, tank_mix.gases[id][MOLES])
					tank_mix.gases[id][MOLES] -= gasdrained
					tank_mix.assert_gas(/datum/gas/hydrogen) //Produce Hydrogen. Mostly because it explodes.
					tank_mix.gases[/datum/gas/hydrogen][MOLES] += gasdrained
					tank_mix.garbage_collect()
		if(!tank_mix && loaded_tank)
			investigate_log("<font color='red'>out of gas.</font>.", INVESTIGATE_ENGINE)
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			power_coeff = 0 //Should NEVER happen.
			return //Immediately stop processing past this point to prevent atmos/MC crashes
	if(!loaded_tank)
		power_coeff -= 0.5 //Half power
	var/power_produced = RAD_COLLECTOR_OUTPUT
	add_avail(power_produced)
	stored_energy -= power_produced

/obj/machinery/power/rad_collector/interact(mob/user)
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
	investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_ENGINE)

/obj/machinery/power/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(!loaded_tank)
		return ..()
	if(!silent)
		to_chat(user, span_warning("Remove the plasma tank first!"))
	return FAILED_UNFASTEN


/obj/machinery/power/rad_collector/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(!anchorvalue)
		disconnect_from_network()
		return
	connect_to_network()

/obj/machinery/power/rad_collector/attackby(obj/item/item, mob/user, params)
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

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/item)
	. = ..()
	default_unfasten_wrench(user, item)
	return TRUE

/obj/machinery/power/rad_collector/screwdriver_act(mob/living/user, obj/item/item)
	if(..())
		return TRUE
	if(!loaded_tank)
		default_deconstruction_screwdriver(user, icon_state, icon_state, item)
		return TRUE
	to_chat(user, span_warning("Remove the plasma tank first!"))
	return TRUE

/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/I)
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

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(!loaded_tank)
		return null
	return loaded_tank.return_analyzable_air()

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(!active)
		. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma, Tritium, CO2 or Hypernobilium</b>.\"")
	// stored_energy is converted directly to watts every SSmachines.wait * 0.1 seconds.
	// Therefore, its units are joules per SSmachines.wait * 0.1 seconds.
	// So joules = stored_energy * SSmachines.wait * 0.1
	var/joules = stored_energy * SSmachines.wait * 0.1
	. += span_notice("[src]'s display states that it has stored <b>[display_joules(joules)]</b>, and is processing <b>[display_power(RAD_COLLECTOR_OUTPUT)]</b>.")

/obj/machinery/power/rad_collector/atom_break(damage_flag)
	. = ..()
	if(.)
		eject()

/obj/machinery/power/rad_collector/proc/eject()
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

/obj/machinery/power/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		. += "ptank"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += loaded_tank ? "on" : "error"

/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_appearance()
	return

//LEGACY RADIATION HANDLING CODE ! FOR SINGULO ONLY \\

/obj/machinery/power/rad_collector/rad_act(intensity)
	if(loaded_tank && active && intensity > RAD_COLLECTOR_EFFICIENCY)
		stored_energy += ((intensity+power_coeff)-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_OUTPUT
