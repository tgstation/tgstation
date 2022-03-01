/obj/item/book/granter/spell/circuit/touch
	name = "Touch Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a touch spell."
	spell = /obj/effect/proc_holder/spell/targeted/touch/circuit
	handler = /obj/item/circuit_component/spell_handler/touch

/obj/item/circuit_component/spell_handler/touch
	display_name = "Circuit Spellbook (Touch)"
	var/datum/port/output/click_param_output

/obj/item/circuit_component/spell_handler/touch/populate_spell_var_ports()
	. = ..()
	spell_var_ports["hand_path"] = add_input_port("Hand Type", PORT_TYPE_ANY, order = 7)
	spell_var_ports["drawmessage"] = add_input_port("Draw Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["dropmessage"] = add_input_port("Drop Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["hand_var_overrides"] = add_input_port("Hand Var Overrides", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY), order = 7)

/obj/item/circuit_component/spell_handler/touch/populate_additional_output_ports()
	. = ..()
	click_param_output = add_output_port("Click Params", PORT_TYPE_STRING)

/obj/effect/proc_holder/spell/targeted/touch/circuit
	var/obj/item/circuit_component/spell_handler/handler
	var/list/hand_var_overrides = list()

/obj/effect/proc_holder/spell/targeted/touch/circuit/ChargeHand(mob/living/carbon/user)
	. = ..()
	if(!.)
		return
	for(var/variable in hand_var_overrides)
		if(variable in attached_hand.vars)
			attached_hand.vv_edit_var(variable, hand_var_overrides[variable])
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, .proc/on_afterattack)

/obj/effect/proc_holder/spell/targeted/touch/circuit/proc/on_afterattack(datum/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	handler?.on_spell_cast(src, user, list(target), click_parameters)
