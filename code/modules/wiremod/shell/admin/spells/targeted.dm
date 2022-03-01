/obj/item/book/granter/spell/circuit/targeted
	name = "Targeted Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants a targeted spell."
	spell = /obj/effect/proc_holder/spell/targeted/circuit
	handler = /obj/item/circuit_component/spell_handler/targeted

/obj/item/circuit_component/spell_handler/targeted
	display_name = "Circuit Spellbook (Targeted)"

/obj/item/circuit_component/spell_handler/targeted/define_option_maps()
	. = ..()
	option_maps += list("random_target_priority" = list(
		"Closest" = TARGET_CLOSEST,
		"Random" = TARGET_RANDOM,
	))

/obj/item/circuit_component/spell_handler/targeted/populate_spell_var_ports()
	. = ..()
	spell_var_ports["max_targets"] = add_input_port("Max Targets", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["target_ignore_prev"] = add_input_port("Can Target Same Entity", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["include_user"] = add_input_port("Can Target Self", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["random_target"] = add_input_port("Select Random Targets", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["random_target_priority"] = add_option_port("Random Target Priority", assoc_to_keys(option_maps["random_target_priority"]), order = 7)

/obj/item/circuit_component/spell_handler/targeted/default_disabled_ports()
	. = ..()
	. += "random_target_priority"

/obj/item/circuit_component/spell_handler/targeted/handle_contextual_ports(datum/port/input/port, list/ports_to_disable, list/ports_to_enable)
	. = ..()
	if(port == spell_var_ports["random_target"])
		if(port.value)
			ports_to_enable |= "random_target_priority"
		else
			ports_to_disable |= "random_target_priority"

/obj/effect/proc_holder/spell/targeted/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/targeted/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	handler.on_spell_cast(src, user, targets)
