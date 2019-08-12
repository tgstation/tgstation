///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents seperated and only reacts under your given terms
/obj/machinery/plumbing/reaction_chamber
	name = "reaction chamber"
	desc = "Keeps chemicals seperated until given conditions are met."
	icon_state = "reaction_chamber"

	buffer = 100
	reagent_flags = TRANSPARENT | NOREACT
	/**list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/oil = 50)
	*//
	var/list/required_reagents = list()
	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE


/obj/machinery/plumbing/reaction_chamber/Initialize()
	. = ..()
/*
/obj/machinery/plumbing/reaction_chamber/send_request(dir, lazy_amount = TRUE)
	for(var/RT in required_reagents)
		for(var/A in reagents.reagent_list)
			var/datum/reagent/RD = A
			if(RT == RD.type && required_reagents[RT] < RD.amount)

				process_request(amount = 10, reagent = null, dir = dir, lazy_amount = lazy_amount)*/