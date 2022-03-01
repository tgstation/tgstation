/obj/item/book/granter/spell/circuit/cone/staggered
	name = "Staggered Cone Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a staggered conical spell."
	spell = /obj/effect/proc_holder/spell/cone/staggered/circuit

/obj/effect/proc_holder/spell/cone/staggered/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/cone/staggered/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	SScircuit_component.queue_instant_run()
	handler.spell_ref_port.set_output(src)
	handler.user_port.set_output(user)
	handler.spell_cast_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()
	. = ..()

/obj/effect/proc_holder/spell/cone/staggered/circuit/do_turf_cone_effect(turf/target_turf, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.turf_target_output.set_output(target_turf)
	cone_handler.distance_output.set_output(level)
	cone_handler.turf_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/cone/staggered/circuit/do_obj_cone_effect(obj/target_obj, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.obj_target_output.set_output(target_obj)
	cone_handler.distance_output.set_output(level)
	cone_handler.obj_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/cone/staggered/circuit/do_mob_cone_effect(mob/living/target_mob, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.mob_target_output.set_output(target_mob)
	cone_handler.distance_output.set_output(level)
	cone_handler.mob_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()
