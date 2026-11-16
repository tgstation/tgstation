/datum/design/component/list
	abstract_type = /datum/design/component/list
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_LIST_COMPONENTS
	)

/datum/design/component/list/format
	name = "Format List Component"
	build_path = /obj/item/circuit_component/format

/datum/design/component/list/format_assoc
	name = "Format Associative List Component"
	build_path = /obj/item/circuit_component/format/assoc

/datum/design/component/list/index
	name = "Index Component"
	build_path = /obj/item/circuit_component/index

/datum/design/component/list/index_assoc
	name = "Index Associative List Component"
	build_path = /obj/item/circuit_component/index/assoc_string

/datum/design/component/list/index_table
	name = "Index Table Component"
	build_path = /obj/item/circuit_component/index_table

/datum/design/component/list/get_column
	name = "Get Column Component"
	build_path = /obj/item/circuit_component/get_column

/datum/design/component/list/select_query
	name = "Select Query Component"
	build_path = /obj/item/circuit_component/select

/datum/design/component/list/concat
	name = "Concatenate List Component"
	build_path = /obj/item/circuit_component/concat_list

/datum/design/component/list/add
	name = "List Add"
	build_path = /obj/item/circuit_component/variable/list/listadd

/datum/design/component/list/remove
	name = "List Remove"
	build_path = /obj/item/circuit_component/variable/list/listremove

/datum/design/component/list/assoc_list_set
	name = "Associative List Set"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_set

/datum/design/component/list/assoc_list_remove
	name = "Associative List Remove"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_remove

/datum/design/component/list/clear
	name = "List Clear"
	build_path = /obj/item/circuit_component/variable/list/listclear

/datum/design/component/list/find
	name = "Element Find"
	build_path = /obj/item/circuit_component/listin

/datum/design/component/list/literal
	name = "List Literal Component"
	build_path = /obj/item/circuit_component/list_literal

/datum/design/component/list/assoc_literal
	name = "Associative List Literal"
	build_path = /obj/item/circuit_component/assoc_literal

/datum/design/component/list/filter
	name = "Filter List Component"
	build_path = /obj/item/circuit_component/filter_list

/datum/design/component/list/pick
	name = "List Pick Component"
	build_path = /obj/item/circuit_component/list_pick

/datum/design/component/list/pick_assoc
	name = "Associative List Pick Component"
	build_path = /obj/item/circuit_component/list_pick/assoc

/datum/design/component/list/foreach
	name = "For Each Component"
	build_path = /obj/item/circuit_component/foreach

/datum/design/component/list/split
	name = "Split Component"
	build_path = /obj/item/circuit_component/split
