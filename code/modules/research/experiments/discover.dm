/datum/experiment_type/discover
	name = "Analyse"
	//If relics turn out to be too powerful you can lock Discover behind some other experiment

/datum/experiment/discover
	weight = 800
	experiment_type = /datum/experiment_type/discover

/datum/experiment/discover/init()
	valid_types = typecacheof(/obj/item/relic)

/datum/experiment/discover/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && istype(O,/obj/item/relic))
		. = is_relic_undiscovered(O)

/datum/experiment/discover/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("[E] scans the [O], revealing its true nature!")
	E.investigate_log("Experimentor has revealed a relic.", INVESTIGATE_EXPERIMENTOR)
	playsound(E, 'sound/effects/supermatter.ogg', 50, 3, -1)
	var/obj/item/relic/R = O
	R.reveal()
	E.eject_item()

/datum/experiment/analyse_relic
	weight = 800
	experiment_type = /datum/experiment_type/discover
	var/busy = FALSE

/datum/experiment/analyse_relic/init()
	valid_types = typecacheof(/obj/item/relic)

/datum/experiment/analyse_relic/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && istype(O,/obj/item/relic) && !busy)
		. = !is_relic_undiscovered(O)

/datum/experiment/analyse_relic/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("[E] scans the [O].")
	busy = TRUE
	addtimer(CALLBACK(src, .proc/report, E, O), rand(20,100))

/datum/experiment/analyse_relic/proc/report(obj/machinery/rnd/experimentor/E,obj/item/O)
	if(!QDELETED(O) && !QDELETED(E))
		var/obj/item/paper/P = new(get_turf(E))

		P.name = "analysis result of [O.name] - #[rand(1000,9999)]"
		P.info += "<h2>Analysis Result of [O.name]</h2>"
		P.info += "<hr/>"
		P.info += "Classification: [initial(O.name)]<br/>"
		P.info += "Robustness: [get_robustness(max(O.throwforce,O.force))]<br/>"
		P.info += "<br/>"
		P.info += "Composition:<br/>"
		if(!LAZYLEN(O.materials))
			P.info += "- Unknown<br/>"
		else
			for(var/material in O.materials)
				P.info += "- [O.materials[material]] cm3 of [material]<br/>"
		P.info += "<hr/>"
		var/datum/component/relic/comp = O.GetComponent(/datum/component/relic)
		if(comp && comp.my_type)
			for(var/datum/relic_effect/eff in comp.my_type.added_effects)
				if(eff.hint)
					P.info += pick(eff.hint)

		P.update_icon()
		E.visible_message("[E] pops out a piece of paper filled with schematics and diagrams.")
	busy = FALSE

/datum/experiment/analyse_relic/proc/get_robustness(force)
	switch(force)
		if(-INFINITY to 0)
			return "worthless"
		if(1 to 10)
			return "weak"
		if(10 to 15)
			return "makeshift"
		if(15 to 25)
			return "robust"
		if(25 to INFINITY)
			return "exceptionally robust"