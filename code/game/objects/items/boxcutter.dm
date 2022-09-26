/obj/item/boxcutter
	name = "boxcutter"
	desc = "A tool for cutting boxes, or throats."
	icon_state = "telebaton"
	base_icon_state = "telebaton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	force = 0
	var/start_extended = FALSE

/obj/item/boxcutter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/butchering, \
	speed = 7 SECONDS, \
	effectiveness = 100, \
	)
	AddComponent(/datum/component/transforming, \
		start_transformed = start_extended, \
		force_on = 8, \
		throwforce_on = 3, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/weapons/bladeslice.ogg', \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		attack_verb_continuous_on = list("cuts", "stabs", "slashes"), \
		attack_verb_simple_on = list("cut", "stab", "slash"))

/obj/item/delivery/attackby(obj/item/boxcutter, mob/user)
	playsound(src, 'sound/items/bikehorn.ogg' , 50, TRUE)
	unwrap_contents(user)
