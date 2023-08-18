/obj/machinery/power/port_gen/pacman
	time_per_sheet = 260

/obj/machinery/power/port_gen/pacman/on_construction(mob/user)
	. = ..()
	var/obj/item/circuitboard/machine/pacman/our_board = circuit
	if(our_board.high_production_profile)
		power_gen = 15000
		time_per_sheet = 85
		max_sheets = 20


/obj/machinery/power/port_gen/pacman/RefreshParts()
	. = ..()
	var/temp_rating = 0
	var/consumption_coeff = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/stock_parts/capacitor))
			temp_rating += SP.rating
		else
			consumption_coeff += SP.rating
	power_gen = round(initial(power_gen) * temp_rating * 2)
	consumption = consumption_coeff
