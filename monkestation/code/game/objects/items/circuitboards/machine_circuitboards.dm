/obj/item/circuitboard/machine/rad_collector
	name = "Radiation Collector (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Comes with a small amount solder of arranged in the corner: \"If you can read this, you're too close.\""
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/manipulator = 1)
	needs_anchored = FALSE


/obj/item/circuitboard/machine/clonepod	//hippie start, re-add cloning
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/scanning_module = 2,
		/datum/stock_part/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "Experimental Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner	//hippie end, re-add cloning
	name = "Cloning Scanner (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/nanite_chamber
	name = "Nanite Chamber (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/datum/stock_part/scanning_module = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/manipulator = 1)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "Nanite Program Hub (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/manipulator = 1)

/obj/item/circuitboard/machine/nanite_programmer
	name = "Nanite Programmer (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/datum/stock_part/manipulator = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/scanning_module = 1)

/obj/item/circuitboard/machine/public_nanite_chamber
	name = "Public Nanite Chamber (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/public_nanite_chamber
	var/cloud_id = 1
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/manipulator = 1)

/obj/item/circuitboard/machine/public_nanite_chamber/multitool_act(mob/living/user)
	. = ..()
	var/new_cloud = input("Set the public nanite chamber's Cloud ID (1-100).", "Cloud ID", cloud_id) as num|null
	if(!new_cloud || (loc != user))
		to_chat(user, span_warning("You must hold the circuitboard to change its Cloud ID!"))
		return
	cloud_id = clamp(round(new_cloud, 1), 1, 100)

/obj/item/circuitboard/machine/public_nanite_chamber/examine(mob/user)
	. = ..()
	. += "Cloud ID is currently set to [cloud_id]."
