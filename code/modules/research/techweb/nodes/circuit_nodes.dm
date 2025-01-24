/datum/techweb_node/programming
	id = TECHWEB_NODE_PROGRAMMING
	starting_node = TRUE
	display_name = "Programming"
	description = "Dedicate an entire shift to program a fridge to greet you when opened."
	prereq_ids = list(TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"component_printer",
		"module_duplicator",
		"circuit_multitool",
		"compact_remote_shell",
		"usb_cable",
		"integrated_circuit",
		"comp_access_checker",
		"comp_arctan2",
		"comp_arithmetic",
		"comp_assoc_list_pick",
		"comp_assoc_list_remove",
		"comp_assoc_list_set",
		"comp_binary_convert",
		"comp_clock",
		"comp_comparison",
		"comp_concat",
		"comp_concat_list",
		"comp_decimal_convert",
		"comp_delay",
		"comp_direction",
		"comp_element_find",
		"comp_filter_list",
		"comp_foreach",
		"comp_format",
		"comp_format_assoc",
		"comp_get_column",
		"comp_gps",
		"comp_health",
		"comp_health_state",
		"comp_hear",
		"comp_id_access_reader",
		"comp_id_getter",
		"comp_id_info_reader",
		"comp_index",
		"comp_index_assoc",
		"comp_index_table",
		"comp_laserpointer",
		"comp_length",
		"comp_light",
		"comp_list_add",
		"comp_list_assoc_literal",
		"comp_list_clear",
		"comp_list_literal",
		"comp_list_pick",
		"comp_list_remove",
		"comp_logic",
		"comp_matscanner",
		"comp_mmi",
		"comp_module",
		"comp_multiplexer",
		"comp_not",
		"comp_ntnet_receive",
		"comp_ntnet_send",
		"comp_ntnet_send_list_literal",
		"comp_nfc_send",
		"comp_nfc_receive",
		"comp_pinpointer",
		"comp_pressuresensor",
		"comp_radio",
		"comp_random",
		"comp_reagents",
		"comp_router",
		"comp_select_query",
		"comp_self",
		"comp_set_variable_trigger",
		"comp_soundemitter",
		"comp_species",
		"comp_speech",
		"comp_speech",
		"comp_split",
		"comp_string_contains",
		"comp_tempsensor",
		"comp_textcase",
		"comp_timepiece",
		"comp_toggle",
		"comp_tonumber",
		"comp_tostring",
		"comp_trigonometry",
		"comp_typecast",
		"comp_typecheck",
		"comp_view_sensor",
		"comp_wire_bundle",
		"comp_wirenet_receive",
		"comp_wirenet_send",
		"comp_wirenet_send_literal",
	)

/datum/techweb_node/circuit_shells
	id = TECHWEB_NODE_CIRCUIT_SHELLS
	display_name = "Advanced Circuit Shells"
	description = "Adding brains to more things."
	prereq_ids = list(TECHWEB_NODE_PROGRAMMING)
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		"controller_shell",
		"dispenser_shell",
		"door_shell",
		"gun_shell",
		"keyboard_shell",
		"module_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
		"undertile_shell",
		"wallmount_shell",
		"comp_equip_action",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/bci
	id = TECHWEB_NODE_BCI
	display_name = "Brain-Computer Interface"
	description = "Embedded brain circuits. May occasionally stream Nanotrasen ads in dreams."
	prereq_ids = list(TECHWEB_NODE_CIRCUIT_SHELLS, TECHWEB_NODE_PASSIVE_IMPLANTS)
	design_ids = list(
		"bci_implanter",
		"bci_shell",
		"comp_bar_overlay",
		"comp_camera_bci",
		"comp_counter_overlay",
		"comp_install_detector",
		"comp_object_overlay",
		"comp_reagent_injector",
		"comp_target_intercept",
		"comp_thought_listener",
		"comp_vox",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/skillchip = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/programmed_robot
	id = TECHWEB_NODE_PROGRAMMED_ROBOT
	display_name = "Programmed Robot"
	description = "Grants access to movable shells, allowing for remote operations and pranks."
	prereq_ids = list(TECHWEB_NODE_CIRCUIT_SHELLS)
	design_ids = list(
		"drone_shell",
		"comp_pathfind",
		"comp_pull",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/programmed_server
	id = TECHWEB_NODE_PROGRAMMED_SERVER
	display_name = "Programmed Server"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list(TECHWEB_NODE_BCI)
	design_ids = list(
		"server_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
