/datum/experiment_type/improve
	name = "Improve"
	hidden = TRUE
	var/uses = 0

/datum/experiment/improve
	weight = 800
	experiment_type = /datum/experiment_type/improve

/datum/experiment/improve/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/improve/mode = E.experiments[/datum/experiment_type/improve]
	if(!mode || mode.uses <= 0)
		. = FALSE

/datum/experiment/clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()

	//E.eject_item() //experimental

	if(istype(O, /obj/item/stock_parts))
		var/obj/item/stock_parts/P = O
		if(P.rating <= 4)
			P.rating *= 3
			E.visible_message("<span class='notice'>[E] uses its data to optimize [P]!</span>")
			E.investigate_log("Experimentor has improved [O]", INVESTIGATE_EXPERIMENTOR)
			P.name = "improved " + P.name

			var/datum/experiment_type/improve/mode = E.experiments[/datum/experiment_type/improve]
			if(mode)
				mode.uses--
		else
			E.say("Object already improved.")
	else
		E.say("Unable to improve object.")
