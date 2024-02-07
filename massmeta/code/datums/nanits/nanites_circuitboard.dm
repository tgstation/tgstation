/obj/item/circuitboard/computer/nanite_chamber_control
	name = "Nanite Chamber Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "Nanite Cloud Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/machine/nanite_chamber
	name = "Nanite Chamber (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/datum/stock_part/scanning_module = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/servo = 1)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "Nanite Program Hub (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1)

/obj/item/circuitboard/machine/nanite_programmer
	name = "Nanite Programmer (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/scanning_module = 1)

/obj/item/circuitboard/machine/public_nanite_chamber
	name = "Public Nanite Chamber (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/public_nanite_chamber
	var/cloud_id = 1
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/servo = 1)

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
