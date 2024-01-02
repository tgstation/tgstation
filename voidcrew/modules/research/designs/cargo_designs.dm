//we are overwriting TG's design for this, everything but the board is already from parent, but I put it here for more readability.
/datum/design/board/cargo
	build_path = /obj/item/circuitboard/computer/voidcrew_cargo

	name = "Supply Console Board"
	desc = "Allows for the construction of circuit boards used to build a Supply Console."
	id = "cargo"
	build_type = IMPRINTER
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO
