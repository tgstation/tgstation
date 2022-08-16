/**
  * ### Liquid Fuel Engines
  * Turns a specific reagent or reagents into thrust.
  */
/obj/machinery/power/shuttle/engine/liquid
	name = "liquid thruster"
	desc = "A thruster that burns reagents stored in the engine for fuel."
	///How much fuel can be loaded into the engine.
	var/max_reagents = 0
	///What reagent is consumed to burn the engine, and how much is needed.
	var/list/datum/reagent/fuel_reagents
	///Used to store how much total of any reagent is needed per burn. Don't set anywhere but /Initialize()
	var/reagent_amount_holder = 0

/obj/machinery/power/shuttle/engine/liquid/Initialize()
	. = ..()
	create_reagents(max_reagents, OPENCONTAINER)
	AddComponent(/datum/component/plumbing/simple_demand)
	for(var/reagent in fuel_reagents)
		reagent_amount_holder += fuel_reagents[reagent]

/obj/machinery/power/shuttle/engine/liquid/burn_engine(percentage = 100)
	. = ..()
	var/true_percentage = 1
	for(var/reagent in fuel_reagents)
		true_percentage *= reagents.remove_reagent(reagent, fuel_reagents[reagent]) / fuel_reagents[reagent]
	return thrust * true_percentage

/obj/machinery/power/shuttle/engine/liquid/return_fuel()
	var/true_percentage = INFINITY
	for(var/reagent in fuel_reagents)
		true_percentage = min(reagents.get_reagent_amount(reagent) / fuel_reagents[reagent], true_percentage)
	return reagent_amount_holder * true_percentage //Multiplies the total amount needed by the smallest percentage of any reagent in the recipe

/obj/machinery/power/shuttle/engine/liquid/return_fuel_cap()
	return reagents.maximum_volume

/obj/machinery/power/shuttle/engine/liquid/oil
	name = "oil thruster"
	desc = "A highly inefficient thruster that burns oil as a propellant."
	max_reagents = 1000
	thrust = 20
	fuel_reagents = list(/datum/reagent/fuel/oil = 50)
	circuit = /obj/item/circuitboard/machine/shuttle/engine/oil
