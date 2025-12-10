// Basically just a special snowflake version of processable that takes a proc callback instead of making a new thing.
// Look up processable.dm for more details on how it works.
// This isn't a subtype due to how proc_refs in RegisterSignal work, I'd have to unregister and re-register
/datum/element/processable_callback
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/result_callback
	var/tool_behaviour
	var/time_to_process
	var/table_required
	var/screentip_verb

/datum/element/processable_callback/Attach(datum/target, tool_behaviour, result_callback, time_to_process = 2 SECONDS, table_required = FALSE, screentip_verb = "Process")
	. = ..()

	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.tool_behaviour = tool_behaviour
	src.result_callback = result_callback
	src.time_to_process = time_to_process
	src.table_required = table_required
	src.screentip_verb = screentip_verb

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(tool_behaviour), PROC_REF(try_process))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(OnExamine))

/datum/element/processable_callback/Detach(datum/target)
	. = ..()

	var/atom/atom_target = target
	atom_target.flags_1 &= ~HAS_CONTEXTUAL_SCREENTIPS_1

	UnregisterSignal(target, list(COMSIG_ATOM_TOOL_ACT(tool_behaviour), COMSIG_ATOM_EXAMINE, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))


/datum/element/processable_callback/proc/try_process(datum/source, mob/living/user, obj/item/item)
	SIGNAL_HANDLER

	if(table_required)
		var/obj/item/found_item = source
		var/found_location = found_item.loc
		var/found_turf = isturf(found_location)
		var/found_table = locate(/obj/structure/table) in found_location
		var/found_tray = locate(/obj/item/storage/bag/tray) in found_location || locate(/obj/item/plate/oven_tray) in found_location
		if(!found_turf && !istype(found_location, /obj/item/storage/bag/tray) || found_turf && !(found_table || found_tray))
			to_chat(user, span_notice("You cannot prepare this here! You need a table or at least a tray."))
			return

	call(result_callback)(source)

/datum/element/processable_callback/proc/OnExamine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/tool_desc = tool_behaviour_name(tool_behaviour)
	examine_list += span_notice("It can be prepared with [span_bold(tool_desc)]!")

/datum/element/processable_callback/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if (isnull(held_item))
		return NONE

	if (held_item.tool_behaviour != tool_behaviour)
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "[screentip_verb]"

	return CONTEXTUAL_SCREENTIP_SET
