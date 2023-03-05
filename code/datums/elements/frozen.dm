GLOBAL_LIST_INIT(freon_color_matrix, list("#2E5E69", "#60A2A8", "#A1AFB1", rgb(0,0,0)))

///simple element to handle frozen obj's
/datum/element/frozen

/datum/element/frozen/Attach(datum/target)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/target_obj = target
	if(target_obj.obj_flags & FREEZE_PROOF)
		return ELEMENT_INCOMPATIBLE

	if(HAS_TRAIT(target_obj, TRAIT_FROZEN))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target_obj, TRAIT_FROZEN, ELEMENT_TRAIT(type))
	target_obj.name = "frozen [target_obj.name]"
	target_obj.add_atom_colour(GLOB.freon_color_matrix, TEMPORARY_COLOUR_PRIORITY)
	target_obj.alpha -= 25

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(shatter_on_throw))
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(shatter_on_throw))
	RegisterSignal(target, COMSIG_OBJ_UNFREEZE, PROC_REF(on_unfreeze))

/datum/element/frozen/Detach(datum/source, ...)
	var/obj/obj_source = source
	REMOVE_TRAIT(obj_source, TRAIT_FROZEN, ELEMENT_TRAIT(type))
	UnregisterSignal(obj_source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_THROW_LANDED, COMSIG_MOVABLE_IMPACT, COMSIG_OBJ_UNFREEZE))
	obj_source.name = replacetext(obj_source.name, "frozen ", "")
	obj_source.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, GLOB.freon_color_matrix)
	obj_source.alpha += 25
	. = ..()

///signal handler for COMSIG_OBJ_UNFREEZE that forces us to detach from the target
/datum/element/frozen/proc/on_unfreeze(datum/source)
	SIGNAL_HANDLER
	Detach(source)

///signal handler for COMSIG_MOVABLE_POST_THROW that shatters our target after impacting after a throw
/datum/element/frozen/proc/shatter_on_throw(datum/target)
	SIGNAL_HANDLER
	var/obj/obj_target = target
	obj_target.visible_message(span_danger("[obj_target] shatters into a million pieces!"))
	obj_target.flags_1 |= NODECONSTRUCT_1	// disable item spawning
	obj_target.deconstruct(FALSE)			// call pre-deletion specialized code -- internals release gas etc

/// signal handler for COMSIG_MOVABLE_MOVED that unfreezes our target if it moves onto an open turf thats hotter than
/// our melting temperature.
/datum/element/frozen/proc/on_moved(datum/target)
	SIGNAL_HANDLER
	var/atom/movable/movable_target = target

	if(movable_target.throwing)
		return

	if(!isopenturf(movable_target.loc))
		return

	var/turf/open/turf_loc = movable_target.loc
	if(turf_loc.air?.temperature >= T0C)//unfreezes target
		Detach(target)
