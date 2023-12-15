/obj/item/circuitboard/machine/centrifuge
	name = "Centrifuge"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/centrifuge
	req_components = list(
		/datum/stock_part/manipulator = 3
	)

/obj/item/circuitboard/machine/diseaseanalyser
	name = "Disease Analyzer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/diseaseanalyser
	req_components = list(
		/datum/stock_part/scanning_module = 3,
		/datum/stock_part/manipulator = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/incubator
	name = "Pathogenic Incubator"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/incubator
	req_components = list(
		/datum/stock_part/scanning_module = 2,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 2,
	)

/obj/item/circuitboard/computer/diseasesplicer
	name = "Disease Splicer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/diseasesplicer

/obj/item/circuitboard/computer/pathology_data
	name = "Pathology Data"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/records/pathology
