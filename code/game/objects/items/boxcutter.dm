/obj/item/boxcutter
	name = "boxcutter"
	desc = "A tool for cutting boxes, or throats."
	icon = 'icons/obj/boxcutter.dmi'
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
	var/start_extended = FALSE
	/// Whether or not the boxcutter has been readied
	var/on = FALSE
	var/on_sound = 'sound/items/boxcutter_activate.ogg'

/obj/item/boxcutter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/butchering, \
		speed = 7 SECONDS, \
		effectiveness = 100, \
	)

	AddComponent(/datum/component/transforming, \
		start_transformed = start_extended, \
		force_on = 10, \
		throwforce_on = 4, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/weapons/bladeslice.ogg', \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		attack_verb_continuous_on = list("cuts", "stabs", "slashes"), \
		attack_verb_simple_on = list("cut", "stab", "slash"), \
	)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/boxcutter/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	on = active
	playsound(src, on_sound, 50)
	tool_behaviour = (active ? TOOL_KNIFE : NONE)
	return COMPONENT_NO_DEFAULT_MESSAGE

