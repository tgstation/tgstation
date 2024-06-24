/datum/armament_entry/company_import/akh_frontier
	category = FRONTIER_EQUIPMENT_NAME
	company_bitflag = CARGO_COMPANY_FRONTIER_EQUIPMENT

// Tools that you could use the rapid fabricator for, but you're too lazy to actually do that

/datum/armament_entry/company_import/akh_frontier/basic
	subcategory = "Hand-Held Equipment"
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/akh_frontier/basic/omni_drill
	item_type = /obj/item/screwdriver/omni_drill

/datum/armament_entry/company_import/akh_frontier/basic/prybar
	item_type = /obj/item/crowbar/large/doorforcer
	restricted = TRUE

/datum/armament_entry/company_import/akh_frontier/basic/arc_welder
	item_type = /obj/item/weldingtool/electric/arc_welder

/datum/armament_entry/company_import/akh_frontier/basic/compact_drill
	item_type = /obj/item/pickaxe/drill/compact

// Flatpacked fabricator and related upgrades

/datum/armament_entry/company_import/akh_frontier/deployables_fab
	subcategory = "Deployable Fabrication Equipment"

/datum/armament_entry/company_import/akh_frontier/deployables_fab/rapid_construction_fabricator
	item_type = /obj/item/flatpacked_machine
	cost = CARGO_CRATE_VALUE * 6
	restricted = TRUE

/datum/armament_entry/company_import/akh_frontier/deployables_fab/foodricator
	item_type = /obj/item/flatpacked_machine/organics_ration_printer
	cost = CARGO_CRATE_VALUE * 2

// Various smaller appliances than the deployable machines below

/datum/armament_entry/company_import/akh_frontier/appliances
	subcategory = "Appliances"
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/akh_frontier/appliances/charger
	item_type = /obj/item/wallframe/cell_charger_multi
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/akh_frontier/appliances/wall_heater
	item_type = /obj/item/wallframe/wall_heater
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/akh_frontier/appliances/water_synth
	item_type = /obj/item/flatpacked_machine/water_synth

/datum/armament_entry/company_import/akh_frontier/appliances/hydro_synth
	item_type = /obj/item/flatpacked_machine/hydro_synth

/datum/armament_entry/company_import/akh_frontier/appliances/sustenance_dispenser
	item_type = /obj/item/flatpacked_machine/sustenance_machine
	cost = PAYCHECK_COMMAND * 2

// Flatpacked, ready to deploy machines

/datum/armament_entry/company_import/akh_frontier/deployables_misc
	subcategory = "Deployable General Equipment"
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/akh_frontier/deployables_misc/arc_furnace
	item_type = /obj/item/flatpacked_machine/arc_furnace

/datum/armament_entry/company_import/akh_frontier/deployables_misc/co2_cracker
	item_type = /obj/item/flatpacked_machine/co2_cracker

/datum/armament_entry/company_import/akh_frontier/deployables_misc/recycler
	item_type = /obj/item/flatpacked_machine/recycler

// Flatpacked, ready to deploy machines for power related activities

/datum/armament_entry/company_import/akh_frontier/deployables
	subcategory = "Deployable Power Equipment"
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/akh_frontier/deployables/turbine
	item_type = /obj/item/flatpacked_machine/wind_turbine
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/akh_frontier/deployables/solids_generator
	item_type = /obj/item/flatpacked_machine/fuel_generator

/datum/armament_entry/company_import/akh_frontier/deployables/stirling_generator
	item_type = /obj/item/flatpacked_machine/stirling_generator
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/akh_frontier/deployables/rtg
	item_type = /obj/item/flatpacked_machine/rtg
	cost = PAYCHECK_COMMAND * 2
	restricted = TRUE
