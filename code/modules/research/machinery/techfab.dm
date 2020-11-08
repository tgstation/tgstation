/obj/machinery/rnd/production/techfab
	name = "technology fabricator"
	desc = "Produces researched prototypes with raw materials and energy."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab
	categories = CATEGORIES_TECHFAB
	console_link = FALSE
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE | IMPRINTER
	time_coeff = 1.2
	component_coeff = 1.2
	uses_regents = TRUE
	
/obj/machinery/rnd/production/techfab/RefreshParts()
	var/T = 0
	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	rmat.set_local_size((200000 + (T*50000)))

	// Unlike the mechfab we don't got lasers so the manipulators control
	// both the speed and consumption of materials
	T = initial(time_coeff)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T = clamp(T - (M.rating * 0.1), 0, 1)
	T = T ?  1/T : INFINITY

	time_coeff = component_coeff = T
	. = ..()



