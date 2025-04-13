/datum/design/board/woodgen
	name = "Internal Combustion Generator Board"
	desc = "The circuit board for a Internal Combustion Generator."
	id = "woodgen"
	build_path = /obj/item/circuitboard/machine/pacman
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/circuitboard/machine/pacman/wood
	name = "Internal Combustion Generator"
	other_type = TRUE
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/port_gen/pacman/wood
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5
	)
	needs_anchored = FALSE
	high_production_profile = TRUE // Спасибо оффам тг за то что приходится костылить

/obj/machinery/power/port_gen/pacman/wood
	name = "internal combustion generator"
	desc = "A portable generator that burns wood and turns it into energy."
	icon = 'modular_meta/features/woodgen/icons/wood_engine.dmi'
	sheet_path = /obj/item/stack/sheet/mineral/wood
	circuit = /obj/item/circuitboard/machine/pacman/wood
	icon_state = "icg_0"
	base_icon_state = "icg"
	max_sheets = 60
	time_per_sheet = 300
	power_gen = 1 KILO JOULES
