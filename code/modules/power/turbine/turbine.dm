/obj/machinery/power/turbine
	density = TRUE
	resistance_flags = FIRE_PROOF
	can_atmos_pass = ATMOS_PASS_DENSITY

	///Theoretical volume of gas that's moving through the turbine, it expands the further it goes
	var/gas_theoretical_volume = 0
	///Stores the turf thermal conductivity to restore it later
	var/our_turf_thermal_conductivity
	///Checks if the machine is processing or not
	var/active = FALSE
	///The parts can be registered on the main one only when their panel is closed
	var/can_connect = TRUE

	///Reference to our turbine part
	var/obj/item/turbine_parts/installed_part
	///Path of the turbine part we can install
	var/obj/item/turbine_parts/part_path

	var/has_gasmix = FALSE
	var/datum/gas_mixture/machine_gasmix

	var/mapped = TRUE

	///Our overlay when active
	var/active_overlay = ""
	///Our overlay when off
	var/off_overlay = ""
	///Our overlay when open
	var/open_overlay = ""
	///Should we use emissive appearance?
	var/emissive = FALSE

/obj/machinery/power/turbine/Initialize(mapload)
	. = ..()

	if(has_gasmix)
		machine_gasmix = new
		machine_gasmix.volume = gas_theoretical_volume

	if(part_path && mapped)
		installed_part = new part_path(src)

	air_update_turf(TRUE)

	update_appearance()

/obj/machinery/power/turbine/Destroy()

	air_update_turf(TRUE)

	if(installed_part)
		QDEL_NULL(installed_part)

	if(machine_gasmix)
		machine_gasmix = null

	return ..()

/obj/machinery/power/turbine/block_superconductivity()
	return TRUE

/obj/machinery/power/turbine/examine(mob/user)
	. = ..()
	if(installed_part)
		. += "Currently at tier [installed_part.current_tier]."
		if(installed_part.current_tier + 1 < installed_part.max_tier)
			. += "Can be upgraded by using a tier [installed_part.current_tier + 1] part."
		. += "The [installed_part.name] can be removed by right-click with a crowbar tool."
	else
		. += "Is missing a [initial(part_path.name)]."

/obj/machinery/power/turbine/update_overlays()
	. = ..()
	if(panel_open)
		. += open_overlay

	if(active)
		. += active_overlay
		if(emissive)
			. += emissive_appearance(icon, active_overlay)
	else
		. += off_overlay

/obj/machinery/power/turbine/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, "You can't open [src] while it's on!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!anchored)
		to_chat(user, span_notice("Anchor [src] first!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(panel_open && !installed_part)
		to_chat(user, "You need to install [initial(part_path.name)] first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(src, 50)
	panel_open = !panel_open
	if(panel_open)
		disable_parts(user)
	else
		enable_parts(user)
	var/descriptor = panel_open ? "open" : "close"
	balloon_alert(user, "you [descriptor] the maintenance hatch of [src]")
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/turbine/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/power/turbine/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/turbine/on_deconstruction()
	if(installed_part)
		installed_part.forceMove(loc)
	return ..()

/obj/machinery/power/turbine/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(!installed_part)
		return
	user.put_in_hands(installed_part)

/**
 * Allow easy enabling of each machine for connection to the main controller
 */
/obj/machinery/power/turbine/proc/enable_parts(mob/user)
	can_connect = TRUE

/**
 * Allow easy disabling of each machine from the main controller
 */
/obj/machinery/power/turbine/proc/disable_parts(mob/user)
	can_connect = FALSE

/obj/machinery/power/turbine/Moved(atom/OldLoc, Dir)
	. = ..()
	disable_parts()
	air_update_turf(TRUE)

/obj/machinery/power/turbine/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == installed_part)
		installed_part = null

/obj/machinery/power/turbine/attackby(obj/item/object, mob/user, params)
	if(active)
		balloon_alert(user, "turn off the machine first")
		return ..()

	if(!panel_open)
		balloon_alert(user, "open the maintenance hatch first")
		return ..()

	if(!istype(object, part_path))
		return ..()

	install_part(object, user)

/**
 * Checks if the machine part we are installing is an improvement over the installed one (if present)
 * Currently it doesn't allow worst parts to be installed
 */
/obj/machinery/power/turbine/proc/install_part(obj/item/turbine_parts/part_object, mob/user)
	if(!do_after(user, 2 SECONDS, src))
		return
	if(installed_part)
		user.put_in_hands(installed_part)
		balloon_alert(user, "replaced part with the one in hand")
	else
		balloon_alert(user, "installed new part")
	user.transferItemToLoc(part_object, src)
	installed_part = part_object
	calculate_parts_limits()

/**
 * Gets the efficiency of the installed part, returns 0 if no part is installed
 */
/obj/machinery/power/turbine/proc/get_efficiency()
	if(installed_part)
		return installed_part.part_efficiency
	return 0

/**
 * Called when installing new parts and when activating the main machine
 */
/obj/machinery/power/turbine/proc/calculate_parts_limits()
	return

/obj/machinery/power/turbine/inlet_compressor
	name = "inlet compressor"
	desc = "The input side of a turbine generator, contains the compressor."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "inlet_compressor"

	circuit = /obj/item/circuitboard/machine/turbine_compressor

	gas_theoretical_volume = 1000

	part_path = /obj/item/turbine_parts/compressor

	has_gasmix = TRUE

	active_overlay = "inlet_animation"
	off_overlay = "inlet_off"
	open_overlay = "inlet_open"

/obj/machinery/power/turbine/inlet_compressor/constructed
	mapped = FALSE

/obj/machinery/power/turbine/turbine_outlet
	name = "turbine outlet"
	desc = "The output side of a turbine generator, contains the turbine and the stator."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "turbine_outlet"

	circuit = /obj/item/circuitboard/machine/turbine_stator

	gas_theoretical_volume = 6000

	part_path = /obj/item/turbine_parts/stator

	has_gasmix = TRUE

	active_overlay = "outlet_animation"
	off_overlay = "outlet_off"
	open_overlay = "outlet_open"

/obj/machinery/power/turbine/turbine_outlet/constructed
	mapped = FALSE

/obj/machinery/power/turbine/core_rotor
	name = "core rotor"
	desc = "The middle part of a turbine generator, contains the rotor and the main computer."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "core_rotor"

	circuit = /obj/item/circuitboard/machine/turbine_rotor

	gas_theoretical_volume = 3000

	part_path = /obj/item/turbine_parts/rotor

	has_gasmix = TRUE

	active_overlay = "core_light"
	open_overlay = "core_open"

	emissive = TRUE

	///ID to easily connect the main part of the turbine to the computer
	var/mapping_id

	///Reference to the compressor
	var/obj/machinery/power/turbine/inlet_compressor/compressor
	///Reference to the turbine
	var/obj/machinery/power/turbine/turbine_outlet/turbine

	///Reference to the input turf
	var/turf/open/input_turf
	///Reference to the output turf
	var/turf/open/output_turf

	///Rotation per minute the machine is doing
	var/rpm
	///Amount of power the machine is producing
	var/produced_energy

	///Check to see if all parts are connected to the core
	var/all_parts_connected = FALSE
	///If the machine was completed before reopening it, try to remake it
	var/was_complete = FALSE

	///Max rmp that the installed parts can handle, limits the rpms
	var/max_allowed_rpm = 0
	///Max temperature that the installed parts can handle, unlimited and causes damage to the machine
	var/max_allowed_temperature = 0

	///Amount of damage the machine has received
	var/damage = 0
	///Used to calculate the max damage received per tick and if the alarm should be called
	var/damage_archived = 0

	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng
	///The engineering channel
	var/engineering_channel = "Engineering"
	///Ratio of the amount of gas going in the turbine
	var/intake_regulator = 0.5

	COOLDOWN_DECLARE(turbine_damage_alert)

/obj/machinery/power/turbine/core_rotor/constructed
	mapped = FALSE

/obj/machinery/power/turbine/core_rotor/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

	new /obj/item/paper/guides/jobs/atmos/turbine(loc)

/obj/machinery/power/turbine/core_rotor/LateInitialize()
	. = ..()
	activate_parts()

/obj/machinery/power/turbine/core_rotor/Destroy()
	disable_parts()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/turbine/core_rotor/enable_parts(mob/user)
	. = ..()
	if(was_complete)
		was_complete = FALSE
		activate_parts(user)

/obj/machinery/power/turbine/core_rotor/disable_parts(mob/user)
	. = ..()
	if(all_parts_connected)
		was_complete = TRUE
	deactivate_parts()

/obj/machinery/power/turbine/core_rotor/multitool_act(mob/living/user, obj/item/tool)
	if(!all_parts_connected && activate_parts(user))
		balloon_alert(user, "all parts are linked")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/turbine/core_rotor/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!all_parts_connected)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	var/obj/item/multitool/multitool = tool
	multitool.buffer = src
	to_chat(user, span_notice("You store linkage information in [tool]'s buffer."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Called to activate the complete machine, checks for part presence, correct orientation and installed parts
 * Registers the input/output turfs and start process_atmos()
 */
/obj/machinery/power/turbine/core_rotor/proc/activate_parts(mob/user, check_only = FALSE)

	compressor = locate(/obj/machinery/power/turbine/inlet_compressor) in get_step(src, turn(dir, 180))
	turbine = locate(/obj/machinery/power/turbine/turbine_outlet) in get_step(src, dir)

	if(!compressor || !turbine)
		if(user)
			balloon_alert(user, "missing parts detected")
		return FALSE

	var/parts_present = TRUE
	if(compressor.dir != dir || !compressor.can_connect || !compressor.installed_part)
		if(user)
			balloon_alert(user, "error while activating the compressor")
		parts_present = FALSE
	if(turbine.dir != dir || !turbine.can_connect || !turbine.installed_part)
		if(user)
			balloon_alert(user, "error while activating the turbine")
		parts_present = FALSE

	if(!parts_present)
		all_parts_connected = FALSE
		return FALSE

	if(check_only)
		return TRUE

	input_turf = get_step(compressor.loc, turn(dir, 180))
	output_turf = get_step(turbine.loc, dir)

	all_parts_connected = TRUE

	calculate_parts_limits()

	SSair.start_processing_machine(src)
	return TRUE

/**
 * Allows to null the various machines and references from the main core
 */
/obj/machinery/power/turbine/core_rotor/proc/deactivate_parts()
	if(all_parts_connected)
		power_off()
	compressor = null
	turbine = null
	input_turf = null
	output_turf = null
	all_parts_connected = FALSE
	SSair.stop_processing_machine(src)

/obj/machinery/power/turbine/core_rotor/on_deconstruction()
	if(all_parts_connected)
		deactivate_parts()
	return ..()

/obj/machinery/power/turbine/core_rotor/calculate_parts_limits()
	if(activate_parts(check_only = TRUE))
		max_allowed_rpm = (compressor.installed_part.max_rpm + turbine.installed_part.max_rpm + installed_part.max_rpm) / 3
		max_allowed_temperature = (compressor.installed_part.max_temperature + turbine.installed_part.max_temperature + installed_part.max_temperature) / 3

/**
 * Called on each atmos tick, calculates the damage done and healed based on temperature
 */
/obj/machinery/power/turbine/core_rotor/proc/calculate_damage_done(temperature)
	damage_archived = damage
	var/temperature_difference = temperature - max_allowed_temperature
	var/damage_done = round(log(90, max(temperature_difference, 1)), 0.5)

	damage = max(damage + damage_done * 0.5, 0)
	damage = min(damage_archived + TURBINE_MAX_TAKEN_DAMAGE, damage)
	if(temperature_difference < 0)
		damage = max(damage - TURBINE_DAMAGE_HEALING, 0)

	if((damage - damage_archived >= 2 || damage > TURBINE_DAMAGE_ALARM_START) && COOLDOWN_FINISHED(src, turbine_damage_alert))
		damage_alert(damage_done)

/**
 * Toggle power on and off, not safe
 */
/obj/machinery/power/turbine/core_rotor/proc/toggle_power()
	if(active)
		power_off()
		return
	power_on()

/**
 * Activate all three parts, not safe, it assumes the machine already connected and properly working
 */
/obj/machinery/power/turbine/core_rotor/proc/power_on()
	active = TRUE
	compressor.active = TRUE
	turbine.active = TRUE
	call_parts_update_appearance()

/**
 * Deactivate all three parts, not safe, it assumes the machine already connected and properly working
 */
/obj/machinery/power/turbine/core_rotor/proc/power_off()
	active = FALSE
	compressor.active = FALSE
	turbine.active = FALSE
	call_parts_update_appearance()

/**
 * Calls all parts update appearance proc.
 */
/obj/machinery/power/turbine/core_rotor/proc/call_parts_update_appearance()
	update_appearance()
	compressor?.update_appearance()
	turbine?.update_appearance()

/**
 * Returns true if all parts have their panel closed
 */
/obj/machinery/power/turbine/core_rotor/proc/all_parts_ready()
	return !panel_open && !compressor.panel_open && !turbine.panel_open

/**
 * Called once every 15 to 5 seconds (depend on damage done), handles alarm calls
 */
/obj/machinery/power/turbine/core_rotor/proc/damage_alert(damage_done)
	COOLDOWN_START(src, turbine_damage_alert, max(round(TURBINE_DAMAGE_ALARM_START - damage_done), 5) SECONDS)

	var/integrity = get_turbine_integrity()

	if(integrity <= 0)
		failure()
		return

	radio.talk_into(src, "Warning, turbine at [get_area_name(src)] taking damage, current integrity at [integrity]%!", engineering_channel)
	playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)

/**
 * Getter for turbine integrity, return the amount in %
 */
/obj/machinery/power/turbine/core_rotor/proc/get_turbine_integrity()
	var/integrity = damage / 500
	integrity = max(round(100 - integrity * 100, 0.01), 0)
	return integrity

/**
 * Called when the integrity reaches 0%, explode the machine based on the reached RPM
 */
/obj/machinery/power/turbine/core_rotor/proc/failure()
	deactivate_parts()
	if(rpm < 35000)
		explosion(src, 0, 1, 4)
		return
	if(rpm < 87500)
		explosion(src, 0, 2, 6)
		return
	if(rpm < 220000)
		explosion(src, 1, 3, 7)
		return
	if(rpm < 550000)
		explosion(src, 2, 5, 7)

/obj/machinery/power/turbine/core_rotor/process_atmos()

	if(!active || !all_parts_connected)
		return

	var/datum/gas_mixture/input_turf_mixture = input_turf.return_air()

	if(!input_turf_mixture)
		return

	calculate_damage_done(input_turf_mixture.temperature)

	//the compressor compresses down the gases from 2500 L to 1000 L
	//the temperature and pressure rises up, you can regulate this to increase/decrease the amount of gas moved in.
	var/compressor_work = do_calculations(input_turf_mixture, compressor.machine_gasmix, regulated = TRUE)
	input_turf.air_update_turf(TRUE)
	var/compressor_pressure = max(compressor.machine_gasmix.return_pressure(), 0.01)

	//the rotor moves the gases that expands from 1000 L to 3000 L, they cool down and both temperature and pressure lowers
	var/rotor_work = do_calculations(compressor.machine_gasmix, machine_gasmix, compressor_work)

	//the turbine expands the gases more from 3000 L to 6000 L, cooling them down further.
	var/turbine_work = do_calculations(machine_gasmix, turbine.machine_gasmix, abs(rotor_work))

	var/turbine_pressure = max(turbine.machine_gasmix.return_pressure(), 0.01)

	//the total work done by the gas
	var/work_done = turbine.machine_gasmix.total_moles() * R_IDEAL_GAS_EQUATION * turbine.machine_gasmix.temperature * log(compressor_pressure / turbine_pressure)

	//removing the work needed to move the compressor but adding back the turbine work that is the one generating most of the power.
	work_done = max(work_done - compressor_work * TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER - turbine_work, 0)

	rpm = ((work_done * compressor.get_efficiency()) ** turbine.get_efficiency()) * get_efficiency() / TURBINE_RPM_CONVERSION
	rpm = min(rpm, max_allowed_rpm)

	produced_energy = rpm * TURBINE_ENERGY_RECTIFICATION_MULTIPLIER * TURBINE_RPM_CONVERSION

	add_avail(produced_energy)

	turbine.machine_gasmix.pump_gas_to(output_turf.air, turbine.machine_gasmix.return_pressure())
	output_turf.air_update_turf(TRUE)

/**
 * Handles all the calculations needed for the gases, work done, temperature increase/decrease
 */
/obj/machinery/power/turbine/core_rotor/proc/do_calculations(datum/gas_mixture/input_mix, datum/gas_mixture/output_mix, work_amount_to_remove, regulated = FALSE)
	var/work_done = input_mix.total_moles() * R_IDEAL_GAS_EQUATION * input_mix.temperature * log((input_mix.volume * max(input_mix.return_pressure(), 0.01)) / (output_mix.volume * max(output_mix.return_pressure(), 0.01))) * TURBINE_WORK_CONVERSION_MULTIPLIER
	if(work_amount_to_remove)
		work_done = work_done - work_amount_to_remove

	var/intake_size = 1
	if(regulated)
		intake_size = intake_regulator

	input_mix.pump_gas_to(output_mix, input_mix.return_pressure() * intake_size)
	var/output_mix_heat_capacity = output_mix.heat_capacity()
	if(!output_mix_heat_capacity)
		return 0
	output_mix.temperature = max((output_mix.temperature * output_mix_heat_capacity + work_done * output_mix.total_moles() * TURBINE_HEAT_CONVERSION_MULTIPLIER) / output_mix_heat_capacity, TCMB)
	return work_done

/obj/item/paper/guides/jobs/atmos/turbine
	name = "paper- 'Quick guide on the new and improved turbine!'"
	info = "<B>How to operate the turbine</B><BR>\
	-The new turbine is not much different from the old one, just put gases in the chamber, light them up and activate the machine from the nearby computer.\
	-There is a new parameter that's visible within the turbine computer's UI, damage. The turbine will be damaged when the heat gets too high, according to the tiers of the parts used. Make sure it doesn't get too hot!<BR>\
	-You can avoid the turbine critically failing by upgrading the parts of the machine, but not with stock parts as you might be used to. There are 3 all-new parts, one for each section of the turbine.<BR>\
	-These items are: the compressor part, the rotor part and the stator part. All of them can be printed in any engi lathes (both proto and auto).<BR>\
	-There are 4 tiers for these items, only the first tier can be printed. The next tier of each part can be made by using various materials on the part (clicking with the material in hand, on the part). The material required to reach the next tier is stated in the part's examine text, try shift clicking it!<BR>\
	-Each tier increases the efficiency (more power), the max reachable RPM, and the max temperature that the machine can process without taking damage (up to fusion temperatures at the last tier!).<BR>\
	-A word of warning, the machine is very inefficient in its gas consumption and many unburnt gases will pass through. If you want to be cheap you can either pre-burn the gases or add a filtering system to collect the unburnt gases and reuse them."
