/**
 * Create /datum/component/aquarium_content with the preset path on the target right before being inserted into aquarium and deletes itself.
 * Used to save memory from aquarium properties on common objects/stacks that won't see aquarium in 99 out of 100 rounds.
 */
/datum/element/deferred_aquarium_content
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/aquarium_content_type

/datum/element/deferred_aquarium_content/Attach(datum/target, aquarium_content_type)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(!aquarium_content_type)
		CRASH("Deferred aquarium content missing behaviour type.")
	src.aquarium_content_type = aquarium_content_type

	//If element is added to something already in aquarium, just create the component.
	var/atom/movable/movable_target = target
	if(istype(movable_target.loc, /obj/structure/aquarium))
		create_aquarium_component(movable_target)
	else //otherwise the component will be created when trying to insert the thing.
		RegisterSignal(target, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK, .proc/create_aquarium_component)

/datum/element/deferred_aquarium_content/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK)

/datum/element/deferred_aquarium_content/proc/create_aquarium_component(datum/source)
	SIGNAL_HANDLER

	source.AddComponent(/datum/component/aquarium_content, aquarium_content_type)
	Detach(source)
