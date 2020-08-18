// If an item has the processable item, it can be processed into another item with a specific tool. This adds generic behavior for those actions to make it easier to set-up generically.
/datum/element/processable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///The result item
	var/atom/result
	///The tool behaviour for this processing recipe
	var/tool_behaviour
	///Time to process the atom
	var/time_to_process
	///Amount of the resulting actor this will create
	var/amount_created

/datum/element/processable/Attach(datum/target, tool_behaviour, result, amount_created = 3, time_to_process = 20)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.tool_behaviour = tool_behaviour
	src.amount_created = amount_created
	src.time_to_process = time_to_process
	src.result = result

	RegisterSignal(target, COMSIG_TOOL(tool_behaviour), .proc/try_process)

/datum/element/processable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_TOOL(tool_behaviour))

/datum/element/processable/proc/try_process(datum/source, mob/living/user, obj/item/I, list/mutable_recipes)
	mutable_recipes += list(TOOL_PROCESSING_RESULT = result, TOOL_PROCESSING_AMOUNT = amount_created, TOOL_PROCESSING_TIME = time_to_process)
	return COMPONENT_NO_AFTERATTACK
