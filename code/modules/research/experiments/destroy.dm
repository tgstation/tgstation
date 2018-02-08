/datum/experiment_type/destroy
	name = "Obliterate"

/datum/experiment/destroy/flatten
	weight = 20
	experiment_type = /datum/experiment_type/destroy
	base_points = 250

/datum/experiment/destroy/flatten/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening the [O]!</span>")
	new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,E))))

/datum/experiment/destroy/spacetime_pull
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/destroy

/datum/experiment/destroy/spacetime_pull/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
	playsound(E, 'sound/effects/supermatter.ogg', 50, 1, -3)
	E.investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
	for(var/atom/movable/AM in oview(7,E))
		if(!AM.anchored)
			AM.throw_at(E,10,1)
	. = TRUE

/datum/experiment/destroy/spacetime_throw
	weight = 35
	is_bad = TRUE
	experiment_type = /datum/experiment_type/destroy

/datum/experiment/destroy/spacetime_throw/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E]'s crusher goes one level too high, crushing right into space-time!</span>")
	playsound(E, 'sound/effects/supermatter.ogg', 50, 1, -3)
	E.investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
	var/list/thrown_objects = list()
	for(var/atom/movable/AM in oview(7,E))
		if(!AM.anchored)
			thrown_objects += AM
	for(var/counter in 1 to thrown_objects.len)
		var/atom/movable/cast = thrown_objects[counter]
		cast.throw_at(pick(thrown_objects),10,1)
	. = TRUE