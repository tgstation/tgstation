/// This element serves to allow movables to hide when they receive the
/// `COMSIG_MOVABLE_TOGGLE_HIDING` signal. Does NOT do any form of checking,
/// it's on the caller to check if they should be calling this or not.
/datum/element/can_hide
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY


/datum/element/can_hide/Attach(atom/movable/target)
	. = ..()

	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_TOGGLE_HIDING, PROC_REF(on_toggle_hiding))
	ADD_TRAIT(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)


/datum/element/can_hide/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_MOVABLE_TOGGLE_HIDING)


/**
 * Handles toggling whatever needs to be toggled on the target in when they
 * hide or come back from hiding. Does NOT check if they were already in the same
 * state, so check that yourself.
 */
/datum/element/can_hide/proc/on_toggle_hiding(atom/movable/target, hiding, play_feedback = TRUE)
	SIGNAL_HANDLER

	target.pass_flags_self = hiding ? PASSSTRUCTURE : initial(target.pass_flags_self)
	target.icon_state = "[target.base_icon_state][hiding ? "_hidden" : ""]"

	if(play_feedback)
		playsound(target, 'sound/effects/bodyfall1.ogg', 50, TRUE)
		new /obj/effect/temp_visual/mook_dust(get_turf(target))

	target.update_appearance()

/// Like datum/element/can_hide, but for basic mobs.
/datum/element/can_hide/basic

// Contains an additional parameter, can_hide_types, to tell the basic mob AI subroutine what types of turfs it can hide onto.
/datum/element/can_hide/basic/Attach(datum/target, list/turf/can_hide_types)
	var/mob/living/basic/basic_target = target
	if(!istype(basic_target))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	if(. == ELEMENT_INCOMPATIBLE)
		return

	basic_target.ai_controller?.set_blackboard_key(BB_HIDING_CAN_HIDE_ON, typecacheof(can_hide_types))

