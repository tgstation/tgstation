/obj/machinery/rnd/production/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter
	categories = CATEGORIES_CIRCUIT_IMPRINTER
	production_animation = "circuit_imprinter_ani"
	allowed_buildtypes = IMPRINTER
	uses_regents = TRUE

/obj/machinery/rnd/production/circuit_imprinter/RefreshParts()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating * 2			//There is only one.
	total_rating = max(1, total_rating)
	time_coeff = component_coeff = total_rating
	. = ..()


