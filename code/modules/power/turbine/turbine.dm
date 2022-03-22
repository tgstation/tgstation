///Multiplier for converting work done into rpm and rpm in energy out
#define TURBINE_RPM_CONVERSION 15
///Efficiency of the turbine to turn work into energy, higher values will yield more power
#define TURBINE_ENERGY_RECTIFICATION_MULTIPLIER 0.25
///Max allowed damage per tick
#define TURBINE_MAX_TAKEN_DAMAGE 10
///Amount of damage healed when under the heat threshold
#define TURBINE_DAMAGE_HEALING 2
///Amount of damage that the machine must have to start launching alarms to the engi comms
#define TURBINE_DAMAGE_ALARM_START 30
///Multiplier when converting the gas energy into gas work
#define TURBINE_WORK_CONVERSION_MULTIPLIER 0.01
///Multiplier when converting gas work back into heat
#define TURBINE_HEAT_CONVERSION_MULTIPLIER 0.005
///Amount of energy removed from the work done by the stator due to the consumption from the compressor working on the gases
#define TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER 0.15

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

	///Overlay for panel_open
	var/open_overlay //#TODO: get the overlay done
	///Overlay for machine activation
	var/on_overlay //#TODO: get the overlay done

	///Reference to our turbine part
	var/obj/item/turbine_parts/installed_part
	///Path of the turbine part we can install
	var/part_path

/obj/machinery/power/turbine/Initialize(mapload)
	. = ..()

	if(part_path)
		installed_part = new part_path(src)

	var/turf/our_turf = get_turf(src)
	if(our_turf.thermal_conductivity != 0 && isopenturf(our_turf))
		our_turf_thermal_conductivity = our_turf.thermal_conductivity
		our_turf.thermal_conductivity = 0

/obj/machinery/power/turbine/Destroy()
	var/turf/our_turf = get_turf(src)
	if(our_turf.thermal_conductivity == 0 && isopenturf(our_turf))
		our_turf.thermal_conductivity = our_turf_thermal_conductivity

	if(installed_part)
		QDEL_NULL(installed_part)

	return ..()

/obj/machinery/power/turbine/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		to_chat(user, "You can't open [src] while it's on!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!anchored)
		to_chat(user, span_notice("Anchor [src] first!"))
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

/obj/machinery/power/turbine/update_overlays()
	. = ..()
	if(panel_open)
		. += open_overlay
	if(active)
		. += on_overlay

/obj/machinery/power/turbine/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/power/turbine/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/turbine/proc/enable_parts(mob/user)
	can_connect = TRUE

/obj/machinery/power/turbine/proc/disable_parts(mob/user)
	can_connect = FALSE

/obj/machinery/power/turbine/Moved(atom/OldLoc, Dir)
	. = ..()
	var/turf/old_turf = get_turf(OldLoc)
	old_turf.thermal_conductivity = our_turf_thermal_conductivity
	var/turf/new_turf = get_turf(src)
	if(new_turf)
		our_turf_thermal_conductivity = new_turf.thermal_conductivity
		new_turf.thermal_conductivity = 0

/obj/machinery/power/turbine/inlet_compressor
	name = "inlet compressor"
	desc = "The input side of a turbine generator, contains the compressor."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "inlet_compressor"

	gas_theoretical_volume = 1000

	part_path = /obj/item/turbine_parts/compressor

	///Reference to the core part
	var/obj/machinery/power/turbine/core_rotor/core

/obj/machinery/power/turbine/inlet_compressor/Destroy()
	if(core)
		core = null
	return ..()

/obj/machinery/power/turbine/inlet_compressor/attackby(obj/item/object, mob/user, params)
	if(!panel_open)
		balloon_alert(user, "open the maintenance hatch first")
		return ..()

	if(!istype(object, part_path))
		return ..()
	var/obj/item/turbine_parts/compressor/compressor_part = object
	if(!installed_part)
		user.transferItemToLoc(compressor_part, src)
		installed_part = compressor_part
		if(core)
			core.calculate_parts_limits()
		balloon_alert(user, "installed new part")
		return
	if(installed_part.part_efficiency < compressor_part.part_efficiency)
		user.transferItemToLoc(compressor_part, src)
		user.put_in_hands(installed_part)
		installed_part = compressor_part
		if(core)
			core.calculate_parts_limits()
		balloon_alert(user, "replaced part with a better one")
		return

	balloon_alert(user, "already installed")
	return

/obj/machinery/power/turbine/turbine_outlet
	name = "turbine outlet"
	desc = "The output side of a turbine generator, contains the turbine and the stator."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "turbine_outlet"

	gas_theoretical_volume = 6000

	part_path = /obj/item/turbine_parts/stator

	///Reference to the core part
	var/obj/machinery/power/turbine/core_rotor/core

/obj/machinery/power/turbine/turbine_outlet/Destroy()
	if(core)
		core = null
	return ..()

/obj/machinery/power/turbine/turbine_outlet/attackby(obj/item/object, mob/user, params)
	if(!panel_open)
		balloon_alert(user, "open the maintenance hatch first")
		return ..()

	if(!istype(object, part_path))
		return ..()
	var/obj/item/turbine_parts/stator/stator_part = object
	if(!installed_part)
		user.transferItemToLoc(stator_part, src)
		installed_part = stator_part
		if(core)
			core.calculate_parts_limits()
		balloon_alert(user, "installed new part")
		return
	if(installed_part.part_efficiency < stator_part.part_efficiency)
		user.transferItemToLoc(stator_part, src)
		user.put_in_hands(installed_part)
		installed_part = stator_part
		if(core)
			core.calculate_parts_limits()
		balloon_alert(user, "replaced part with a better one")
		return

	balloon_alert(user, "already installed")
	return

/obj/machinery/power/turbine/core_rotor
	name = "core rotor"
	desc = "The middle part of a turbine generator, contains the rotor and the main computer."
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "core_rotor"

	gas_theoretical_volume = 3000

	part_path = /obj/item/turbine_parts/rotor

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

	///Efficiency of the part installed in the compressor (from 0.25 to 0.85)
	var/compressor_part_efficiency = 0.25
	///Efficiency of the part installed in the rotor (from 0.25 to 0.85)
	var/rotor_part_efficiency = 0.25
	///Efficiency of the part installed in the turbine (from 0.85 to 0.895) - don't go higher than that, it can cause #nan errors
	var/stator_part_efficiency = 0.85

	///Rotation per minute the machine is doing
	var/rpm
	///Amount of power the machine is producing
	var/produced_energy

	///First stage of the moving gasmix - compression from 2500 L to 1000 L - heat up
	var/datum/gas_mixture/compressor_mixture
	///Second stage of the moving gasmix - expansion from 1000 L to 3000 L - first cool down
	var/datum/gas_mixture/rotor_mixture
	///Third stage of the moving gasmix - expansion from 3000 L to 6000 L - second cool down
	var/datum/gas_mixture/turbine_mixture

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

	COOLDOWN_DECLARE(turbine_damage_alert)

/obj/machinery/power/turbine/core_rotor/LateInitialize()
	. = ..()
	activate_parts()

/obj/machinery/power/turbine/core_rotor/Destroy(mob/user)
	deactivate_parts(user)
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

/obj/machinery/power/turbine/core_rotor/proc/activate_parts(mob/user)

	compressor = locate(/obj/machinery/power/turbine/inlet_compressor) in get_step(src, turn(dir, 180))
	turbine = locate(/obj/machinery/power/turbine/turbine_outlet) in get_step(src, dir)

	if(!compressor || !turbine)
		if(user)
			balloon_alert(user, "missing parts detected")
		return FALSE
	if(compressor.dir != dir || !compressor.can_connect)
		if(user)
			balloon_alert(user, "wrong compressor direction")
		return FALSE
	if(turbine.dir != dir || !turbine.can_connect)
		if(user)
			balloon_alert(user, "wrong turbine direction")
		return FALSE

	compressor.core = src
	turbine.core = src

	input_turf = get_step(compressor.loc, turn(dir, 180))
	output_turf = get_step(turbine.loc, dir)

	compressor_mixture = new
	rotor_mixture = new
	turbine_mixture = new
	compressor_mixture.volume = compressor.gas_theoretical_volume
	rotor_mixture.volume = gas_theoretical_volume
	turbine_mixture.volume = turbine.gas_theoretical_volume

	compressor_part_efficiency = compressor.installed_part.part_efficiency
	stator_part_efficiency = turbine.installed_part.part_efficiency
	rotor_part_efficiency = installed_part.part_efficiency

	all_parts_connected = TRUE

	calculate_parts_limits()

	SSair.start_processing_machine(src)
	return TRUE

/obj/machinery/power/turbine/core_rotor/proc/deactivate_parts()
	compressor?.core = null
	turbine?.core = null
	compressor = null
	turbine = null
	input_turf = null
	output_turf = null
	compressor_mixture = null
	rotor_mixture = null
	turbine_mixture = null
	all_parts_connected = FALSE
	SSair.stop_processing_machine(src)

/obj/machinery/power/turbine/core_rotor/attackby(obj/item/object, mob/user, params)
	if(!panel_open)
		balloon_alert(user, "open the maintenance hatch first")
		return ..()
	if(all_parts_connected)
		if(istype(object, compressor.part_path))
			var/obj/item/turbine_parts/compressor/compressor_part = object
			if(!compressor.installed_part)
				user.transferItemToLoc(compressor_part, src)
				compressor.installed_part = compressor_part
				compressor_part_efficiency = compressor_part.part_efficiency
				calculate_parts_limits()
				balloon_alert(user, "installed new part")
				return
			if(compressor.installed_part.part_efficiency < compressor_part.part_efficiency)
				user.transferItemToLoc(compressor_part, src)
				user.put_in_hands(compressor.installed_part)
				compressor.installed_part = compressor_part
				compressor_part_efficiency = compressor_part.part_efficiency
				calculate_parts_limits()
				balloon_alert(user, "replaced part with a better one")
				return

			balloon_alert(user, "already installed")
			return

		if(istype(object, turbine.part_path))
			var/obj/item/turbine_parts/stator/stator_part = object
			if(!turbine.installed_part)
				user.transferItemToLoc(stator_part, src)
				turbine.installed_part = stator_part
				stator_part_efficiency = stator_part.part_efficiency
				calculate_parts_limits()
				balloon_alert(user, "installed new part")
				return
			if(turbine.installed_part.part_efficiency < stator_part.part_efficiency)
				user.transferItemToLoc(stator_part, src)
				user.put_in_hands(turbine.installed_part)
				turbine.installed_part = stator_part
				stator_part_efficiency = stator_part.part_efficiency
				calculate_parts_limits()
				balloon_alert(user, "replaced part with a better one")
				return

			balloon_alert(user, "already installed")
			return

	if(istype(object, part_path))
		var/obj/item/turbine_parts/rotor/rotor_part = object
		if(!installed_part)
			user.transferItemToLoc(rotor_part, src)
			installed_part = rotor_part
			rotor_part_efficiency = rotor_part.part_efficiency
			calculate_parts_limits()
			balloon_alert(user, "installed new part")
			return
		if(installed_part.part_efficiency < rotor_part.part_efficiency)
			user.transferItemToLoc(rotor_part, src)
			user.put_in_hands(installed_part)
			installed_part = rotor_part
			rotor_part_efficiency = rotor_part.part_efficiency
			calculate_parts_limits()
			balloon_alert(user, "replaced part with a better one")
			return

		balloon_alert(user, "already installed")

	return ..()

/obj/machinery/power/turbine/core_rotor/on_deconstruction()
	if(all_parts_connected)
		deactivate_parts()
	return ..()

/obj/machinery/power/turbine/core_rotor/proc/calculate_parts_limits()
	compressor_part_efficiency = compressor.installed_part.part_efficiency
	stator_part_efficiency = turbine.installed_part.part_efficiency
	rotor_part_efficiency = installed_part.part_efficiency

	max_allowed_rpm = (compressor.installed_part.max_rpm + turbine.installed_part.max_rpm + installed_part.max_rpm) / 3
	max_allowed_temperature = (compressor.installed_part.max_temperature + turbine.installed_part.max_temperature + installed_part.max_temperature) / 3

/obj/machinery/power/turbine/core_rotor/proc/calculate_damage_done(temperature)
	damage_archived = damage
	var/temperature_difference = temperature - max_allowed_temperature
	var/damage_done = round(log(90, max(temperature_difference, 1)), 0.5)

	damage = max(damage + damage_done * 0.5, 0)
	damage = min(damage_archived + TURBINE_MAX_TAKEN_DAMAGE, damage)
	if(temperature_difference < 0)
		damage = max(damage - TURBINE_DAMAGE_HEALING, 0)

	if((damage - damage_archived >= 2 || damage > TURBINE_DAMAGE_ALARM_START) && COOLDOWN_FINISHED(src, turbine_damage_alert))
		call_alert(damage_done)

/obj/machinery/power/turbine/core_rotor/proc/call_alert(damage_done)
	COOLDOWN_START(src, turbine_damage_alert, max(round(TURBINE_DAMAGE_ALARM_START - damage_done), 5) SECONDS)
	message_admins("AHHH YOU KILLING MEEEEE!!!11!!11!!!1111!!") //#TODO finish alert

/obj/machinery/power/turbine/core_rotor/process_atmos()

	if(!active)
		return

	var/datum/gas_mixture/input_turf_mixture = input_turf.air

	if(!input_turf_mixture || !input_turf_mixture.gases)
		return

	calculate_damage_done(input_turf_mixture.temperature)

	var/compressor_work = input_turf_mixture.total_moles() * R_IDEAL_GAS_EQUATION * input_turf_mixture.temperature * log(input_turf_mixture.volume / compressor_mixture.volume) * TURBINE_WORK_CONVERSION_MULTIPLIER
	input_turf.air.pump_gas_to(compressor_mixture, input_turf.air.return_pressure())
	input_turf.air_update_turf(TRUE)
	compressor_mixture.temperature = max((compressor_mixture.temperature * compressor_mixture.heat_capacity() + compressor_work * compressor_mixture.total_moles() * TURBINE_HEAT_CONVERSION_MULTIPLIER) / compressor_mixture.heat_capacity(), TCMB)

	var/compressor_pressure = compressor_mixture.return_pressure()

	var/rotor_work = compressor_mixture.total_moles() * R_IDEAL_GAS_EQUATION * compressor_mixture.temperature * log(compressor_mixture.volume / rotor_mixture.volume) * TURBINE_WORK_CONVERSION_MULTIPLIER
	rotor_work = rotor_work - compressor_work
	compressor_mixture.pump_gas_to(rotor_mixture, compressor_mixture.return_pressure())
	rotor_mixture.temperature = max((rotor_mixture.temperature * rotor_mixture.heat_capacity() + rotor_work * rotor_mixture.total_moles() * TURBINE_HEAT_CONVERSION_MULTIPLIER) / rotor_mixture.heat_capacity(), TCMB)

	var/turbine_work = rotor_mixture.total_moles() * R_IDEAL_GAS_EQUATION * rotor_mixture.temperature * log(rotor_mixture.volume / turbine_mixture.volume) * TURBINE_WORK_CONVERSION_MULTIPLIER
	turbine_work = turbine_work - abs(rotor_work)
	rotor_mixture.pump_gas_to(turbine_mixture, rotor_mixture.return_pressure())
	turbine_mixture.temperature = max((turbine_mixture.temperature * turbine_mixture.heat_capacity() + turbine_work * turbine_mixture.total_moles() * TURBINE_HEAT_CONVERSION_MULTIPLIER) / turbine_mixture.heat_capacity(), TCMB)

	var/turbine_pressure = turbine_mixture.return_pressure()

	var/work_done = turbine_mixture.total_moles() * R_IDEAL_GAS_EQUATION * turbine_mixture.temperature * log(compressor_pressure / turbine_pressure)

	work_done = max(work_done - compressor_work * TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER - turbine_work, 0)

	rpm = ((work_done * compressor_part_efficiency) ** stator_part_efficiency) * rotor_part_efficiency / TURBINE_RPM_CONVERSION
	rpm = min(rpm, max_allowed_rpm)

	produced_energy = rpm * TURBINE_ENERGY_RECTIFICATION_MULTIPLIER * TURBINE_RPM_CONVERSION

	add_avail(produced_energy)

	turbine_mixture.pump_gas_to(output_turf.air, turbine_mixture.return_pressure())
	output_turf.air_update_turf(TRUE)
