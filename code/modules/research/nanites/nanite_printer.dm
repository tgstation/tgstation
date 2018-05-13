/obj/machinery/rnd/production/nanite_printer
	name = "nanite printer"
	desc = "Manufactures injectors containing pattern nanites."
	icon_state = "nanite_printer"
	container_type = OPENCONTAINER
	circuit = /obj/item/circuitboard/machine/nanite_printer
	categories = list(
						"Utility Nanites",
						"Medical Nanites",
						"Augmentation Nanites',
						"Dangerous Nanites",
						"Suppression Nanites"
						)
	production_animation = "nanite_printer_ani"
	allowed_buildtypes = NANITE_PRINTER

/obj/machinery/rnd/production/circuit_imprinter/disconnect_console()
	linked_console.linked_imprinter = null
	..()

/obj/machinery/rnd/production/circuit_imprinter/calculate_efficiency()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating * 2			//There is only one.
	total_rating = max(1, total_rating)
	efficiency_coeff = total_rating