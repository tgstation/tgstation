/obj/machinery/vending/Initialize(mapload)
	. = ..()
	onstation = FALSE
	if(circuit)
		circuit.onstation = FALSE
