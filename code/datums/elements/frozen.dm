///simple element to handle frozen obj's
/datum/element/frozen
	element_flags = ELEMENT_DETACH

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

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(target, COMSIG_MOVABLE_POST_THROW, .proc/shatter_on_throw)
	RegisterSignal(target, COMSIG_OBJ_UNFREEZE, .proc/on_unfrozen)

/datum/element/frozen/Detach(datum/source, ...)
	var/obj/obj_source = source
	REMOVE_TRAIT(obj_source, TRAIT_FROZEN, ELEMENT_TRAIT(type))
	obj_source.name = replacetext(obj_source.name, "frozen ", "")
	obj_source.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, GLOB.freon_color_matrix)
	obj_source.alpha += 25
	. = ..()

/datum/element/frozen/proc/on_unfrozen(datum/source)
	SIGNAL_HANDLER
	Detach(source)

/datum/element/frozen/proc/shatter_on_throw(datum/target)
	SIGNAL_HANDLER
	var/obj/obj_target = target
	obj_target.visible_message(span_danger("[obj_target] shatters into a million pieces!"))
	qdel(obj_target)

/datum/element/frozen/proc/on_moved(datum/target)
	SIGNAL_HANDLER
	var/obj/obj_target = target
	if(!isopenturf(obj_target.loc))
		return

	var/turf/open/turf_loc = obj_target.loc
	if(turf_loc.air?.temperature >= T0C)//unfreezes target
		Detach(target)
