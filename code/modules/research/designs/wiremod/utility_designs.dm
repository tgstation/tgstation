/datum/design/component/utility
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_UTILITY_COMPONENTS
	)

/datum/design/component/utility/router
	name = "Router Component"
	id = "comp_router"
	build_path = /obj/item/circuit_component/router

/datum/design/component/utility/multiplexer
	name = "Multiplexer Component"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/router/multiplexer

/datum/design/component/utility/typecast
	name = "Typecast Component"
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/typecast

/datum/design/component/utility/clock
	name = "Clock Component"
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/utility/delay
	name = "Delay Component"
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/utility/timepiece
	name = "Timepiece Component"
	id = "comp_timepiece"
	build_path = /obj/item/circuit_component/timepiece

/datum/design/component/utility/typecheck
	name = "Typecheck Component"
	id = "comp_typecheck"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/utility/wire_bundle
	name = "Wire Bundle"
	id = "comp_wire_bundle"
	build_path = /obj/item/circuit_component/wire_bundle

/datum/design/component/utility/setter_trigger
	name = "Set Variable Trigger"
	id = "comp_set_variable_trigger"
	build_path = /obj/item/circuit_component/variable/setter/trigger
