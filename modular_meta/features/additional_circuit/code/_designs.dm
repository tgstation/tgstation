//Mining Component
/datum/design/component/mining
	name = "Mining Component"
	id = "comp_mine"
	build_path = /obj/item/circuit_component/mining

//Item Interact Component
/datum/design/component/item_interact
	name = "Item Interact Component"
	id = "comp_iinteract"
	build_path = /obj/item/circuit_component/item_interact

/datum/techweb_node/comp_advanced_interacts
	id = TECHWEB_NODE_COMP_INTERACTION_COMPONENT
	display_name = "Advanced Action Components"
	description = "Grants access to more advanced action components for the drone shell."
	prereq_ids = list(TECHWEB_NODE_PROGRAMMED_ROBOT)
	design_ids = list(
		"comp_mine",
		"comp_iinteract",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

//Target Scanner Component
/datum/design/component/radar_scanner
	name = "Target Scanner Component"
	id = "comp_tscanner"
	build_path = /obj/item/circuit_component/target_scanner

//Cell Charge Component
/datum/design/component/cell_charge
	name = "Cell Charge Component"
	id = "comp_ccharge"
	build_path = /obj/item/circuit_component/cell_charge

/datum/techweb_node/comp_advanced_sensors
	id = TECHWEB_NODE_COMP_ADVANCED_SENSORS
	display_name = "Advanced Sensor Components"
	description = "Grants access to advanced sensor components component for shells."
	prereq_ids = list(TECHWEB_NODE_PROGRAMMING)
	design_ids = list(
		"comp_tscanner",
		"comp_ccharge",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
