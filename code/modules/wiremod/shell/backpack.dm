
/obj/item/backpack_shell
	name = "backpack shell"
	desc = "A huge circuit shell with a few straps attached to it, allowing you to secure it on your back."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_back"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_GIGANTIC
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/obj/item/backpack_shell/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/backpack_shell()
	), SHELL_CAPACITY_LARGE)

/obj/item/circuit_component/backpack_shell
	display_name = "Backpack Shell"
	display_desc = "Used to scan whoever is wearing the shell."

	var/datum/port/output/wearer
	var/datum/port/output/put_on
	var/datum/port/output/taken_off
	var/worn = FALSE

/obj/item/circuit_component/backpack_shell/Initialize()
	. = ..()
	wearer = add_output_port("Wearer", PORT_TYPE_ATOM)
	put_on = add_output_port("Put On", PORT_TYPE_SIGNAL)
	taken_off = add_output_port("Taken Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/backpack_shell/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(shell, COMSIG_ITEM_POST_UNEQUIP, .proc/on_uneqip)

/obj/item/circuit_component/backpack_shell/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_POST_UNEQUIP,
	))
/obj/item/circuit_component/backpack_shell/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_BACK)
		return

	wearer.set_output(equipper)
	put_on.set_output(COMPONENT_SIGNAL)
	worn = TRUE

/obj/item/circuit_component/backpack_shell/proc/on_uneqip(mob/living/unequipper, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	if(!worn)
		return

	wearer.set_output(null)
	taken_off.set_output(COMPONENT_SIGNAL)
