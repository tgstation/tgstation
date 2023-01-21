/datum/crafting_recipe/bluespace_vendor_mount
	name = "Bluespace Vendor Wall Mount"
	result = /obj/item/wallframe/bluespace_vendor_mount
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/cable_coil = 10,
	)
	category = CAT_ATMOSPHERIC

/datum/crafting_recipe/pipe
	name = "Smart pipe fitting"
	tool_behaviors = list(TOOL_WRENCH)
	result = /obj/item/pipe/quaternary/pipe
	reqs = list(/obj/item/stack/sheet/iron = 1)
	time = 0.5 SECONDS
	category = CAT_ATMOSPHERIC

/datum/crafting_recipe/pipe/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/pipe/smart
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.p_init_dir = ALL_CARDINALS
	crafted_pipe.setDir(SOUTH)
	crafted_pipe.update()

/datum/crafting_recipe/layer_adapter
	name = "Layer manifold fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/binary/layer_adapter
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 1 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/layer_adapter/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/layer_adapter/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/pipe/layer_manifold
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/color_adapter
	name = "Color adapter fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/binary/color_adapter
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 1 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/color_adapter/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/color_adapter/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/pipe/color_adapter
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/he_pipe
	name = "H/E pipe fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/quaternary/he_pipe
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 1 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/he_pipe/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/he_pipe/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/he_junction
	name = "H/E junction fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/he_junction
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 1 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/he_junction/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/he_junction/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/pipe/heat_exchanging/junction
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/pressure_pump
	name = "Pressure pump fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/binary/pressure_pump
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/pressure_pump/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/pressure_pump/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/binary/pump
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/manual_valve
	name = "Manual valve fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/binary/manual_valve
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/manual_valve/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/manual_valve/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/binary/valve
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/vent
	name = "Vent pump fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/vent
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/vent/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/vent/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/vent_pump
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/scrubber
	name = "Scrubber fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/scrubber
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/scrubber/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/scrubber/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/filter
	name = "Filter fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/trinary/flippable/filter
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/filter/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/filter/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/trinary/filter
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/mixer
	name = "Mixer fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/trinary/flippable/mixer
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/mixer/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/mixer/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/trinary/mixer
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/connector
	name = "Portable connector fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/connector
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/connector/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/connector/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/portables_connector
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/passive_vent
	name = "Passive vent fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/passive_vent
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/passive_vent/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/passive_vent/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/passive_vent
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/injector
	name = "Outlet injector fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/injector
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 5,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/injector/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/injector/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/outlet_injector
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/he_exchanger
	name = "Heat exchanger fitting"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER)
	result = /obj/item/pipe/directional/he_exchanger
	reqs = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/plasteel = 1,
	)
	time = 2 SECONDS
	category = CAT_ATMOSPHERIC
	additional_req_text = " smart pipe fitting"

/datum/crafting_recipe/he_exchanger/check_requirements(mob/user, list/collected_requirements)
	return atmos_pipe_check(user, collected_requirements)

/datum/crafting_recipe/he_exchanger/on_craft_completion(mob/user, atom/result)
	var/obj/item/pipe/crafted_pipe = result
	crafted_pipe.pipe_type = /obj/machinery/atmospherics/components/unary/heat_exchanger
	crafted_pipe.pipe_color = COLOR_VERY_LIGHT_GRAY
	crafted_pipe.setDir(user.dir)
	crafted_pipe.update()

/datum/crafting_recipe/steam_vent
	name = "Steam Vent"
	result = /obj/structure/steam_vent
	time = 0.8 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/tile/iron = 1,
		/obj/item/stock_parts/water_recycler = 1,
	)
	category = CAT_ATMOSPHERIC
