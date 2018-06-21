/datum/experiment_type/clone
	name = "Clone"
	hidden = TRUE
	var/uses = 0

/datum/experiment/clone
	weight = 50
	experiment_type = /datum/experiment_type/clone

/datum/experiment/clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(!mode || mode.uses <= 0)
		. = FALSE

/datum/experiment/clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='notice'>A duplicate [O] pops out!</span>")
	E.investigate_log("Experimentor has cloned [O]", INVESTIGATE_EXPERIMENTOR)
	var/turf/T = get_turf(pick(oview(1,E)))
	new O.type(T)
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(mode)
		mode.uses--

/datum/experiment/bad_clone
	weight = 800
	is_bad = TRUE
	experiment_type = /datum/experiment_type/clone

/datum/experiment/bad_clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(!mode || mode.uses <= 0)
		. = FALSE
	if(is_type_in_typecache(O, GLOB.critical_items) && is_valid_critical(O)) //crit items cant be badcloned
		. = FALSE

/datum/experiment/bad_clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='notice'>A duplicate [O] pops out!</span>")
	E.investigate_log("Experimentor has cloned [O], but it will melt sometime soon.", INVESTIGATE_EXPERIMENTOR)
	E.eject_item()
	var/turf/T = get_turf(pick(oview(1,E)))
	var/obj/item/NO = new O.type(T)
	addtimer(CALLBACK(src, .proc/melt, NO), rand(10,150) ** 2)
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(mode)
		mode.uses--

/datum/experiment/bad_clone/proc/melt(obj/item/O)
	O.visible_message("<span class='notice'>[O] melts into a puddle of grey slag.</span>")
	new /obj/effect/decal/cleanable/molten_object(get_turf(O))
	qdel(O)

/datum/experiment/destroy/clone //no cloning valuable items without being careful
	weight = 800
	is_bad = TRUE
	experiment_type = /datum/experiment_type/clone

/datum/experiment/vaporize/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(!mode || mode.uses <= 0)
		. = FALSE
	if(is_type_in_typecache(O, GLOB.critical_items) && is_valid_critical(O))
		. = FALSE

/datum/experiment/vaporize/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	E.visible_message("<span class='danger'>[E] malfunctions, vaporizing [O]!</span>")
	. = ..()