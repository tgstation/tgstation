/// Element used to track the conditions for a turf being part of an incomplete shuttle frame
/datum/element/shuttle_construction_turf
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/shuttle_construction_turf/Attach(turf/target)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_TURF_CHANGE, PROC_REF(pre_turf_changed))
	RegisterSignal(target, COMSIG_TURF_ATTEMPT_LATTICE_REPLACEMENT, PROC_REF(pre_lattice_replacement))
	RegisterSignal(target, COMSIG_TURF_ADDED_TO_SHUTTLE, PROC_REF(on_turf_added_to_shuttle))
	ADD_TRAIT((get_area(target)), TRAIT_HAS_SHUTTLE_CONSTRUCTION_TURF, REF(target))
	if(!GLOB.shuttle_frames_by_turf[target])
		assign_shuttle_construction_turf_to_frame(target)

/datum/element/shuttle_construction_turf/Detach(turf/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_TURF_CHANGE, COMSIG_TURF_ATTEMPT_LATTICE_REPLACEMENT, COMSIG_TURF_ADDED_TO_SHUTTLE, SIGNAL_REMOVETRAIT(TRAIT_SHUTTLE_CONSTRUCTION_TURF)))
	REMOVE_TRAIT((get_area(source)), TRAIT_HAS_SHUTTLE_CONSTRUCTION_TURF, REF(source))
	var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[source]
	frame.remove_turf(source)

///Changing or destroying the turf detaches the element, also we need to reapply the traits since they don't get passed down.
/datum/element/shuttle_construction_turf/proc/pre_turf_changed(turf/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	var/list/old_trait_sources = GET_TRAIT_SOURCES(source, TRAIT_SHUTTLE_CONSTRUCTION_TURF)
	old_trait_sources = old_trait_sources.Copy()
	post_change_callbacks += CALLBACK(src, PROC_REF(post_turf_changed), old_trait_sources)
	var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[source]
	frame.possibly_valid_changing_turfs[source] = TRUE

/datum/element/shuttle_construction_turf/proc/pre_lattice_replacement(turf/source, list/post_successful_replacement_callbacks)
	SIGNAL_HANDLER
	post_successful_replacement_callbacks += CALLBACK(src, PROC_REF(register_lattice))

/datum/element/shuttle_construction_turf/proc/post_turf_changed(list/trait_sources, turf/new_turf)
	var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[new_turf]
	frame.possibly_valid_changing_turfs -= new_turf
	if(isfloorturf(new_turf) || iswallturf(new_turf))
		trait_sources |= ELEMENT_TRAIT(type)
	else
		trait_sources -= ELEMENT_TRAIT(type)
	if(length(trait_sources))
		for(var/source in trait_sources)
			new_turf.AddElementTrait(TRAIT_SHUTTLE_CONSTRUCTION_TURF, source, type)
	else
		frame.remove_turf(new_turf)

/datum/element/shuttle_construction_turf/proc/register_lattice(obj/structure/lattice/new_lattice)
	new_lattice.AddElement(/datum/element/shuttle_construction_lattice)

/datum/element/shuttle_construction_turf/proc/on_turf_added_to_shuttle(turf/source)
	REMOVE_TRAIT(source, TRAIT_SHUTTLE_CONSTRUCTION_TURF, ELEMENT_TRAIT(type))
