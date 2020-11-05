/obj/machinery/rnd/production/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter
	categories = list(
		CATEGORY_AI_MODULES,
		CATEGORY_COMPUTER_BOARDS,
		CATEGORY_MACHINERY_TELEPORTATION,
		CATEGORY_MACHINERY_MEDICAL,
		CATEGORY_MACHINERY_ENGINEERING,
		CATEGORY_EXOSUIT_MODULES,
		CATEGORY_MACHINERY_HYDRO,
		CATEGORY_SUBSPACE_TELECOMS,
		CATEGORY_MACHINERY_RESEARCH,
		CATEGORY_MACHINERY_MISC,
		CATEGORY_COMPUTER_PARTS
		)
	production_animation = "circuit_imprinter_ani"
	allowed_buildtypes = IMPRINTER

#if 0
/obj/machinery/rnd/production/circuit_imprinter/proc/calculate_efficiency()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating * 2			//There is only one.
	total_rating = max(1, total_rating)
	efficiency_coeff = total_rating
#endif

