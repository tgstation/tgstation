/datum/design/component/list
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_LIST_COMPONENTS
	)

/datum/design/component/list/format
	name = "Format List Component"
	id = "comp_format"
	build_path = /obj/item/circuit_component/format

/datum/design/component/list/format_assoc
	name = "Format Associative List Component"
	id = "comp_format_assoc"
	build_path = /obj/item/circuit_component/format/assoc

/datum/design/component/list/index
	name = "Index Component"
	id = "comp_index"
	build_path = /obj/item/circuit_component/index

/datum/design/component/list/index_assoc
	name = "Index Associative List Component"
	id = "comp_index_assoc"
	build_path = /obj/item/circuit_component/index/assoc_string

/datum/design/component/list/index_table
	name = "Index Table Component"
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table

/datum/design/component/list/get_column
	name = "Get Column Component"
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column

/datum/design/component/list/select_query
	name = "Select Query Component"
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select

/datum/design/component/list/concat
	name = "Concatenate List Component"
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list

/datum/design/component/list/add
	name = "List Add"
	id = "comp_list_add"
	build_path = /obj/item/circuit_component/variable/list/listadd

/datum/design/component/list/remove
	name = "List Remove"
	id = "comp_list_remove"
	build_path = /obj/item/circuit_component/variable/list/listremove

/datum/design/component/list/assoc_list_set
	name = "Associative List Set"
	id = "comp_assoc_list_set"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_set

/datum/design/component/list/assoc_list_remove
	name = "Associative List Remove"
	id = "comp_assoc_list_remove"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_remove

/datum/design/component/list/clear
	name = "List Clear"
	id = "comp_list_clear"
	build_path = /obj/item/circuit_component/variable/list/listclear

/datum/design/component/list/find
	name = "Element Find"
	id = "comp_element_find"
	build_path = /obj/item/circuit_component/listin

/datum/design/component/list/literal
	name = "List Literal Component"
	id = "comp_list_literal"
	build_path = /obj/item/circuit_component/list_literal

/datum/design/component/list/assoc_literal
	name = "Associative List Literal"
	id = "comp_list_assoc_literal"
	build_path = /obj/item/circuit_component/assoc_literal

/datum/design/component/list/filter
	name = "Filter List Component"
	id = "comp_filter_list"
	build_path = /obj/item/circuit_component/filter_list

/datum/design/component/list/pick
	name = "List Pick Component"
	id = "comp_list_pick"
	build_path = /obj/item/circuit_component/list_pick

/datum/design/component/list/pick_assoc
	name = "Associative List Pick Component"
	id = "comp_assoc_list_pick"
	build_path = /obj/item/circuit_component/list_pick/assoc

/datum/design/component/list/foreach
	name = "For Each Component"
	id = "comp_foreach"
	build_path = /obj/item/circuit_component/foreach

/datum/design/component/list/split
	name = "Split Component"
	id = "comp_split"
	build_path = /obj/item/circuit_component/split
