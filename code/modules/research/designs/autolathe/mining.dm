// Autolathe-able circuitboards for starting with boulder processing machines.
/datum/design/board/smelter
	name = "Boulder Smelter Board"
	desc = "A circuitboard for a boulder smelter. Lowtech enough to be printed from the lathe."
	id = "b_smelter"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/smelter
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/refinery
	name = "Boulder Refinery Board"
	desc = "A circuitboard for a boulder refinery. Lowtech enough to be printed from the lathe."
	id = "b_refinery"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/refinery
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO
