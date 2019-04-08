//***********
//Percdonalds
//***********


//********
//Machines
//********
/obj/machinery/chem_dispenser/cooking
	name = "kitchen reagent dispenser"
	desc = "The greatest appliance all chefs should have."
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	amount = 25
	working_state = "minidispenser_working"
	nopower_state = "minidispenser_nopower"
	dispensable_reagents = list(
		"water",
		"flour",
		"milk",
		"soymilk",
		"cream",
		"ketchup",
		"sugar",
		"eggyolk"
	)
	circuit = /obj/item/circuitboard/machine/chem_dispenser/cooking

/obj/item/circuitboard/machine/chem_dispenser/cooking
	name = "Kitchen reagent Dispenser (Machine Board)"
	build_path = /obj/machinery/chem_dispenser/cooking

/obj/machinery/smartfridge/vegetables/New()
	initial_contents = list()
	var/list/possible_boxes = subtypesof(/obj/item/reagent_containers/food/snacks/grown)
	for(var/T in possible_boxes)
		for(var/i=5,i>0,i--)
			initial_contents += T
	. = ..()

//********
//Clothing
//********

