#define BLESSING_APPEARANCE_KEY "blessing"
/// Attached to blessed turfs, prevents jaunting, revenant movement and cult teleportation
/datum/element/blessed_turf

/datum/element/blessed_turf/Attach(datum/target, invisible = FALSE)
	. = ..()
	if (!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/target_turf = target
	ADD_TRAIT(target_turf, TRAIT_TURF_BLESSED, ELEMENT_TRAIT(type))
	RegisterSignal(target_turf, COMSIG_ATOM_INTERCEPT_TELEPORTING, PROC_REF(block_cult_teleport))

	if (invisible)
		return

	var/image/blessing_icon = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = ABOVE_NORMAL_TURF_LAYER, loc = target_turf)
	SET_PLANE_EXPLICIT(blessing_icon, GAME_PLANE, target_turf)
	blessing_icon.alpha = 64
	blessing_icon.appearance_flags = RESET_ALPHA | RESET_COLOR | KEEP_APART
	target_turf.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessed_aware, BLESSING_APPEARANCE_KEY, blessing_icon)

/datum/element/blessed_turf/Detach(datum/source, ...)
	. = ..()
	var/turf/target_turf = source
	REMOVE_TRAIT(target_turf, TRAIT_TURF_BLESSED, ELEMENT_TRAIT(type))
	UnregisterSignal(target_turf, COMSIG_ATOM_INTERCEPT_TELEPORTING)
	target_turf.remove_alt_appearance(BLESSING_APPEARANCE_KEY)

/datum/element/blessed_turf/proc/block_cult_teleport(datum/source, channel, turf/origin)
	SIGNAL_HANDLER

	if(channel == TELEPORT_CHANNEL_CULT)
		return COMPONENT_INTERCEPT_TELEPORT

#undef BLESSING_APPEARANCE_KEY
