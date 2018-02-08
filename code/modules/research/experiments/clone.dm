/datum/experiment_type/clone
	name = "Clone"
	hidden = TRUE
	var/uses = 0

/datum/experiment/clone
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/clone

/datum/experiment/clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(uses <= 0)
		. = FALSE

/datum/experiment/clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='notice'>A duplicate [O] pops out!</span>")
	E.investigate_log("Experimentor has cloned [O]", INVESTIGATE_EXPERIMENTOR)
	E.eject_item()
	var/turf/T = get_turf(pick(oview(1,src)))
	new O.type(T)
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(mode)
		mode.uses--