/// Lets a machine be patched with a welder
/datum/element/weld_repairable

/datum/element/weld_repairable/Attach(datum/target)
	. = ..()
	if(!ismachinery(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/machinery/machine = target
	machine.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(machine, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welded))
	RegisterSignal(machine, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(machine, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/element/weld_repairable/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_EXAMINE, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))
	return ..()

/datum/element/weld_repairable/proc/needs_repair(obj/machinery/machine)
	return (machine.machine_stat & BROKEN) || machine.get_integrity() < machine.max_integrity

/datum/element/weld_repairable/proc/on_examine(obj/machinery/machine, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(needs_repair(machine))
		examine_list += span_notice("It could be <b>welded</b> back into shape.")

/datum/element/weld_repairable/proc/on_requesting_context_from_item(obj/machinery/machine, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER

	if(held_item?.tool_behaviour != TOOL_WELDER || user.combat_mode || !needs_repair(machine))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Repair"
	return CONTEXTUAL_SCREENTIP_SET

/datum/element/weld_repairable/proc/on_welded(obj/machinery/machine, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	if(user.combat_mode) // welder as a weapon
		return NONE
	if(!needs_repair(machine))
		machine.balloon_alert(user, "it doesn't need repairs!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 0)) // use_tool skips this with a delay, off welder would hiss and fail
		machine.balloon_alert(user, "turn it on first!")
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(repair), machine, user, tool)
	return ITEM_INTERACT_SUCCESS

/datum/element/weld_repairable/proc/repair(obj/machinery/machine, mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("repairing...")
	if(!tool.use_tool(machine, user, 4 SECONDS, amount = 0, volume = 50)) // no fuel, quick patch job
		return
	machine.balloon_alert(user, "repaired")
	machine.repair_damage(machine.max_integrity - machine.get_integrity())
	machine.set_machine_stat(machine.machine_stat & ~BROKEN)
	machine.update_appearance()
