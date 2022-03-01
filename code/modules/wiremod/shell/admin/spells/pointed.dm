/obj/item/book/granter/spell/circuit/pointed
	name = "Pointed Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a pointed spell."
	spell = /obj/effect/proc_holder/spell/pointed/circuit
	handler = /obj/item/circuit_component/spell_handler/pointed

/obj/item/circuit_component/spell_handler/pointed
	display_name = "Circuit Spellbook (Pointed)"

/obj/item/circuit_component/spell_handler/pointed/populate_spell_var_ports()
	. = ..()
	spell_var_ports["ranged_mousepointer"] = add_input_port("Reticle", PORT_TYPE_ANY, order = 7)
	spell_var_ports["deactive_msg"] = add_input_port("Dispel Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["active_msg"] = add_input_port("Activation Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["self_castable"] = add_input_port("Castable On Self", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["aim_assist"] = add_input_port("Aim Assist", PORT_TYPE_NUMBER, order = 7)

/obj/effect/proc_holder/spell/pointed/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/pointed/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	handler.on_spell_cast(src, user, targets)
