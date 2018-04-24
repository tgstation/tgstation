/*
* Fabricator Circuit Board
*/

/obj/item/circuitboard/machine/podfab
	name = "Pod Fabricator (Machine Board)"
	build_path = /obj/machinery/mecha_part_fabricator/podfab
	//origin_tech = "programming=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/datum/design/board/podfab
	name = "Machine Design (Pod Fabricator Board)"
	desc = "The circuit board for an Pod Fabricator."
	id = "podfab"
	build_path = /obj/item/circuitboard/machine/podfab
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/*
* Pod Fabricator
*/
/obj/machinery/mecha_part_fabricator/podfab
	name = "space pod fabricator"
	fabtype = PODFAB
	circuit = /obj/item/circuitboard/machine/podfab
	req_access = list()
	stored_research = /datum/techweb/specialized/autounlocking/podfab
	part_sets = list(
								"Weapons",
								"Utility",
								"Ammunition",
								"Secondary",
								"Construction",
								"Shield",
								"Engine",
								"Cargo Hold",
								"Sensor")

/datum/techweb/specialized/autounlocking/podfab
	node_autounlock_ids = list("podsbasic")
	allowed_buildtypes = PODFAB