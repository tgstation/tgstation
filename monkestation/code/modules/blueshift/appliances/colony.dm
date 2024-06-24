// Machine that makes water and nothing else

/obj/machinery/plumbing/synthesizer/water_synth
	name = "water synthesizer"
	desc = "An infinitely useful device for those finding themselves in a frontier without a stable source of water. \
		Using a simplified version of the chemistry dispenser's synthesizer process, it can create water out of nothing \
		but good old electricity."
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "water_synth"
	anchored = FALSE
	/// Reagents that this can dispense, overrides the default list on init
	var/static/list/synthesizable_reagents = list(
		/datum/reagent/water,
	)
	/// What this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/water_synth

/obj/machinery/plumbing/synthesizer/water_synth/Initialize(mapload, bolt = FALSE, layer)
	. = ..()
	dispensable_reagents = synthesizable_reagents
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

// Deployable item for cargo for the water synth

/obj/item/flatpacked_machine/water_synth
	name = "water synthesizer parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "water_synth_parts"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/plumbing/synthesizer/water_synth
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)

// Machine that makes botany nutrients for hydroponics farming

/obj/machinery/plumbing/synthesizer/colony_hydroponics
	name = "hydroponics chemical synthesizer"
	desc = "An infinitely useful device for those finding themselves in a frontier without a stable source of nutrients for crops. \
		Using a simplified version of the chemistry dispenser's synthesizer process, it can create hydroponics nutrients out of nothing \
		but good old electricity."
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "hydro_synth"
	anchored = FALSE
	/// Reagents that this can dispense, overrides the default list on init
	var/static/list/synthesizable_reagents = list(
		/datum/reagent/plantnutriment/eznutriment,
		/datum/reagent/plantnutriment/left4zednutriment,
		/datum/reagent/plantnutriment/robustharvestnutriment,
		/datum/reagent/plantnutriment/endurogrow,
		/datum/reagent/plantnutriment/liquidearthquake,
		/datum/reagent/toxin/plantbgone/weedkiller,
		/datum/reagent/toxin/pestkiller,
	)
	/// What this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/hydro_synth

/obj/machinery/plumbing/synthesizer/colony_hydroponics/Initialize(mapload, bolt = FALSE, layer)
	. = ..()
	dispensable_reagents = synthesizable_reagents
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

// Deployable item for cargo for the hydro synth

/obj/item/flatpacked_machine/hydro_synth
	name = "hydroponics chemical synthesizer parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "hydro_synth_parts"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/plumbing/synthesizer/colony_hydroponics
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)

// Chem dispenser with a limited range of thematic reagents to dispense

/obj/machinery/chem_dispenser/frontier_appliance
	name = "sustenance dispenser"
	desc = "Creates and dispenses a small pre-defined set of chemicals and other liquids for the convenience of those typically on the frontier. \
		While the machine is loved by many, it also has a reputation for making some of the worst coffees this side of the galaxy. Use at your own risk."
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	pass_flags = PASSTABLE
	anchored_tabletop_offset = 4
	anchored = FALSE
	circuit = null
	powerefficiency = 0.5
	recharge_amount = 50
	show_ph = FALSE
	// God's strongest coffee machine
	dispensable_reagents = list(
		/datum/reagent/water,
		/datum/reagent/consumable/powdered_milk,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/powdered_lemonade,
		/datum/reagent/consumable/powdered_coco,
		/datum/reagent/consumable/powdered_coffee,
		/datum/reagent/consumable/powdered_tea,
		/datum/reagent/consumable/vanilla,
		/datum/reagent/consumable/caramel,
		/datum/reagent/consumable/korta_nectar,
		/datum/reagent/consumable/korta_milk,
		/datum/reagent/consumable/astrotame,
		/datum/reagent/consumable/salt,
		/datum/reagent/consumable/blackpepper,
		/datum/reagent/consumable/nutraslop,
		/datum/reagent/consumable/enzyme,
	)
	/// Since we don't have a board to take from, we use this to give the dispenser a cell on spawning
	var/cell_we_spawn_with = /obj/item/stock_parts/cell/crap/empty

/obj/machinery/chem_dispenser/frontier_appliance/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	cell = new cell_we_spawn_with(src)

/obj/machinery/chem_dispenser/frontier_appliance/display_beaker()
	var/mutable_appearance/overlayed_beaker = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	return overlayed_beaker

/obj/machinery/chem_dispenser/frontier_appliance/RefreshParts()
	. = ..()
	powerefficiency = 0.5
	recharge_amount = 50

/obj/machinery/chem_dispenser/frontier_appliance/examine(mob/user)
	. = ..()
	. += span_notice("It cannot be repacked, but can be deconstructed normally.")

// Deployable item for cargo for the sustenance machine

/obj/item/flatpacked_machine/sustenance_machine
	name = "sustenance dispenser parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/chemistry_machines.dmi'
	icon_state = "dispenser_parts"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/chem_dispenser/frontier_appliance
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)

// We can't just use electrolyzer reactions, because that'd let electrolyzers do co2 cracking

GLOBAL_LIST_INIT(cracker_reactions, cracker_reactions_list())

/// Global proc to build up the list of co2 cracker reactions
/proc/cracker_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/cracker_reaction))
		var/datum/cracker_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/cracker_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"
	var/desc = ""
	var/list/factor

/// Called when the co2 cracker reaction is run, should be where the code for actually changing gasses around is run
/datum/cracker_reaction/proc/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	return

/// Checks if this reaction can actually be run
/datum/cracker_reaction/proc/reaction_check(datum/gas_mixture/air_mixture)
	var/temp = air_mixture.temperature
	var/list/cached_gases = air_mixture.gases
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/id in requirements)
		if(id == "MIN_TEMP" || id == "MAX_TEMP")
			continue
		if(!cached_gases[id] || cached_gases[id][MOLES] < requirements[id])
			return FALSE
	return TRUE

/datum/cracker_reaction/co2_cracking
	name = "CO2 Cracking"
	id = "co2_cracking"
	desc = "Conversion of CO2 into equal amounts of O2"
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/carbon_dioxide = "1 mole of CO2 gets consumed",
		/datum/gas/oxygen = "1 mole of O2 gets produced",
		"Location" = "Can only happen on turfs with an active CO2 cracker.",
	)

/datum/cracker_reaction/co2_cracking/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen)
	var/proportion = min(air_mixture.gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(2), (2.5 * (working_power ** 2)))
	air_mixture.gases[/datum/gas/carbon_dioxide][MOLES] -= proportion
	air_mixture.gases[/datum/gas/oxygen][MOLES] += proportion
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

// CO2 cracker machine itself

/obj/machinery/electrolyzer/co2_cracker
	name = "portable CO2 cracker"
	desc = "A portable device that is the savior of many a colony on the frontier. Performing similarly to an electrolyzer, \
		it takes in nearby gasses and breaks them into different gasses. The big draw of this one? It can crack carbon dioxide \
		into breathable oxygen. Handy for places where CO2 is all too common, and oxygen is all too hard to find."
	icon = 'monkestation/code/modules/blueshift/icons/portable_machines.dmi'
	circuit = null
	working_power = 1
	/// Soundloop for while the thermomachine is turned on
	var/datum/looping_sound/conditioner_running/soundloop
	/// What this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/co2_cracker

/obj/machinery/electrolyzer/co2_cracker/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/electrolyzer/co2_cracker/process_atmos()
	if(on && !soundloop.loop_started)
		soundloop.start()
	else if(soundloop.loop_started)
		soundloop.stop()
	return ..()

/obj/machinery/electrolyzer/co2_cracker/call_reactions(datum/gas_mixture/env)
	for(var/reaction in GLOB.cracker_reactions)
		var/datum/cracker_reaction/current_reaction = GLOB.cracker_reactions[reaction]

		if(!current_reaction.reaction_check(env))
			continue

		current_reaction.react(loc, env, working_power)

	env.garbage_collect()

/obj/machinery/electrolyzer/co2_cracker/RefreshParts()
	. = ..()
	working_power = 2
	efficiency = 1

/obj/machinery/electrolyzer/co2_cracker/crowbar_act(mob/living/user, obj/item/tool)
	return

// "parts kit" for buying these from cargo

/obj/item/flatpacked_machine/co2_cracker
	name = "CO2 cracker parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/parts_kits.dmi'
	icon_state = "co2_cracker"
	type_to_deploy = /obj/machinery/electrolyzer/co2_cracker
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, // We're gonna pretend plasma is the catalyst for co2 cracking
	)

/obj/machinery/biogenerator/foodricator
	name = "organic rations printer"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		various foods or ingredients. The best friend of a chef where deliveries are inconsistent or simply don't exist. \
		Some of those that consume the food from this complain that the foods it makes have poor taste, though they must \
		not appreciate being able to eat steak and eggs for breakfast with a lack of any livestock at all in the colony."
	icon = 'monkestation/code/modules/blueshift/icons/foodricator.dmi'
	circuit = null
	anchored = FALSE
	pass_flags = PASSTABLE
	efficiency = 1
	productivity = 2.5
	anchored_tabletop_offset = 6
	show_categories = list(
		RND_CATEGORY_AKHTER_FOODRICATOR_INGREDIENTS,
		RND_CATEGORY_AKHTER_FOODRICATOR_BAGS,
		RND_CATEGORY_AKHTER_FOODRICATOR_SNACKS,
		RND_CATEGORY_AKHTER_FOODRICATOR_UTENSILS,
		RND_CATEGORY_AKHTER_SEEDS,
	)
	/// What this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/organics_ration_printer

/obj/machinery/biogenerator/foodricator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	AddElement(/datum/element/repackable, repacked_type, 5 SECONDS)

/obj/machinery/biogenerator/foodricator/RefreshParts()
	. = ..()
	efficiency = 1
	productivity = 3

/obj/machinery/biogenerator/foodricator/default_deconstruction_crowbar()
	return

// Deployable item for cargo for the rations printer

/obj/item/flatpacked_machine/organics_ration_printer
	name = "organic rations printer parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/foodricator.dmi'
	icon_state = "biogenerator_parts"
	type_to_deploy = /obj/machinery/biogenerator/foodricator
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/machinery/colony_recycler
	name = "materials recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. Items are inserted by hand, rather than by belt. \
		Mind your fingers."
	icon = 'monkestation/code/modules/blueshift/icons/portable_machines.dmi'
	icon_state = "recycler"
	anchored = FALSE
	density = TRUE
	circuit = null
	/// The percentage of materials returned
	var/amount_produced = 80
	/// The sound made when an item is eaten
	var/item_recycle_sound = 'monkestation/code/modules/blueshift/sounds/forge.ogg'
	/// The recycler's internal materials storage, for when items recycled don't produce enough to make a full sheet of that material
	var/datum/component/material_container/materials
	/// The list of all the materials we can recycle
	var/static/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/plasma,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plastic,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
	)
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/recycler

/obj/machinery/colony_recycler/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 5 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	materials = AddComponent( \
		/datum/component/material_container, \
		allowed_materials, \
		INFINITY, \
		MATCONTAINER_EXAMINE, \
		_after_insert = TYPE_PROC_REF(/obj/machinery/colony_recycler, has_eaten_materials), \
	)

/obj/machinery/colony_recycler/Destroy()
	materials = null
	return ..()

/obj/machinery/colony_recycler/examine(mob/user)
	. = ..()
	. += span_notice("Reclaiming <b>[amount_produced]%</b> of materials salvaged.")
	. += span_notice("Can be <b>secured</b> with a <b>wrench</b> using <b>Right-Click</b>.")

/obj/machinery/colony_recycler/wrench_act_secondary(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return

/// Proc called when the recycler eats new materials, checks if we should spit out new material sheets
/obj/machinery/colony_recycler/proc/has_eaten_materials(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	flick("recycler_grind", src)
	playsound(src, item_recycle_sound, 50, TRUE)
	use_power(min(active_power_usage * 0.25, amount_inserted / 100))

	if(amount_inserted)
		materials.retrieve_all(drop_location())

// "parts kit" for buying these from cargo

/obj/item/flatpacked_machine/recycler
	name = "recycler parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/parts_kits.dmi'
	icon_state = "recycler"
	type_to_deploy = /obj/machinery/colony_recycler
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT, // Titan for the crushing element
	)

/obj/machinery/space_heater/wall_mounted
	name = "mounted heater"
	desc = "A compact heating and cooling device for small scale applications, made to mount onto walls up and out of the way. \
		Like other, more free-standing space heaters however, these still require cell power to function."
	icon = 'monkestation/code/modules/blueshift/icons/space_heater.dmi'
	anchored = TRUE
	density = FALSE
	circuit = null
	heating_power = 20 KW
	efficiency = 10000
	display_panel = TRUE
	/// What this repacks into when its wrenched off a wall
	var/repacked_type = /obj/item/wallframe/wall_heater

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/space_heater/wall_mounted, 29)

/obj/machinery/space_heater/wall_mounted/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/space_heater/wall_mounted/RefreshParts()
	. = ..()
	heating_power = 20 KW
	efficiency = 10000

/obj/machinery/space_heater/wall_mounted/default_deconstruction_crowbar()
	return

/obj/machinery/space_heater/wall_mounted/default_unfasten_wrench(mob/living/user, obj/item/wrench, time)
	user.balloon_alert(user, "deconstructing...")
	wrench.play_tool_sound(src)
	if(wrench.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

/obj/machinery/space_heater/wall_mounted/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())
	return ..()

// Wallmount for creating the heaters

/obj/item/wallframe/wall_heater
	name = "unmounted wall heater"
	desc = "A compact heating and cooling device for small scale applications, made to mount onto walls up and out of the way. \
		Like other, more free-standing space heaters however, these still require cell power to function."
	icon = 'monkestation/code/modules/blueshift/icons/space_heater.dmi'
	icon_state = "sheater-off"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/space_heater/wall_mounted
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)

/obj/machinery/cell_charger_multi/wall_mounted
	name = "mounted multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but mounted neatly on a wall out of the way!"
	icon = 'monkestation/code/modules/blueshift/icons/cell_charger.dmi'
	icon_state = "wall_charger"
	base_icon_state = "wall_charger"
	circuit = null
	max_batteries = 3
	charge_rate = 900 KW
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/wallframe/cell_charger_multi

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/cell_charger_multi/wall_mounted, 29)

/obj/machinery/cell_charger_multi/wall_mounted/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/cell_charger_multi/wall_mounted/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	user.balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

// previously NO_DECONSTRUCTION
/obj/machinery/cell_charger_multi/wall_mounted/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())

/obj/machinery/cell_charger_multi/wall_mounted/RefreshParts()
	. = ..()
	charge_rate = 900 KW // Nuh uh!

// Item for creating the arc furnace or carrying it around

/obj/item/wallframe/cell_charger_multi
	name = "unmounted wall multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but able to be mounted neatly on a wall out of the way!"
	icon = 'monkestation/code/modules/blueshift/icons/packed_machines.dmi'
	icon_state = "cell_charger_packed"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/cell_charger_multi/wall_mounted
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)

/obj/machinery/power/colony_wind_turbine
	name = "miniature wind turbine"
	desc = "A post with two special-designed vertical turbine blades attached to its sides. \
		When placed outdoors in a planet with an atmosphere, will produce a small trickle of power \
		for free. If there is a storm in the area the turbine is placed, the power production will \
		multiply significantly."
	icon = 'monkestation/code/modules/blueshift/icons/wind_turbine.dmi'
	icon_state = "turbine"
	density = TRUE
	max_integrity = 100
	idle_power_usage = 0
	anchored = TRUE
	can_change_cable_layer = FALSE
	circuit = null
	layer = ABOVE_MOB_LAYER
	can_change_cable_layer = TRUE
	/// How much power the turbine makes without a storm
	var/regular_power_production = 2500
	/// How much power the turbine makes during a storm
	var/storm_power_production = 10000
	/// Is our pressure too low to function?
	var/pressure_too_low = FALSE
	/// Minimum external pressure needed to work
	var/minimum_pressure = 5
	/// What we undeploy into
	var/undeploy_type = /obj/item/flatpacked_machine/wind_turbine

/obj/machinery/power/colony_wind_turbine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, undeploy_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	connect_to_network()

/obj/machinery/power/colony_wind_turbine/examine(mob/user)
	. = ..()
	var/area/turbine_area = get_area(src)
	if(!turbine_area.outdoors)
		. += span_notice("Its must be constructed <b>outdoors</b> to function.")
	if(pressure_too_low)
		. += span_notice("There must be enough atmospheric <b>pressure</b> for the turbine to spin.")


/obj/machinery/power/colony_wind_turbine/process()
	var/area/our_current_area = get_area(src)
	if(!our_current_area.outdoors)
		icon_state = "turbine"
		add_avail(0)
		return

	var/turf/our_turf = get_turf(src)
	var/datum/gas_mixture/environment = our_turf.return_air()

	if(environment.return_pressure() < minimum_pressure)
		pressure_too_low = TRUE
		icon_state = "turbine"
		add_avail(0)
		return

	pressure_too_low = FALSE
	var/storming_out = FALSE

	var/datum/weather/weather_we_track
	for(var/datum/weather/possible_weather in SSweather.processing)
		if((our_turf.z in possible_weather.impacted_z_levels) || (our_current_area in possible_weather.impacted_areas))
			weather_we_track = possible_weather
			break
	if(weather_we_track)
		if(!(weather_we_track.stage == END_STAGE))
			storming_out = TRUE

	add_avail((storming_out ? storm_power_production : regular_power_production))

	var/new_icon_state = (storming_out ? "turbine_storm" : "turbine_normal")
	icon_state = new_icon_state


// Item for deploying wind turbines
/obj/item/flatpacked_machine/wind_turbine
	name = "flat-packed miniature wind turbine"
	icon = 'monkestation/code/modules/blueshift/icons/wind_turbine.dmi'
	icon_state = "turbine_packed"
	type_to_deploy = /obj/machinery/power/colony_wind_turbine
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/machinery/griddle/frontier_tabletop
	name = "tabletop griddle"
	desc = "A griddle type slim enough to fit atop a table without much fuss. This type in particular \
		was made to be broken down into many parts and shipped across the glaxy. This makes it a favourite in \
		pop-up food stalls and colony kitchens all around."
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/griddle.dmi'
	icon_state = "griddletable_off"
	variant = "table"
	pass_flags_self = LETPASSTHROW
	pass_flags = PASSTABLE
	circuit = null
	// Lines up perfectly with tables when anchored on them
	anchored_tabletop_offset = 3
	/// What type this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/frontier_griddle

/obj/machinery/griddle/frontier_tabletop/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/griddle/frontier_tabletop/unanchored
	anchored = FALSE

// Deployable item for cargo

/obj/item/flatpacked_machine/frontier_griddle
	name = "flat-packed tabletop griddle"
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/griddle.dmi'
	icon_state = "griddle_parts"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/griddle/frontier_tabletop
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/machinery/microwave/frontier_printed
	desc = "A plastic-paneled microwave oven, capable of doing anything a standard microwave could do. \
		This one is special designed to be tightly packed into a shape that can be easily re-assembled \
		later from the factory. There don't seem to be included instructions on getting it folded back \
		together, though..."
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/microwave.dmi'
	circuit = null
	max_n_of_items = 5
	efficiency = 2
/obj/machinery/microwave/frontier_printed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/microwave/frontier_printed/RefreshParts()
	. = ..()
	max_n_of_items = 5

/obj/machinery/microwave/frontier_printed/examine(mob/user)
	. = ..()
	. += span_notice("It cannot be repacked, but can be deconstructed normally.")

/obj/machinery/microwave/frontier_printed/unanchored
	anchored = FALSE

// Deployable item for cargo

/obj/item/flatpacked_machine/macrowave
	name = "microwave oven parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/microwave.dmi'
	icon_state = "packed_microwave"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/microwave/frontier_printed
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/machinery/oven/range_frontier
	name = "frontier range"
	desc = "A combined oven and stove commonly seen on the frontier. Comes from the factory packed up \
		in a neatly compact format that can then be deployed into a nearly full size appliance. \
		It seems, however, that the designer forgot to include instructions on packing these things back up."
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/range.dmi'
	icon_state = "range_off"
	base_icon_state = "range"
	pass_flags_self = PASSMACHINE|PASSTABLE|LETPASSTHROW
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 1.2
	circuit = null

/obj/machinery/oven/range_frontier/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	AddComponent(/datum/component/stove, container_x = -3, container_y = 14)

/obj/machinery/oven/range_frontier/examine(mob/user)
	. = ..()
	. += span_notice("It cannot be repacked, but can be deconstructed normally.")

/obj/machinery/oven/range_frontier/unanchored
	anchored = FALSE

// Deployable item for cargo

/obj/item/flatpacked_machine/frontier_range
	name = "frontier range parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/kitchen_stuff/range.dmi'
	icon_state = "range_packed"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/oven/range_frontier
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/gps/computer/beacon
	name = "\improper GPS beacon"
	desc = "A GPS beacon, anchored to the ground to prevent loss or accidental movement."
	icon = 'monkestation/code/modules/blueshift/icons/gps_beacon.dmi'
	icon_state = "gps_beacon"
	pixel_y = 0
	/// What this is undeployed back into
	var/undeploy_type = /obj/item/flatpacked_machine/gps_beacon

/obj/item/gps/computer/beacon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, undeploy_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/item/flatpacked_machine/gps_beacon
	name = "packed GPS beacon"
	icon = 'monkestation/code/modules/blueshift/icons/gps_beacon.dmi'
	icon_state = "beacon_folded"
	w_class = WEIGHT_CLASS_SMALL
	type_to_deploy = /obj/item/gps/computer/beacon

/obj/item/flatpacked_machine/gps_beacon/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)
