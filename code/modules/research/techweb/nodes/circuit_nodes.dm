/datum/techweb_node/programming
	display_name = "Programming"
	description = "Dedicate an entire shift to program a fridge to greet you when opened."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/component_printer,
		/datum/design/board/module_printer,
		/datum/design/circuit_multitool,
		/datum/design/wiremod_shell/compact_remote,
		/datum/design/usb_cable,
		/datum/design/integrated_circuit,
		/datum/design/component/access_checker,
		/datum/design/component/math/arctan2,
		/datum/design/component/math/arithmetic,
		/datum/design/component/list/pick_assoc,
		/datum/design/component/list/assoc_list_remove,
		/datum/design/component/list/assoc_list_set,
		/datum/design/component/math/binary_conversion,
		/datum/design/component/utility/clock,
		/datum/design/component/math/comparison,
		/datum/design/component/string/concat,
		/datum/design/component/list/concat,
		/datum/design/component/math/decimal_conversion,
		/datum/design/component/utility/delay,
		/datum/design/component/entity/direction,
		/datum/design/component/list/find,
		/datum/design/component/list/filter,
		/datum/design/component/list/foreach,
		/datum/design/component/list/format,
		/datum/design/component/list/format_assoc,
		/datum/design/component/list/get_column,
		/datum/design/component/entity/gps,
		/datum/design/component/entity/health,
		/datum/design/component/entity/compare_health_state,
		/datum/design/component/entity/hear,
		/datum/design/component/id_access_reader,
		/datum/design/component/id_getter,
		/datum/design/component/id_info_reader,
		/datum/design/component/list/index,
		/datum/design/component/list/index_assoc,
		/datum/design/component/list/index_table,
		/datum/design/component/action/laserpointer,
		/datum/design/component/math/length,
		/datum/design/component/action/light,
		/datum/design/component/list/add,
		/datum/design/component/list/assoc_literal,
		/datum/design/component/list/clear,
		/datum/design/component/list/literal,
		/datum/design/component/list/pick,
		/datum/design/component/list/remove,
		/datum/design/component/math/logic,
		/datum/design/component/entity/matscanner,
		/datum/design/component/action/mmi,
		/datum/design/component/module,
		/datum/design/component/utility/multiplexer,
		/datum/design/component/math/not,
		/datum/design/component/ntnet_receive,
		/datum/design/component/ntnet_send,
		/datum/design/component/list/literal/ntnet_send,
		/datum/design/component/nfc_send,
		/datum/design/component/nfc_receive,
		/datum/design/component/entity/pinpointer,
		/datum/design/component/pressuresensor,
		/datum/design/component/action/radio,
		/datum/design/component/math/random,
		/datum/design/component/entity/reagentscanner,
		/datum/design/component/utility/router,
		/datum/design/component/list/select_query,
		/datum/design/component/entity/self,
		/datum/design/component/utility/setter_trigger,
		/datum/design/component/action/soundemitter,
		/datum/design/component/entity/species,
		/datum/design/component/action/speech,
		/datum/design/component/list/split,
		/datum/design/component/string/contains,
		/datum/design/component/string/replace,
		/datum/design/component/tempsensor,
		/datum/design/component/string/textcase,
		/datum/design/component/utility/timepiece,
		/datum/design/component/math/toggle,
		/datum/design/component/string/tonumber,
		/datum/design/component/string/tostring,
		/datum/design/component/math/trigonometry,
		/datum/design/component/utility/typecast,
		/datum/design/component/utility/typecheck,
		/datum/design/component/view_sensor,
		/datum/design/component/utility/wire_bundle,
		/datum/design/component/wirenet_receive,
		/datum/design/component/wirenet_send,
		/datum/design/component/wirenet_send_literal,
	)

/datum/techweb_node/circuit_shells
	display_name = "Advanced Circuit Shells"
	description = "Adding brains to more things."
	prerequisite_nodes = list(/datum/techweb_node/programming)
	unlocked_designs = list(
		/datum/design/wiremod_shell/assembly,
		/datum/design/wiremod_shell/bot,
		/datum/design/wiremod_shell/controller,
		/datum/design/wiremod_shell/dispenser,
		/datum/design/wiremod_shell/airlock,
		/datum/design/wiremod_shell/gun,
		/datum/design/wiremod_shell/implant,
		/datum/design/wiremod_shell/keyboard,
		/datum/design/wiremod_shell/mod_module,
		/datum/design/wiremod_shell/money_bot,
		/datum/design/wiremod_shell/scanner_gate,
		/datum/design/wiremod_shell/scanner,
		/datum/design/wiremod_shell/undertile,
		/datum/design/wiremod_shell/wallmount,
		/datum/design/component/action/equipment_action,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/bci
	display_name = "Brain-Computer Interface"
	description = "Embedded brain circuits. May occasionally stream Nanotrasen ads in dreams."
	prerequisite_nodes = list(/datum/techweb_node/circuit_shells, /datum/techweb_node/passive_implants)
	unlocked_designs = list(
		/datum/design/board/bci_implanter,
		/datum/design/wiremod_shell/bci,
		/datum/design/component/bci/bar_overlay,
		/datum/design/component/bci/bci_camera,
		/datum/design/component/bci/counter_overlay,
		/datum/design/component/bci/install_detector,
		/datum/design/component/bci/object_overlay,
		/datum/design/component/bci/reagent_injector,
		/datum/design/component/bci/target_intercept,
		/datum/design/component/bci/thought_listener,
		/datum/design/component/bci/vox,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/skillchip = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/programmed_robot
	display_name = "Programmed Robot"
	description = "Grants access to movable shells, allowing for remote operations and pranks."
	prerequisite_nodes = list(/datum/techweb_node/circuit_shells)
	unlocked_designs = list(
		/datum/design/wiremod_shell/drone,
		/datum/design/component/action/pathfind,
		/datum/design/component/action/pull,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/programmed_server
	display_name = "Programmed Server"
	description = "Grants access to a server shell that has a very high capacity for components."
	prerequisite_nodes = list(/datum/techweb_node/bci)
	unlocked_designs = list(
		/datum/design/wiremod_shell/server,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
