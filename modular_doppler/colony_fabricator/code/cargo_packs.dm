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

/datum/supply_pack/service/kitchenmage
	name = "'KitchenMage' Culinary Acquisition Helper"
	desc = "'KitchenMage', even YOUR kitchen deserves the magic of our patented dispensing system!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/machinery/chem_dispenser/kitchenaid_stand,
	)
	crate_name = "heavy kitchen machinery crate"
	crate_type = /obj/structure/closet/crate/radiation

// Engineering

/datum/supply_pack/engineering/colony_starter
	name = "Colonization Starter Kit"
	desc = "The Sol standard minimum kit for frontier colonization, contains everything you need to construct a mostly functioning colony in most places across the galaxy."
	cost = CARGO_CRATE_VALUE * 11 // 6 for the lathe, 3 for the organics printer, 2 for the rest of the stuff
	contains = list(
		/obj/item/flatpacked_machine,
		/obj/item/flatpacked_machine/organics_printer,
		/obj/item/flatpacked_machine/gps_beacon,
		/obj/item/stack/sheet/plastic_wall_panel/fifty,
		/obj/item/stack/rods/twentyfive,
		/obj/item/stack/sheet/iron/twenty,
		/obj/item/flatpacked_machine/airlock_kit_manual,
		/obj/item/flatpacked_machine/airlock_kit_manual,
		/obj/item/wallframe/apc,
		/obj/item/electronics/apc,
		/obj/item/stock_parts/power_store/battery/high,
	)
	crate_name = "colonization kit crate"

/datum/supply_pack/engineering/wind_power
	name = "'Go-Green' Wind Turbine Pack"
	desc = "A promotion for colonies powered by greener energy, 'Go-Green' (tm) with nine wind turbines."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
		/obj/item/flatpacked_machine/wind_turbine,
	)
	crate_name = "wind turbine pack"
