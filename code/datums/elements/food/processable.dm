// If an item has the processable item, it can be processed into another item with a specific tool. This adds generic behaviour for those actions to make it easier to set-up generically.
/datum/element/processable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The type of atom this creates when the processing recipe is used.
	var/atom/result_atom_type
	///The tool behaviour for this processing recipe
	var/tool_behaviour
	///Time to process the atom
	var/time_to_process
	///Amount of the resulting actor this will create
	var/amount_created
	///Whether or not the atom being processed has to be on a table or tray to process it
	var/table_required
	///Verb used in processing food (such as slice, flatten), defaults to process
	var/screentip_verb

/datum/element/processable/Attach(datum/target, tool_behaviour, result_atom_type, amount_created = 3, time_to_process = 2 SECONDS, table_required = FALSE, screentip_verb = "Process")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.tool_behaviour = tool_behaviour
	src.amount_created = amount_created
	src.time_to_process = time_to_process
	src.result_atom_type = result_atom_type
	src.table_required = table_required
	src.screentip_verb = screentip_verb

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(tool_behaviour), PROC_REF(try_process))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(OnExamine))

	if(!PERFORM_ALL_TESTS(focus_only/check_materials_when_processed) || !atom_target.custom_materials)
		return

	var/atom/movable/prototype = new
	prototype.set_custom_materials(atom_target.custom_materials, 1 / amount_created)
	var/atom/movable/result = new result_atom_type
	if(!prototype.compare_materials(result))
		var/warning = "custom_materials of [result.type] when processed compared to just spawned don't match"
		var/what_it_should_be = prototype.get_materials_english_list()
		//compose a text string containing the syntax and paths to use for editing the custom_materials var
		if(result.custom_materials)
			what_it_should_be += " (you can round values a bit)"
		stack_trace("[warning]. custom_materials should be [what_it_should_be] (you can round values a bit).")
	qdel(prototype)
	qdel(result)

/datum/element/processable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ATOM_TOOL_ACT(tool_behaviour), COMSIG_ATOM_EXAMINE, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))

/datum/element/processable/proc/try_process(datum/source, mob/living/user, obj/item/I, list/mutable_recipes)
	SIGNAL_HANDLER

	if(table_required)
		var/obj/item/found_item = source
		var/found_location = found_item.loc
		var/found_turf = isturf(found_location)
		var/found_table = locate(/obj/structure/table) in found_location
		var/found_tray = locate(/obj/item/storage/bag/tray) in found_location || locate(/obj/item/plate/oven_tray) in found_location
		if(!found_turf && !istype(found_location, /obj/item/storage/bag/tray) || found_turf && !(found_table || found_tray))
			to_chat(user, span_notice("You cannot make [initial(result_atom_type.name)] here! You need a table or at least a tray."))
			return

	mutable_recipes += list(list(TOOL_PROCESSING_RESULT = result_atom_type, TOOL_PROCESSING_AMOUNT = amount_created, TOOL_PROCESSING_TIME = time_to_process))

///So people know what the frick they're doing without reading from a wiki page (I mean they will inevitably but i'm trying to help, ok?)
/datum/element/processable/proc/OnExamine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/result_name = initial(result_atom_type.name)
	var/result_gender = initial(result_atom_type.gender)
	var/tool_desc = tool_behaviour_name(tool_behaviour)

	// I admit, this is a lot of lines for very minor changes in the strings
	// but at least it's readable?
	if(amount_created > 1)
		if(result_gender == PLURAL)
			examine_list += span_notice("It can be turned into [amount_created] [result_name] with [span_bold(tool_desc)]!")
		else
			examine_list += span_notice("It can be turned into [amount_created] [result_name][plural_s(result_name)] with [span_bold(tool_desc)]!")

	else
		if(result_gender == PLURAL)
			examine_list += span_notice("It can be turned into some [result_name] with [span_bold(tool_desc)]!")
		else
			examine_list += span_notice("It can be turned into \a [result_name] with [span_bold(tool_desc)]!")

/**
 * Adds context sensitivy directly to the processable file for screentips
 * Arguments:
 * * source - refers to item that will display its screentip
 * * context - refers to, in this case, an item that can be proccessed into another item via add element proccessable
 * * held_item - refers to tool used by add element proccessable to process one item into another item
 * * user - refers to user who will see the screentip when the proper context and tool are there
 */
/datum/element/processable/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if (isnull(held_item))
		return NONE

	if (held_item.tool_behaviour != tool_behaviour)
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "[screentip_verb] into [initial(result_atom_type.name)]"

	return CONTEXTUAL_SCREENTIP_SET
