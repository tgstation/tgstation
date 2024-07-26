// Service

/datum/supply_pack/service/hydro_synthesizers
	name = "Hydroponics Plumbing Synthesizer Pack"
	desc = "Watering and feeding your plants got you down? Worry no further as this kit contains two each of water and hydroponics fertilizer synthesizers."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(
		/obj/machinery/plumbing/synthesizer/water_synth,
		/obj/machinery/plumbing/synthesizer/water_synth,
		/obj/machinery/plumbing/synthesizer/colony_hydroponics,
		/obj/machinery/plumbing/synthesizer/colony_hydroponics,
	)
	crate_name = "hydroponics synthesizers crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/service/frontier_kitchen
	name = "Frontier Kitchen Equipment"
	desc = "A range of frontier appliance classics, enough to set up a functioning kitchen no matter where you are in the galaxy."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/machinery/plumbing/synthesizer/water_synth,
		/obj/machinery/chem_dispenser/frontier_appliance,
		/obj/machinery/griddle/frontier_tabletop/unanchored,
		/obj/machinery/microwave/frontier_printed/unanchored,
		/obj/machinery/oven/range_frontier/unanchored,
		/obj/machinery/biogenerator/foodricator,
	)
	crate_name = "frontier kitchen crate"

// Engineering

/datum/supply_pack/engineering/colony_starter
	name = "Colonization Starter Kit"
	desc = "The Sol standard minimum kit for frontier colonization, contains everything you need to construct a mostly functioning colony in most places across the galaxy."
	cost = CARGO_CRATE_VALUE * 11 // 6 for the lathe, 3 for the organics printer, 2 for the rest of the stuff
	contains = list(
		/obj/item/flatpacked_machine,
		/obj/item/flatpacked_machine/ore_silo,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/stack/cable_coil/five,
		/obj/item/stack/cable_coil/five,
		/obj/item/stack/cable_coil/five,
		/obj/item/stack/cable_coil/five,
		/obj/item/stack/cable_coil/five,
		/obj/item/flatpacked_machine/organics_printer,
		/obj/item/flatpacked_machine/gps_beacon,
		/obj/item/stack/sheet/plastic_wall_panel/fifty,
		/obj/item/stack/rods/twentyfive,
		/obj/item/stack/sheet/iron/twenty,
		/obj/item/flatpacked_machine/airlock_kit_manual,
		/obj/item/flatpacked_machine/airlock_kit_manual,
		/obj/item/wallframe/apc,
		/obj/item/electronics/apc,
		/obj/item/stock_parts/cell/high,
	)
	crate_name = "colonization kit crate"

/obj/machinery/biogenerator/organic_printer
	name = "organic materials printer"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		reagents and items of use that a fabricator can't typically make. While the exact designs these machines have differs from \
		location to location, and upon who designed them, this one should be able to at the very least provide you with \
		some clothing, basic food supplies, and whatever else you may require."
	icon = 'monkestation/code/modules/blueshift/icons/biogenerator.dmi'
	circuit = null
	anchored = FALSE
	efficiency = 1
	productivity = 2
	max_items = 35
	show_categories = list(
		RND_CATEGORY_AKHTER_CLOTHING,
		RND_CATEGORY_AKHTER_EQUIPMENT,
		RND_CATEGORY_AKHTER_RESOURCES,
	)

/obj/machinery/biogenerator/organic_printer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/machinery/biogenerator/organic_printer/RefreshParts()
	. = ..()
	efficiency = 1
	productivity = 2
	max_items = 35

/obj/machinery/biogenerator/organic_printer/default_deconstruction_crowbar()
	return

// Deployable item for cargo for the organics printer
/obj/item/flatpacked_machine/organics_printer
	name = "organic materials printer parts kit"
	icon = 'monkestation/code/modules/blueshift/icons/biogenerator.dmi'
	icon_state = "biogenerator_parts"
	type_to_deploy = /obj/machinery/biogenerator/organic_printer

/obj/item/flatpacked_machine/organics_printer/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)


/obj/structure/closet/crate/colony_starter/PopulateContents()
	new /obj/item/flatpacked_machine(src)
	new /obj/item/flatpacked_machine/ore_silo(src)
	new /obj/item/flatpacked_machine/wind_turbine(src)
	new /obj/item/flatpacked_machine/wind_turbine(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/flatpacked_machine/organics_printer(src)
	new /obj/item/flatpacked_machine/gps_beacon(src)
	new /obj/item/stack/sheet/plastic_wall_panel/fifty(src)
	new /obj/item/stack/rods/twentyfive(src)
	new /obj/item/stack/sheet/iron/twenty(src)
	new /obj/item/flatpacked_machine/airlock_kit_manual(src)
	new /obj/item/flatpacked_machine/airlock_kit_manual(src)
	new /obj/item/wallframe/apc(src)
	new /obj/item/electronics/apc(src)
	new /obj/item/stock_parts/cell/high(src)
	new /obj/item/wallframe/frontier_medstation(src)
	new /obj/item/screwdriver/omni_drill(src)
	new /obj/item/multitool(src)
	new /obj/item/crowbar(src)
