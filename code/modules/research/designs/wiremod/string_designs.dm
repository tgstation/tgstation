/datum/design/component/string
	abstract_type = /datum/design/component/string
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_STRING_COMPONENTS
	)

/datum/design/component/string/tostring
	name = "To String Component"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/string/tonumber
	name = "To Number"
	build_path = /obj/item/circuit_component/tonumber

/datum/design/component/string/concat
	name = "Concatenation Component"
	build_path = /obj/item/circuit_component/concat

/datum/design/component/string/textcase
	name = "Textcase Component"
	build_path = /obj/item/circuit_component/textcase

/datum/design/component/string/contains
	name = "String Contains Component"
	build_path = /obj/item/circuit_component/compare/contains

/datum/design/component/string/replace
	name = "String Replace Component"
	build_path = /obj/item/circuit_component/compare/contains/replace
