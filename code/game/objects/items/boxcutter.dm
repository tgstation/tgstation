/obj/item/boxcutter
	name = "boxcutter"
	desc = "A tool for cutting boxes, or throats."
	icon = 'icons/obj/tools.dmi'
	icon_state = "boxcutter"
	inhand_icon_state = "boxcutter"
	base_icon_state = "boxcutter"
	lefthand_file = 'icons/mob/inhands/equipment/boxcutter_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/boxcutter_righthand.dmi'
	inhand_icon_state = null
	attack_verb_continuous = list("prods", "pokes")
	attack_verb_simple = list("prod", "poke")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	force = 0
	/// Used on Initialize, how much time to cut cable restraints and zipties.
	var/snap_time_weak_handcuffs = 0 SECONDS
	/// Used on Initialize, how much time to cut real handcuffs. Null means it can't.
	var/snap_time_strong_handcuffs = null
	/// Starts open if true
	var/start_extended = FALSE

/obj/item/boxcutter/get_all_tool_behaviours()
	return list(TOOL_KNIFE)

/obj/item/boxcutter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/butchering, \
		speed = 7 SECONDS, \
		effectiveness = 100, \
	)

	AddComponent( \
		/datum/component/transforming, \
		start_transformed = start_extended, \
		force_on = 10, \
		throwforce_on = 4, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/items/weapons/bladeslice.ogg', \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		attack_verb_continuous_on = list("cuts", "stabs", "slashes"), \
		attack_verb_simple_on = list("cut", "stab", "slash"), \
	)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/boxcutter/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	playsound(src, 'sound/items/boxcutter_activate.ogg', 50)
	tool_behaviour = (active ? TOOL_KNIFE : NONE)
	if(active)
		AddElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
	else
		RemoveElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/boxcutter/extended
	start_extended = TRUE
