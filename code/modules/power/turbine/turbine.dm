#define MINIMUM_TURBINE_PRESSURE 0.01
#define PRESSURE_MAX(value)(max((value), MINIMUM_TURBINE_PRESSURE))

/obj/machinery/power/turbine
	density = TRUE
	resistance_flags = FIRE_PROOF
	can_atmos_pass = ATMOS_PASS_DENSITY
	processing_flags = NONE

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

/obj/machinery/power/turbine/LateInitialize()
	. = ..()
	activate_parts()

/obj/machinery/power/turbine/Destroy()
	air_update_turf(TRUE)

	if(installed_part)
		QDEL_NULL(installed_part)

	if(machine_gasmix)
		machine_gasmix = null

	deactivate_parts()
	return ..()

/**
 * Handles all the calculations needed for the gases, work done, temperature increase/decrease
 */
/obj/machinery/power/turbine/proc/transfer_gases(datum/gas_mixture/input_mix, datum/gas_mixture/output_mix, work_amount_to_remove, intake_size = 1)
	//pump gases. if no gases were transfered then no work was done
	var/output_pressure = PRESSURE_MAX(output_mix.return_pressure())
	var/datum/gas_mixture/transfered_gases = input_mix.pump_gas_to(output_mix, input_mix.return_pressure() * intake_size)
	if(!transfered_gases)
		return 0

	//compute work done
	var/work_done = QUANTIZE(transfered_gases.total_moles()) * R_IDEAL_GAS_EQUATION * transfered_gases.temperature * log((transfered_gases.volume * PRESSURE_MAX(transfered_gases.return_pressure())) / (output_mix.volume * output_pressure)) * TURBINE_WORK_CONVERSION_MULTIPLIER
	if(work_amount_to_remove)
		work_done = work_done - work_amount_to_remove

	//compute temperature & work from temperature if that is a lower value
	var/output_mix_heat_capacity = output_mix.heat_capacity()
	if(!output_mix_heat_capacity)
		return 0
	work_done = min(work_done, (output_mix_heat_capacity * output_mix.temperature - output_mix_heat_capacity * TCMB) / TURBINE_HEAT_CONVERSION_MULTIPLIER)
	output_mix.temperature = max((output_mix.temperature * output_mix_heat_capacity + work_done * TURBINE_HEAT_CONVERSION_MULTIPLIER) / output_mix_heat_capacity, TCMB)
	return work_done

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
			. += emissive_appearance(icon, active_overlay, src)
	else
		. += off_overlay

/obj/machinery/power/turbine/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		balloon_alert(user, "turn it off!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(src, 50)
	toggle_panel_open()
	if(panel_open)
		deactivate_parts(user)
	else
		activate_parts(user)
	balloon_alert(user, "you [panel_open ? "open" : "close"] the maintenance hatch of [src]")
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
	if(!panel_open)
		balloon_alert(user, "panel is closed!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!installed_part)
		balloon_alert(user, "no rotor installed!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(active)
		balloon_alert(user, "[src] is on!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.put_in_hands(installed_part)

	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Allow easy enabling of each machine for connection to the main controller
 */
/obj/machinery/power/turbine/proc/activate_parts(mob/user, check_only = FALSE)
	can_connect = TRUE

/**
 * Allow easy disabling of each machine from the main controller
 */
/obj/machinery/power/turbine/proc/deactivate_parts(mob/user)
	can_connect = FALSE

/obj/machinery/power/turbine/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	set_panel_open(TRUE)
	update_appearance()
	deactivate_parts()
	air_update_turf(TRUE)

/obj/machinery/power/turbine/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == installed_part)
		installed_part = null

/obj/machinery/power/turbine/attackby(obj/item/turbine_parts/object, mob/user, params)
	//not the correct part
	if(!istype(object, part_path))
		return ..()

	//not in a state to accep the part. return TRUE so we don't bash the machine and damage it
	if(active)
		balloon_alert(user, "turn off the machine first!")
		return TRUE
	if(!panel_open)
		balloon_alert(user, "open the maintenance hatch first!")
		return TRUE

	//install the part
	if(!do_after(user, 2 SECONDS, src))
		return
	if(installed_part)
		user.put_in_hands(installed_part)
		balloon_alert(user, "replaced part with the one in hand")
	else
		balloon_alert(user, "installed new part")
	user.transferItemToLoc(object, src)
	installed_part = object

/**
 * Gets the efficiency of the installed part, returns 0 if no part is installed
 */
/obj/machinery/power/turbine/proc/get_efficiency()
	if(installed_part)
		return installed_part.part_efficiency
	return 0

/obj/machinery/power/turbine/inlet_compressor
	name = "inlet compressor"
	desc = "The input side of a turbine generator, contains the compressor."
	icon = 'icons/obj/machines/engine/turbine.dmi'
	icon_state = "inlet_compressor"

	circuit = /obj/item/circuitboard/machine/turbine_compressor

	gas_theoretical_volume = 1000

	part_path = /obj/item/turbine_parts/compressor

	has_gasmix = TRUE

	active_overlay = "inlet_animation"
	off_overlay = "inlet_off"
	open_overlay = "inlet_open"

	/// The rotor this inlet is linked to
	var/obj/machinery/power/turbine/core_rotor/rotor
	/// The turf from which it absorbs gases from
	var/turf/open/input_turf
	/// Work acheived during compression
	var/compressor_work
	/// Pressure of gases absorbed
	var/compressor_pressure
	///Ratio of the amount of gas going in the turbine
	var/intake_regulator = 0.5

/obj/machinery/power/turbine/inlet_compressor/deactivate_parts(mob/user)
	. = ..()
	if(!QDELETED(rotor))
		rotor.deactivate_parts()
	rotor = null
	input_turf = null

/**
 * transfer's gases from it's input turf to it's internal gas mix
 * Returns temperature of the gas mix absorbed only if some work was done
 */
/obj/machinery/power/turbine/inlet_compressor/proc/compress_gases()
	compressor_work = 0
	compressor_pressure = MINIMUM_TURBINE_PRESSURE
	if(QDELETED(input_turf))
		input_turf = get_step(loc, REVERSE_DIR(dir))

	var/datum/gas_mixture/input_turf_mixture = input_turf.return_air()
	if(!input_turf_mixture)
		return 0

	//the compressor compresses down the gases from 2500 L to 1000 L
	//the temperature and pressure rises up, you can regulate this to increase/decrease the amount of gas moved in.
	compressor_work = transfer_gases(input_turf_mixture, machine_gasmix, work_amount_to_remove = 0, intake_size = intake_regulator)
	input_turf.update_visuals()
	input_turf.air_update_turf(TRUE)
	compressor_pressure = PRESSURE_MAX(machine_gasmix.return_pressure())

	return input_turf_mixture.temperature

/obj/machinery/power/turbine/inlet_compressor/constructed
	mapped = FALSE

/obj/machinery/power/turbine/turbine_outlet
	name = "turbine outlet"
	desc = "The output side of a turbine generator, contains the turbine and the stator."
	icon = 'icons/obj/machines/engine/turbine.dmi'
	icon_state = "turbine_outlet"

	circuit = /obj/item/circuitboard/machine/turbine_stator

	gas_theoretical_volume = 6000

	part_path = /obj/item/turbine_parts/stator

	has_gasmix = TRUE

	active_overlay = "outlet_animation"
	off_overlay = "outlet_off"
	open_overlay = "outlet_open"

	/// The rotor this outlet is linked to
	var/obj/machinery/power/turbine/core_rotor/rotor
	/// The turf to puch the gases out into
	var/turf/open/output_turf

/obj/machinery/power/turbine/turbine_outlet/deactivate_parts(mob/user)
	. = ..()
	if(!QDELETED(rotor))
		rotor.deactivate_parts()
	rotor = null
	output_turf = null

/// push gases from its gas mix to output turf
/obj/machinery/power/turbine/turbine_outlet/proc/expel_gases()
	if(QDELETED(output_turf))
		output_turf = get_step(loc, dir)
	//turf is blocked don't eject gases
	if(!TURF_SHARES(output_turf))
		return FALSE

	//eject gases and update turf is any was ejected
	var/datum/gas_mixture/ejected_gases = machine_gasmix.pump_gas_to(output_turf.air, machine_gasmix.return_pressure())
	if(ejected_gases)
		output_turf.update_visuals()
		output_turf.air_update_turf(TRUE)

	//return ejected gases
	return ejected_gases

/obj/machinery/power/turbine/turbine_outlet/constructed
	mapped = FALSE

/obj/machinery/power/turbine/core_rotor
	name = "core rotor"
	desc = "The middle part of a turbine generator, contains the rotor and the main computer."
	icon = 'icons/obj/machines/engine/turbine.dmi'
	icon_state = "core_rotor"
	can_change_cable_layer = TRUE

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

	///Rotation per minute the machine is doing
	var/rpm
	///Amount of power the machine is producing
	var/produced_energy

	///Check to see if all parts are connected to the core
	var/all_parts_connected = FALSE

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

/obj/machinery/power/turbine/core_rotor/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/turbine/core_rotor/examine(mob/user)
	. = ..()
	if(!panel_open)
		. += span_notice("[EXAMINE_HINT("screw")] open its panel to change cable layer.")
	if(!all_parts_connected)
		. += span_warning("The parts need to be linked via a [EXAMINE_HINT("multitool")]")

/obj/machinery/power/turbine/core_rotor/cable_layer_change_checks(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open panel first!")
		return FALSE
	return TRUE

/obj/machinery/power/turbine/core_rotor/multitool_act(mob/living/user, obj/item/tool)
	//allow cable layer changing
	if(panel_open)
		return ..()

	//failed checks
	if(!activate_parts(user))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	//log rotor to link later to computer
	balloon_alert(user, "all parts linked")
	var/obj/item/multitool/multitool = tool
	multitool.buffer = src
	to_chat(user, span_notice("You store linkage information in [tool]'s buffer."))

	//success
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/turbine/core_rotor/multitool_act_secondary(mob/living/user, obj/item/tool)
	//allow cable layer changing
	if(panel_open)
		return ..()

	//works same as regular left click
	return multitool_act(user, tool)

/// convinience proc for balloon alert which returns if viewer is null
/obj/machinery/power/turbine/core_rotor/proc/feedback(mob/viewer, text)
	if(isnull(viewer))
		return
	balloon_alert(viewer, text)

/**
 * Called to activate the complete machine, checks for part presence, correct orientation and installed parts
 * Registers the input/output turfs
 */
/obj/machinery/power/turbine/core_rotor/activate_parts(mob/user, check_only = FALSE)
	//if this is not a checkup and all parts are connected then we have nothing to do
	if(!check_only && all_parts_connected)
		return TRUE

	//locate compressor & turbine, when checking we simply check to see if they are still there
	if(!check_only)
		compressor = locate(/obj/machinery/power/turbine/inlet_compressor) in get_step(src, REVERSE_DIR(dir))
		turbine = locate(/obj/machinery/power/turbine/turbine_outlet) in get_step(src, dir)

		//maybe look for them the other way around. we want the rotor to allign with them either way for player convinience
		if(!compressor && !turbine)
			compressor = locate(/obj/machinery/power/turbine/inlet_compressor) in get_step(src, dir)
			turbine = locate(/obj/machinery/power/turbine/turbine_outlet) in get_step(src, REVERSE_DIR(dir))

	//sanity checks for compressor
	if(QDELETED(compressor))
		feedback(user, "missing compressor!")
		return (all_parts_connected = FALSE)
	if(compressor.dir != dir && compressor.dir != REVERSE_DIR(dir)) //make sure it's not perpendicular to the rotor
		feedback(user, "compressor not aligned with rotor!")
		return (all_parts_connected = FALSE)
	if(!compressor.can_connect)
		feedback(user, "close compressor panel!")
		return (all_parts_connected = FALSE)
	if(!compressor.installed_part)
		feedback(user, "compressor has a missing part!")
		return (all_parts_connected = FALSE)

	//sanity checks for turbine
	if(QDELETED(turbine))
		feedback(user, "missing turbine!")
		return (all_parts_connected = FALSE)
	if(turbine.dir != dir && turbine.dir != REVERSE_DIR(dir))
		feedback(user, "turbine not aligned with rotor!")
		return (all_parts_connected = FALSE)
	if(!turbine.can_connect)
		feedback(user, "turbine panel is either open or is misplaced!") //we say misplaced because can_connect becomes FALSE when this turbine is moved
		return (all_parts_connected = FALSE)
	if(!turbine.installed_part)
		feedback(user, "turbine is missing stator part!")
		return (all_parts_connected = FALSE)

	//final sanity check to make sure turbine & compressor are facing the same direction. From an visual perspective they will appear facing away from each other actually. I know blame spriter's
	if(compressor.dir != turbine.dir)
		feedback(user, "turbine & compressor are not facing away from each other!")
		return (all_parts_connected = FALSE)

	//all checks successfull remember result
	all_parts_connected = TRUE
	if(check_only)
		return TRUE

	compressor.rotor = src
	turbine.rotor = src
	max_allowed_rpm = (compressor.installed_part.max_rpm + turbine.installed_part.max_rpm + installed_part.max_rpm) / 3
	max_allowed_temperature = (compressor.installed_part.max_temperature + turbine.installed_part.max_temperature + installed_part.max_temperature) / 3
	connect_to_network()

	return TRUE

/**
 * Allows to null the various machines and references from the main core
 */
/obj/machinery/power/turbine/core_rotor/deactivate_parts()
	if(all_parts_connected)
		power_off()
	compressor = null
	turbine = null
	all_parts_connected = FALSE
	disconnect_from_network()
	SSair.stop_processing_machine(src)

/obj/machinery/power/turbine/core_rotor/on_deconstruction()
	deactivate_parts()
	return ..()

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
 * It does a minimun check to ensure the parts still exist
 */
/obj/machinery/power/turbine/core_rotor/proc/power_on()
	if(active || QDELETED(compressor) || QDELETED(turbine))
		return
	active = TRUE
	compressor.active = TRUE
	turbine.active = TRUE
	call_parts_update_appearance()
	SSair.start_processing_machine(src)

/**
 * Calls all parts update appearance proc.
 */
/obj/machinery/power/turbine/core_rotor/proc/call_parts_update_appearance()
	update_appearance()
	if(!QDELETED(compressor))
		compressor.update_appearance()
	if(!QDELETED(turbine))
		turbine.update_appearance()

/**
 * Deactivate all three parts, not safe, it assumes the machine already connected and properly working
 * will try to turn off whatever components are left of this machine
 */
/obj/machinery/power/turbine/core_rotor/proc/power_off()
	if(!active)
		return
	active = FALSE
	if(!QDELETED(compressor))
		compressor.active = FALSE
	if(!QDELETED(turbine))
		turbine.active = FALSE
	call_parts_update_appearance()
	SSair.stop_processing_machine(src)

/**
 * Returns true if all parts have their panel closed
 */
/obj/machinery/power/turbine/core_rotor/proc/all_parts_ready()
	if(QDELETED(compressor))
		return FALSE
	if(QDELETED(turbine))
		return FALSE
	return !panel_open && !compressor.panel_open && !turbine.panel_open

/**
 * Getter for turbine integrity, return the amount in %
 */
/obj/machinery/power/turbine/core_rotor/proc/get_turbine_integrity()
	var/integrity = damage / 500
	integrity = max(round(100 - integrity * 100, 0.01), 0)
	return integrity

/obj/machinery/power/turbine/core_rotor/process_atmos()
	if(!active || !activate_parts(check_only = TRUE))
		power_off()
		return PROCESS_KILL

	//===============COMPRESSOR WORKING========//
	//Transfer gases from turf to compressor
	var/temperature = compressor.compress_gases()
	//Compute damage taken based on temperature
	damage_archived = damage
	var/temperature_difference = temperature - max_allowed_temperature
	var/damage_done = round(log(90, max(temperature_difference, 1)), 0.5)
	damage = max(damage + damage_done * 0.5, 0)
	damage = min(damage_archived + TURBINE_MAX_TAKEN_DAMAGE, damage)
	if(temperature_difference < 0)
		damage = max(damage - TURBINE_DAMAGE_HEALING, 0)
	//Apply damage if it passes threshold limits
	if((damage - damage_archived >= 2 || damage > TURBINE_DAMAGE_ALARM_START) && COOLDOWN_FINISHED(src, turbine_damage_alert))
		COOLDOWN_START(src, turbine_damage_alert, max(round(TURBINE_DAMAGE_ALARM_START - damage_done), 5) SECONDS)
		//Boom!
		var/integrity = get_turbine_integrity()
		if(integrity <= 0)
			deactivate_parts()
			if(rpm < 35000)
				explosion(src, 0, 1, 4)
				return PROCESS_KILL
			if(rpm < 87500)
				explosion(src, 0, 2, 6)
				return PROCESS_KILL
			if(rpm < 220000)
				explosion(src, 1, 3, 7)
				return PROCESS_KILL
			if(rpm < 550000)
				explosion(src, 2, 5, 7)
			return PROCESS_KILL
		radio.talk_into(src, "Warning, turbine at [get_area_name(src)] taking damage, current integrity at [integrity]%!", engineering_channel)
		playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)

	//================ROTOR WORKING============//
	//The Rotor moves the gases that expands from 1000 L to 3000 L, they cool down and both temperature and pressure lowers
	var/rotor_work = transfer_gases(compressor.machine_gasmix, machine_gasmix, compressor.compressor_work)
	//the turbine expands the gases more from 3000 L to 6000 L, cooling them down further.
	var/turbine_work = transfer_gases(machine_gasmix, turbine.machine_gasmix, abs(rotor_work))

	//================TURBINE WORKING============//
	//Calculate final power generated based on how much gas was ejected from the turbine
	var/datum/gas_mixture/ejected_gases = turbine.expel_gases()
	if(!ejected_gases) //output turf was blocked with high pressure/temperature gases or by some structure so no power generated
		rpm = 0
		produced_energy = 0
		return
	var/work_done =  QUANTIZE(ejected_gases.total_moles()) * R_IDEAL_GAS_EQUATION * ejected_gases.temperature * log(compressor.compressor_pressure / PRESSURE_MAX(ejected_gases.return_pressure()))
	//removing the work needed to move the compressor but adding back the turbine work that is the one generating most of the power.
	work_done = max(work_done - compressor.compressor_work * TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER - turbine_work, 0)
	//calculate final acheived rpm
	rpm = ((work_done * compressor.get_efficiency()) ** turbine.get_efficiency()) * get_efficiency() / TURBINE_RPM_CONVERSION
	rpm = FLOOR(min(rpm, max_allowed_rpm), 1)
	//add energy into the grid
	produced_energy = rpm * TURBINE_ENERGY_RECTIFICATION_MULTIPLIER * TURBINE_RPM_CONVERSION
	add_avail(produced_energy)

/obj/item/paper/guides/jobs/atmos/turbine
	name = "paper- 'Quick guide on the new and improved turbine!'"
	default_raw_text = "<B>How to operate the turbine</B><BR>\
	-The new turbine is not much different from the old one, just put gases in the chamber, light them up and activate the machine from the nearby computer.\
	-There is a new parameter that's visible within the turbine computer's UI, damage. The turbine will be damaged when the heat gets too high, according to the tiers of the parts used. Make sure it doesn't get too hot!<BR>\
	-You can avoid the turbine critically failing by upgrading the parts of the machine, but not with stock parts as you might be used to. There are 3 all-new parts, one for each section of the turbine.<BR>\
	-These items are: the compressor part, the rotor part and the stator part. All of them can be printed in any engi lathes (both proto and auto).<BR>\
	-There are 4 tiers for these items, only the first tier can be printed. The next tier of each part can be made by using various materials on the part (clicking with the material in hand, on the part). The material required to reach the next tier is stated in the part's examine text, try shift clicking it!<BR>\
	-Each tier increases the efficiency (more power), the max reachable RPM, and the max temperature that the machine can process without taking damage (up to fusion temperatures at the last tier!).<BR>\
	-A word of warning, the machine is very inefficient in its gas consumption and many unburnt gases will pass through. If you want to be cheap you can either pre-burn the gases or add a filtering system to collect the unburnt gases and reuse them."

#undef PRESSURE_MAX
#undef MINIMUM_TURBINE_PRESSURE
