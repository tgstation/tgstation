/datum/design/component/utility
	abstract_type = /datum/design/component/utility
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_UTILITY_COMPONENTS
	)

/datum/design/component/utility/router
	name = "Router Component"
	build_path = /obj/item/circuit_component/router

/datum/design/component/utility/multiplexer
	name = "Multiplexer Component"
	build_path = /obj/item/circuit_component/router/multiplexer

/datum/design/component/utility/typecast
	name = "Typecast Component"
	build_path = /obj/item/circuit_component/typecast

/datum/design/component/utility/clock
	name = "Clock Component"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/utility/delay
	name = "Delay Component"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/utility/timepiece
	name = "Timepiece Component"
	build_path = /obj/item/circuit_component/timepiece

/datum/design/component/utility/typecheck
	name = "Typecheck Component"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/utility/wire_bundle
	name = "Wire Bundle"
	build_path = /obj/item/circuit_component/wire_bundle

/datum/design/component/utility/setter_trigger
	name = "Set Variable Trigger"
	build_path = /obj/item/circuit_component/variable/setter/trigger
