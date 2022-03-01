/obj/item/book/granter/spell/circuit/cone
	name = "Cone Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a conical spell."
	spell = /obj/effect/proc_holder/spell/cone/circuit
	handler = /obj/item/circuit_component/spell_handler/cone

/obj/item/circuit_component/spell_handler/cone
	display_name = "Circuit Spellbook (Cone)"
	var/datum/port/output/turf_target_output
	var/datum/port/output/obj_target_output
	var/datum/port/output/mob_target_output
	var/datum/port/output/distance_output
	var/datum/port/output/turf_target_signal
	var/datum/port/output/obj_target_signal
	var/datum/port/output/mob_target_signal

/obj/item/circuit_component/spell_handler/cone/populate_spell_var_ports()
	. = ..()
	spell_var_ports["cone_levels"] = add_input_port("Distance", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["respect_density"] = add_input_port("Blocked By Walls", PORT_TYPE_NUMBER, order = 7)

/obj/item/circuit_component/spell_handler/cone/populate_additional_output_ports()
	spell_cast_signal = add_output_port("On Initial Cast", PORT_TYPE_INSTANT_SIGNAL)
	distance_output = add_output_port("Distance", PORT_TYPE_NUMBER)
	turf_target_output = add_output_port("Turf", PORT_TYPE_ATOM)
	turf_target_signal = add_output_port("Turf Effect", PORT_TYPE_INSTANT_SIGNAL)
	obj_target_output = add_output_port("Object", PORT_TYPE_ATOM)
	obj_target_signal = add_output_port("Object Effect", PORT_TYPE_INSTANT_SIGNAL)
	mob_target_output = add_output_port("Mob", PORT_TYPE_ATOM)
	mob_target_signal = add_output_port("Mob Effect", PORT_TYPE_INSTANT_SIGNAL)

/obj/item/circuit_component/spell_handler/cone/get_additional_ui_notices()
	. = list()
	. += create_ui_notice("Turf Effect sets: Turf, Distance", "orange", "info")
	. += create_ui_notice("Object Effect sets: Object, Distance", "orange", "info")
	. += create_ui_notice("Mob Effect sets: Mob, Distance", "orange", "info")
	. += create_ui_notice("All signals also set: Spell, User", "orange", "info")

/obj/effect/proc_holder/spell/cone/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/cone/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	SScircuit_component.queue_instant_run()
	handler.spell_ref_port.set_output(src)
	handler.user_port.set_output(user)
	handler.spell_cast_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()
	. = ..()

/obj/effect/proc_holder/spell/cone/circuit/do_turf_cone_effect(turf/target_turf, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.turf_target_output.set_output(target_turf)
	cone_handler.distance_output.set_output(level)
	cone_handler.turf_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/cone/circuit/do_obj_cone_effect(obj/target_obj, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.obj_target_output.set_output(target_obj)
	cone_handler.distance_output.set_output(level)
	cone_handler.obj_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/cone/circuit/do_mob_cone_effect(mob/living/target_mob, level)
	var/obj/item/circuit_component/spell_handler/cone/cone_handler = handler
	if(!istype(cone_handler))
		return
	SScircuit_component.queue_instant_run()
	cone_handler.mob_target_output.set_output(target_mob)
	cone_handler.distance_output.set_output(level)
	cone_handler.mob_target_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()
