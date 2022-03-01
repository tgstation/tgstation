/obj/item/book/granter/spell/circuit/aoe_turf
	name = "AoE Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants an area-of-effect spell."
	spell = /obj/effect/proc_holder/spell/aoe_turf/circuit
	handler = /obj/item/circuit_component/spell_handler/aoe_turf

/obj/item/circuit_component/spell_handler/aoe_turf
	display_name = "Circuit Spellbook (AoE)"

/obj/item/circuit_component/spell_handler/aoe_turf/populate_spell_var_ports()
	. = ..()
	spell_var_ports["inner_radius"] = add_input_port("Inner Radius", PORT_TYPE_NUMBER, order = 7)

/obj/effect/proc_holder/spell/aoe_turf/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/aoe_turf/circuit/cast(list/targets, mob/user)
	if(!istype(handler))
		return
	handler.on_spell_cast(src, user, targets)
