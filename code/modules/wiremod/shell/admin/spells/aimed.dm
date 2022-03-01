/obj/item/book/granter/spell/circuit/aimed
	name = "Aimed Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one grants an aimed spell."
	spell = /obj/effect/proc_holder/spell/aimed/circuit
	handler = /obj/item/circuit_component/spell_handler/aimed

/obj/item/circuit_component/spell_handler/aimed
	display_name = "Circuit Spellbook (Aimed)"
	var/datum/port/output/projectile_port
	var/datum/port/output/projectile_index_port
	var/datum/port/output/impact_angle_port
	var/datum/port/output/ready_projectile_signal

/obj/item/circuit_component/spell_handler/aimed/populate_ports()
	. = ..()
	projectile_port = add_output_port("Projectile", PORT_TYPE_ATOM)
	projectile_index_port = add_output_port("Index", PORT_TYPE_NUMBER)
	impact_angle_port = add_output_port("Impact Angle", PORT_TYPE_NUMBER)
	ready_projectile_signal = add_output_port("Prepare Projectile", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/spell_handler/aimed/get_additional_ui_notices()
	. = ..()
	. += create_ui_notice("On Cast is triggered by projectile impact.", "orange", "info")
	. += create_ui_notice("On Cast also sets: Projectile, Impact Angle", "orange", "info")
	. += create_ui_notice("Prepare Projectile sets: Projectile, Targets, User, Index", "orange", "info")

/obj/item/circuit_component/spell_handler/aimed/populate_spell_var_ports()
	. = ..()
	spell_var_ports["base_icon_state"] = add_input_port("Base Icon State", PORT_TYPE_STRING, order = 7)
	spell_var_ports["projectile_type"] = add_input_port("Projectile Type", PORT_TYPE_ANY, order = 7)
	spell_var_ports["deactive_msg"] = add_input_port("Discharge Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["active_msg"] = add_input_port("Charge Message", PORT_TYPE_STRING, order = 7)
	spell_var_ports["active_icon_state"] = add_input_port("Active Icon State", PORT_TYPE_STRING, order = 7)
	spell_var_ports["projectile_amount"] = add_input_port("Projectiles Per Cast", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["projectiles_per_fire"] = add_input_port("Projectiles Per Fire", PORT_TYPE_NUMBER, order = 7)
	spell_var_ports["projectile_var_overrides"] = add_input_port("Projectile Var Overrides", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY), order = 7)

/obj/effect/proc_holder/spell/aimed/circuit
	var/obj/item/circuit_component/spell_handler/handler

/obj/effect/proc_holder/spell/aimed/circuit/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	. = ..()
	RegisterSignal(P, COMSIG_PROJECTILE_ON_HIT, .proc/on_projectile_impact)
	var/obj/item/circuit_component/spell_handler/aimed/aimed_handler = handler
	if(!istype(aimed_handler))
		return
	SScircuit_component.queue_instant_run()
	aimed_handler.projectile_port.set_output(P)
	aimed_handler.targets_port.set_output(list(target))
	aimed_handler.user_port.set_output(user)
	aimed_handler.projectile_index_port.set_output(iteration)
	aimed_handler.ready_projectile_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()

/obj/effect/proc_holder/spell/aimed/circuit/proc/on_projectile_impact(datum/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	if(!istype(handler))
		return
	SScircuit_component.queue_instant_run()
	handler.spell_ref_port.set_output(src)
	handler.targets_port.set_output(list(target))
	handler.user_port.set_output(firer)
	var/obj/item/circuit_component/spell_handler/aimed/aimed_handler = handler
	if(!istype(aimed_handler))
		return
	aimed_handler.impact_angle_port.set_output(angle)
	aimed_handler.projectile_port.set_output(source)
	SScircuit_component.execute_instant_run()
