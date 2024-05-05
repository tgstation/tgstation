/obj/item/melee/trick_weapon/threaded_cane
	name = "Threaded Cane"
	base_name = "Threaded Cane"
	desc = "A blind man's whip."
	icon_state = "threaded_cane"
	inhand_icon_state = "threaded_cane"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	on_force = 15
	base_force = 18
	throwforce = 12
	reach = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	damtype = BURN
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/melee/trick_weapon/threaded_cane/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/transforming, \
		force_on = on_force, \
		throwforce_on = 10, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_BULKY)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src,WEAPON_UPGRADE, PROC_REF(upgrade_weapon))

/obj/item/melee/trick_weapon/threaded_cane/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, active ? "extended" : "collapsed")
	inhand_icon_state = active ? "chain" : "threaded_cane"
	if(active)
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', vol = 50)
	reach = active ? 2 : 1
	enabled = active
	force = active ? upgraded_val(on_force, upgrade_level) : upgraded_val(base_force, upgrade_level)
	return COMPONENT_NO_DEFAULT_MESSAGE
