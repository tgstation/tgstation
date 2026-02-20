/datum/manufacturing_gas_recipe
	/// is plasma gas needed
	var/plasma_required = TRUE
	/// sheet type required
	var/required_material
	/// gas id that we produce
	var/produced_gas_id
	/// produced mols
	var/produced_mols = 25 // 150 sheets -> 3750 mols (canister: 3743)

/datum/manufacturing_gas_recipe/plasma
	plasma_required = FALSE
	required_material = /obj/item/stack/sheet/mineral/plasma
	produced_gas_id = GAS_PLASMA

/datum/manufacturing_gas_recipe/oxygen
	required_material = /obj/item/stack/sheet/glass
	produced_gas_id = GAS_O2

/datum/manufacturing_gas_recipe/nitrogen
	required_material = /obj/item/stack/sheet/mineral/titanium
	produced_gas_id = GAS_N2

/datum/manufacturing_gas_recipe/co2
	required_material = /obj/item/stack/sheet/iron
	produced_gas_id = GAS_CO2
	produced_mols = 15

/datum/manufacturing_gas_recipe/tritium //150 sheets of uranium for 750 mol of trit
	required_material = /obj/item/stack/sheet/mineral/uranium
	produced_gas_id = GAS_TRITIUM
	produced_mols = 5

/obj/machinery/power/manufacturing/gasrefinery
	name = "manufacturing gas refinery"
	desc = "Turns ore into gas with the help of piped plasma. Emits said created gas into the air at a high temperature. Build preferably in an airless room. Requires power via wire."
	icon_state = "gasrefinery"
	base_icon_state = "gasrefinery"
	circuit = /obj/item/circuitboard/machine/manurefinery
	may_be_moved = FALSE // gas machine connector is the most jank shit ever
	/// power used to make gas
	var/power_cost = 4 KILO WATTS
	/// our atmos connector
	var/datum/gas_machine_connector/internal_connector
	/// all known recipes
	var/static/list/datum/manufacturing_gas_recipe/recipes = subtypesof(/datum/manufacturing_gas_recipe)
	/// last failure reason we display in description
	var/last_failure_reason
	/// typepath of current recipe
	var/datum/manufacturing_gas_recipe/current_recipe = /datum/manufacturing_gas_recipe/plasma
	/// max pressure (in kPa) on our tile before we are unable to output gas
	var/max_output_pressure = 500
	// upgrade related stuff
	/// plasma mols needed and used for producing gas with 1 sheet (should be higher than the plasma recipe on T1)
	var/plasma_mols_needed = 15 // T4: 7.5 (plasma recipe right now is 10 mols output)
	/// stacks used every process
	var/stacks_used_per_process = 1 // T4: 5
	/// output mol multiplier from upgrades
	var/output_mult = 1 // T4: 1.6

/obj/machinery/power/manufacturing/gasrefinery/Initialize(mapload)
	. = ..()
	internal_connector = new(loc, src, dir, CELL_VOLUME) //this is the jankiest least functional shit ever and i do not have the knowhow to refactor gas machine connectors

/obj/machinery/power/manufacturing/gasrefinery/Destroy()
	QDEL_NULL(internal_connector)
	return ..()

/obj/machinery/power/manufacturing/gasrefinery/examine(mob/user)
	. = ..()
	. += span_notice("Power needed to process sheets: <b>[display_power(power_cost, convert = FALSE)]</b>.")
	. += span_notice("Maximum external pressure: <b>[max_output_pressure]kPa</b>.")
	. += span_notice("With the current parts;")
	. += span_notice("- Piped mols needed for a recipe: <b>[plasma_mols_needed] mol</b>.")
	. += span_notice("- Sheet count processed at once: <b>[stacks_used_per_process]</b>.")
	. += span_notice("- Recipe efficiency (output multiplier): <b>[output_mult*100]%</b>.")

/obj/machinery/power/manufacturing/gasrefinery/RefreshParts()
	. = ..()
	plasma_mols_needed = initial(plasma_mols_needed)
	var/datum/stock_part/servo/servo = locate() in component_parts
	plasma_mols_needed -= (servo.tier-1) * 2.5
	var/datum/stock_part/matter_bin/bin = locate() in component_parts
	stacks_used_per_process = initial(stacks_used_per_process) + (bin.tier-1)
	var/datum/stock_part/micro_laser/laser = locate() in component_parts
	output_mult = 1 + (laser.tier-1) * 0.2

/obj/machinery/power/manufacturing/gasrefinery/update_overlays()
	. = ..()
	. += generate_io_overlays(REVERSE_DIR(dir), COLOR_MODERATE_BLUE)
	if(surplus() >= power_cost)
		. += "[base_icon_state]_conveyoron"

/obj/machinery/power/manufacturing/gasrefinery/receive_resource(obj/receiving, atom/from, receive_dir)
	if(!istype(receiving, initial(current_recipe.required_material)) || surplus() < power_cost  || receive_dir != REVERSE_DIR(dir))
		return MANUFACTURING_FAIL
	var/list/stacks = contents - circuit
	if(length(stacks) >= 1)
		try_merge_stack_in_contents(receiving)
		return MANUFACTURING_FAIL
	receiving.Move(src, get_dir(receiving, src))
	START_PROCESSING(SSmanufacturing, src)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/gasrefinery/atom_destruction(damage_flag)
	dump_inventory_contents()
	return ..()

/obj/machinery/power/manufacturing/gasrefinery/process(seconds_per_tick)
	var/list/contents_circuitless = contents - circuit
	var/turf/open/our_turf = get_turf(src)
	if(!length(contents_circuitless) || !anchored)
		return PROCESS_KILL
	if(!istype(our_turf) || isspaceturf(our_turf) || our_turf.planetary_atmos)
		last_failure_reason = "BAD PLACEMENT"
		return

	var/obj/item/stack/sheet/sheet = contents_circuitless[1]
	if(!istype(sheet, initial(current_recipe.required_material)))
		sheet.Move(loc)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)
		return
	if(surplus() < power_cost)
		last_failure_reason = "NO POWER"
		return
	if(our_turf.return_air().return_pressure() > max_output_pressure)
		last_failure_reason = "EXTERNAL OVERPRESSURE"
		return

	var/used_amount = min(stacks_used_per_process, sheet.amount)
	var/datum/gas_mixture/port = internal_connector.gas_connector.airs[1]
	if(initial(current_recipe.plasma_required))
		if(!port.has_gas(/datum/gas/plasma, amount=plasma_mols_needed*used_amount))
			last_failure_reason = "NOT ENOUGH PLASMA GAS"
			return
		port.remove_specific(/datum/gas/plasma, plasma_mols_needed*used_amount)
	add_load(power_cost)
	var/spawned_gas = gas_id2path(initial(current_recipe.produced_gas_id))
	sheet.use(used_amount)
	var/datum/gas_mixture/merger = new
	merger.assert_gas(spawned_gas)
	merger.gases[spawned_gas][MOLES] = initial(current_recipe.produced_mols) * output_mult * used_amount * seconds_per_tick
	merger.temperature = 1750
	our_turf.assume_air(merger)
	last_failure_reason = null
	flick_overlay_view("[base_icon_state]_refine", 1 SECONDS)
	if(!length(contents_circuitless))
		return PROCESS_KILL //we finished

/obj/machinery/power/manufacturing/gasrefinery/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Manufgasrefinery", name)
		ui.open()

/obj/machinery/power/manufacturing/gasrefinery/ui_data(mob/user)
	. = list()
	.["plasma_mols_needed"] = plasma_mols_needed
	.["last_failure_reason"] = last_failure_reason
	var/obj/recipe_material_typepath = initial(current_recipe.required_material)
	.["recipe"] = list(
		plasma_required = initial(current_recipe.plasma_required),
		required_material = uppertext(initial(recipe_material_typepath.name)),
		produced_gas_id = uppertext(initial(current_recipe.produced_gas_id)),
		produced_mols = initial(current_recipe.produced_mols),
	)

/obj/machinery/power/manufacturing/gasrefinery/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	playsound(src, 'sound/machines/terminal/terminal_button07.ogg', 45, TRUE)
	switch(action)
		if("change_sel")
			var/adjustment = text2num(params["adjustment"])
			if(isnull(adjustment))
				return
			current_recipe = recipes[WRAP(recipes.Find(current_recipe)+adjustment, 1, length(recipes)+1)]
			dump_inventory_contents()
			return TRUE
