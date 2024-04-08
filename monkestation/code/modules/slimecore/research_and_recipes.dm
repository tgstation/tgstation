/obj/item/circuitboard/machine/biomass_recycler
	name = "Biomass Recycler (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/biomass_recycler
	req_components = list(
		/datum/stock_part/matter_bin = 3,
		/datum/stock_part/manipulator = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/corral_corner
	name = "Corral Corner (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/corral_corner
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/manipulator = 1)
	needs_anchored = TRUE

/obj/item/circuitboard/machine/slime_extract_requestor
	name = "Extract Request Pad (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/slime_extract_requestor
	req_components = list(
		/datum/stock_part/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/computer/slime_market
	name = "Slime Market (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/slime_market

/obj/item/circuitboard/machine/slime_market_pad
	name = "Intergalactic Market Pad (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/slime_market_pad
	req_components = list(
		/datum/stock_part/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)


/datum/design/slimevac
	name = "Slime Vacuum"
	id = "slimevac"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5, /datum/material/glass =SMALL_MATERIAL_AMOUNT*0.5)
	build_path = /obj/item/vacuum_pack
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/slime_market_pad
	name = "Slime Market Pad Board"
	desc = "The circuit board for a slime market pad."
	id = "slime_market_pad"
	build_path = /obj/item/circuitboard/machine/slime_market_pad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/slime_market
	name = "Slime Market Computer Board"
	desc = "The circuit board for a slime market computer."
	id = "slime_market"
	build_path = /obj/item/circuitboard/computer/slime_market
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/slime_extract_requestor
	name = "Slime Extract Requestor Board"
	desc = "The circuit board for a slime extract requestor."
	id = "slime_extract_requestor"
	build_path = /obj/item/circuitboard/machine/slime_extract_requestor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/corral_corner
	name = "Corral Corner Board"
	desc = "The circuit board for a corral corner piece."
	id = "corral_corner"
	build_path = /obj/item/circuitboard/machine/corral_corner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/biomass_recycler
	name = "Biomass Recycler Board"
	desc = "The circuit board for a biomass recycler."
	id = "biomass_recycler"
	build_path = /obj/item/circuitboard/machine/biomass_recycler
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
