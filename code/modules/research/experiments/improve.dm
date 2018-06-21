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

/datum/experiment/improve/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/success = FALSE
	var/originalname = O.name
	if(istype(O, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = O
		C.maxcharge *= 2
		C.charge *= 2
		C.chargerate *= 2
		success = TRUE
	else if(istype(O, /obj/item/stock_parts))
		var/obj/item/stock_parts/P = O
		if(P.rating == initial(P.rating)) //because someone's going to try to get T100+ parts
			P.rating *= 2
			if(!findtext(P.name, "improved"))
				P.name = "improved " + P.name
			success = TRUE
		else
			E.say("Object already advanced to limit of current knowledge.")
	else
		E.say("Unknown object, unable to modify.")

	if(success)
		E.visible_message("<span class='notice'>[E] uses its data to improve the [originalname]!</span>")
		E.investigate_log("Experimentor has improved [originalname]", INVESTIGATE_EXPERIMENTOR)
		var/datum/experiment_type/improve/mode = E.experiments[/datum/experiment_type/improve]
		if(mode)
			mode.uses--