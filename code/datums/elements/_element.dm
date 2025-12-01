/**
 * A holder for simple behaviour that can be attached to many different types
 *
 * Only one element of each type is instanced during game init.
 * Otherwise acts basically like a lightweight component.
 */
/datum/element
	/// Option flags for element behaviour
	var/element_flags = NONE
	/**
	  * The index of the first attach argument to consider for duplicate elements
	  *
	  * All arguments from this index onwards (1 based, until `argument_hash_end_idx` is reached, if set)
	  * are hashed into the key to determine if this is a new unique element or one already exists
	  *
	  * Is only used when flags contains [ELEMENT_BESPOKE]
	  *
	  * This is infinity so you must explicitly set this
	  */
	var/argument_hash_start_idx = INFINITY
	/**
	  * The index of the last attach argument to consider for duplicate elements
	  * Only used when `element_flags` contains [ELEMENT_BESPOKE].
	  * If not set, it'll copy every argument from `argument_hash_start_idx` onwards as normal
	  */
	var/argument_hash_end_idx = 0

/// Activates the functionality defined by the element on the given target datum
/datum/element/proc/Attach(datum/target)
	SHOULD_CALL_PARENT(TRUE)
	if(type == /datum/element)
		return ELEMENT_INCOMPATIBLE
	SEND_SIGNAL(target, COMSIG_ELEMENT_ATTACH, src)
	if(element_flags & ELEMENT_DETACH_ON_HOST_DESTROY)
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(OnTargetDelete), override = TRUE)

/datum/element/proc/OnTargetDelete(datum/source)
	SIGNAL_HANDLER
	Detach(source)

/// Deactivates the functionality defines by the element on the given datum
/datum/element/proc/Detach(datum/source, ...)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(source, COMSIG_ELEMENT_DETACH, src)
	UnregisterSignal(source, COMSIG_QDELETING)

/datum/element/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	SSdcs.elements_by_type -= type
	return ..()

//DATUM PROCS

/// Finds the singleton for the element type given and attaches it to src
/datum/proc/_AddElement(list/arguments)
	if(QDELING(src))
		var/datum/element/element_type = arguments[1]
		stack_trace("We just tried to add the element [element_type] to a qdeleted datum, something is fucked")
		return

	var/datum/element/ele = SSdcs.GetElement(arguments)
	if(!ele) // We couldn't fetch the element, likely because it was not an element.
		return // the crash message has already been sent
	arguments[1] = src
	if(ele.Attach(arglist(arguments)) == ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible element [ele.type] was assigned to a [type]! args: [json_encode(args)]")

/**
 * Finds the singleton for the element type given and detaches it from src
 * You only need additional arguments beyond the type if you're using [ELEMENT_BESPOKE]
 */
/datum/proc/_RemoveElement(list/arguments)
	var/datum/element/ele = SSdcs.GetElement(arguments, FALSE)
	if(!ele) // We couldn't fetch the element, likely because it didn't exist.
		return
	if(ele.element_flags & ELEMENT_COMPLEX_DETACH)
		arguments[1] = src
		ele.Detach(arglist(arguments))
	else
		ele.Detach(src)

/**
 * Used to manage (typically non_bespoke) elements with multiple sources through traits
 * so we don't have to make them a components again.
 * The element will be later removed once all trait sources are gone, there's no need of a
 * "RemoveElementTrait" counterpart.
 */
/datum/proc/AddElementTrait(trait, source, datum/element/eletype, ...)
	if(!ispath(eletype, /datum/element))
		CRASH("AddElementTrait called, but [eletype] is not of a /datum/element path")
	ADD_TRAIT(src, trait, source)
	if(HAS_TRAIT_NOT_FROM(src, trait, source))
		return
	var/list/arguments = list(eletype)
	/// 3 is the length of fixed args of this proc, any further one is passed down to AddElement.
	if(length(args) > 3)
		arguments += args.Copy(4)
	/// We actually pass down a copy of the arguments since it's manipulated by the end of the proc.
	_AddElement(arguments.Copy())
	var/datum/ele = SSdcs.GetElement(arguments)
	ele.RegisterSignal(src, SIGNAL_REMOVETRAIT(trait), TYPE_PROC_REF(/datum/element, _detach_on_trait_removed))

/datum/element/proc/_detach_on_trait_removed(datum/source, trait)
	SIGNAL_HANDLER
	Detach(source)
	UnregisterSignal(source, SIGNAL_REMOVETRAIT(trait))
