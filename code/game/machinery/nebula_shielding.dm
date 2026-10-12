///Machinery that block nebulas. This type is for convenience, you can set nebula shielding on other objects as well using add_to_nebula_shielding()
/obj/machinery/nebula_shielding
	density = TRUE

	icon = 'icons/obj/machines/nebula_shielding.dmi'
	pixel_x = -16

	layer = NOT_HIGH_OBJ_LAYER
	use_power = IDLE_POWER_USE // power draw is manually handled
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

	///Strength of the shield we apply
	var/shielding_strength
	///The type of nebula that we shield against
	var/nebula_type

/obj/machinery/nebula_shielding/Initialize(mapload)
	. = ..()
	add_to_nebula_shielding(src, nebula_type, PROC_REF(get_nebula_shielding))

///Nebula is asking us how strong we are. Return our shield strength is all is well
/obj/machinery/nebula_shielding/proc/get_nebula_shielding(seconds_per_tick)
	if(!is_operational)
		if(use_power != NO_POWER_USE)
			update_use_power(IDLE_POWER_USE)
		return 0

	generate_reward(seconds_per_tick)
	if(use_power != NO_POWER_USE)
		update_use_power(ACTIVE_POWER_USE)
	return shielding_strength

///Generate a resource for defending against the nebula
/obj/machinery/nebula_shielding/proc/generate_reward(seconds_per_tick)
	return

/obj/machinery/nebula_shielding/on_set_is_operational(old_value)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/nebula_shielding/update_icon_state()
	. = ..()

	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
	else if(machine_stat & MAINT)
		icon_state = "[base_icon_state]_open"
	else if(machine_stat & NOPOWER)
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]_on"

///We shield against the radioactive nebula and passively generate tritium
/obj/machinery/nebula_shielding/radiation
	name = "radioactive nebula shielder"
	desc = "Generates a field around the station, protecting it from a radioactive nebula."

	icon_state = "radioactive_shielding"
	base_icon_state = "radioactive_shielding"

	circuit = /obj/item/circuitboard/machine/radioactive_nebula_shielding

	nebula_type = /datum/station_trait/nebula/hostile/radiation
	shielding_strength = 4

	integrity_failure = 0.4

	/// Our internal gas output pipe
	var/datum/gas_machine_connector/tritium_output
	/// Max amount pressure before excess trit is vented
	var/max_pressure = 10 * ONE_ATMOSPHERE
	/// Volume of the output pipe
	var/internal_volume = CELL_VOLUME * 0.5

/obj/machinery/nebula_shielding/radiation/Initialize(mapload)
	. = ..()
	tritium_output = new(src, internal_volume)

/obj/machinery/nebula_shielding/radiation/Destroy()
	QDEL_NULL(tritium_output)
	return ..()

/obj/machinery/nebula_shielding/radiation/on_deconstruction(disassembled)
	. = ..()
	// dump all our stinky stuff out when deconstructed
	loc.assume_air(tritium_output.gas_connector.airs[1])

/obj/machinery/nebula_shielding/radiation/examine(mob/user)
	. = ..()
	. += span_notice("Passively generates tritium. Provides [shielding_strength] levels of nebula shielding when active.")

/obj/machinery/nebula_shielding/radiation/generate_reward(seconds_per_tick)
	var/datum/gas_mixture/output_air = tritium_output.gas_connector.airs[1]
	// heat up a tiny bit, radiation is hot right? (tritium won't burn out oxygen anyways)
	output_air.temperature = output_air.total_moles() <= MINIMUM_MOLE_COUNT ? T20C : max(TCMB, output_air.temperature + (1 * seconds_per_tick))
	// adds 0.5 mol of tritium per second to the output port
	var/datum/gas_mixture/excess_tritium = output_air.add_gas_up_to_pressure(/datum/gas/tritium, 0.5 * seconds_per_tick, max_pressure)
	tritium_output.gas_connector.update_parents()
	// any excess tritium is dumped into the air
	loc.assume_air(excess_tritium)

/obj/machinery/nebula_shielding/radiation/return_analyzable_air()
	return tritium_output.gas_connector.airs[1]

/obj/machinery/nebula_shielding/radiation/on_set_panel_open(old_value)
	. = ..()
	if(panel_open)
		set_machine_stat(machine_stat | MAINT)
	else
		set_machine_stat(machine_stat & ~MAINT)

/obj/machinery/nebula_shielding/radiation/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, tool)

/obj/machinery/nebula_shielding/radiation/crowbar_act(mob/living/user, obj/item/tool)
	if(!can_crowbar_deconstruct())
		return ITEM_INTERACT_BLOCKING

	var/inside_pressure = tritium_output.gas_connector.airs[1].return_pressure()
	var/outside_pressure = loc.return_air()?.return_pressure() || 0
	var/pressure_difference = inside_pressure - outside_pressure

	var/unsafe_release = FALSE
	if(pressure_difference > 2 * ONE_ATMOSPHERE)
		to_chat(user, span_warning("As you begin prying [src] apart, you hear the hiss of gas escaping... maybe you should reconsider?"))
		unsafe_release = TRUE

	if(!tool.use_tool(src, user, (unsafe_release ? 4 SECONDS : 1 SECONDS), volume = 50))
		return ITEM_INTERACT_BLOCKING

	if(unsafe_release)
		tritium_output.gas_connector.unsafe_pressure_release(user, pressure_difference)

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

///Emergency shielding so people aren't permanently in a radstorm if shit goes very wrong in engineering
/obj/machinery/nebula_shielding/radiation/emergency
	name = "emergency nebula radiation shielder"
	desc = "Generates a field around the station to protect it from a radioactive nebula."

	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "portgen1_1"
	pixel_x = 0
	density = TRUE
	anchored = FALSE //so some handsome rogue could potentially move it off the station z-level
	shielding_strength = 999 //should block the nebula completely
	use_power = NO_POWER_USE

	nebula_type = /datum/station_trait/nebula/hostile/radiation

	internal_volume = parent_type::internal_volume * 0.3

	///How long we work untill we self-destruct
	var/detonate_in = 10 MINUTES

/obj/machinery/nebula_shielding/radiation/emergency/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), detonate_in, TIMER_DELETE_ME)

/obj/machinery/nebula_shielding/radiation/emergency/examine(mob/user)
	. = ..()

	. += span_notice("[p_They()] will last [DisplayTimeText(detonate_in)] before overloading.")

///We don't live for very long, so self-destruct
/obj/machinery/nebula_shielding/radiation/emergency/proc/self_destruct()
	deconstruct(FALSE)
	do_sparks(5, FALSE, src) // spawns some sparks to light any tritium we just dumped out on fire immediately
	explosion(src, light_impact_range = 5, flame_range = 3, explosion_cause = src)

/// Small explanation for engineering on how to set-up the radioactive nebula shielding
/obj/item/paper/fluff/radiation_nebula
	name = "radioactive nebula shielding"
	default_raw_text = {"EXTREME IMPORTANCE!!!! <br>
		Set up these radioactive nebula shielding units before the gravity generator's native shielding is overwhelmed! <br>
		Shielding units passively generate tritium, so make sure to properly ventilate/isolate the area before setting up a shielding unit!
		More circuit boards can be ordered through cargo. Consider setting up auxiliary shielding units in-case of destruction, power loss or sabotage.
	"}

/// Warns medical that they can't use radioactive resonance
/obj/item/paper/fluff/radiation_nebula_virologist
	name = "radioactive resonance"
	default_raw_text = {"EXTREME IMPORTANCE!!!! <br>
		During routine blood screening on employees working within the nebula, we have found no traces of the symptom called 'Radioactive Resonance'. <br>
		Something inside the nebula is interfering with it; be wary of a more shallow viral genepool.
	"}
