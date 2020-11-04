/obj/machinery/rnd/production/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter
	categories = list(
		CATEGORY_AI_MODULES	= list(),
		CATEGORY_COMPUTER_BOARDS = list(),
		CATEGORY_MACHINERY_TELEPORTATION = list(),
		CATEGORY_MACHINERY_MEDICAL = list(),
		CATEGORY_MACHINERY_ENGINEERING = list(),
		CATEGORY_EXOSUIT_MODULES = list(),
		CATEGORY_MACHINERY_HYDRO = list(),
		CATEGORY_SUBSPACE_TELECOMS = list(),
		CATEGORY_MACHINERY_RESEARCH = list(),
		CATEGORY_MACHINERY_MISC = list(),
		CATEGORY_COMPUTER_PARTS = list()
		)
	production_animation = "circuit_imprinter_ani"
	allowed_buildtypes = IMPRINTER

/obj/machinery/rnd/production/circuit_imprinter/calculate_efficiency()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating * 2			//There is only one.
	total_rating = max(1, total_rating)
	efficiency_coeff = total_rating

