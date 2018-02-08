/datum/experiment_type/radiate
	name = "Irradiate"

/datum/experiment/enable_clone
	weight = 20
	experiment_type = /datum/experiment_type/radiate
	base_points = 250

/datum/experiment/enable_clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		return web.all_experiment_types[/datum/experiment_type/clone].hidden //Only perform if clonemode is not enabled


/datum/experiment/enable_clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		var/datum/experiment_type/clone/mode = web.all_experiment_types[/datum/experiment_type/clone]
		mode.hidden = FALSE
		mode.uses = E.bad_thing_coeff
		E.experiments |= mode //Give it to this experimentor. Others need to relink to unlock.

		E.visible_message("[E] has activated an unknown subroutine!")
		playsound(E, 'sound/effects/genetics.ogg', 50, 1)