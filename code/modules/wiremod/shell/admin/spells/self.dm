/obj/item/book/granter/spell/circuit/self
	name = "Self Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a self-affecting spell."
	spell = /obj/effect/proc_holder/spell/self/circuit
	handler = /obj/item/circuit_component/spell_handler/self

/obj/item/circuit_component/spell_handler/self
	display_name = "Circuit Spellbook (Self)"

/obj/item/circuit_component/spell_handler/self/populate_additional_output_ports()
	spell_cast_signal = add_output_port("On Cast", PORT_TYPE_INSTANT_SIGNAL)

/obj/item/circuit_component/spell_handler/self/get_additional_ui_notices()
	return create_ui_notice("On Cast sets: User, Spell", "orange", "info")

/obj/item/circuit_component/spell_handler/self/on_spell_cast(obj/effect/proc_holder/spell, mob/user, list/targets)
	SScircuit_component.queue_instant_run()
	spell_ref_port.set_output(spell)
	user_port.set_output(user)
	spell_cast_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/self/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/self/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	handler.on_spell_cast(src, user)
