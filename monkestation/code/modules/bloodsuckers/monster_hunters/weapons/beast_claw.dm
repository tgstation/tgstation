/obj/item/melee/trick_weapon/beast_claw
	name = "\improper Beast Claw"
	base_name = "\improper Beast Claw"
	desc = "The bones seem to still be twitching."
	icon_state = "Bone_Claw"
	base_icon_state = "Claw"
	w_class =  WEIGHT_CLASS_SMALL
	block_chance = 20
	base_force = 18
	on_force = 23
	throwforce = 10
	wound_bonus = 25
	bare_wound_bonus = 35
	demolition_mod = 1.5 //ripping through doors and windows should be a little easier with a claw shouldnt it?
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/fwoosh.ogg'
	damtype = BRUTE //why can i not make things do wounds i want
	attack_verb_continuous = list("rips", "claws", "gashes", "tears", "lacerates", "dices", "cuts", "attacks")
	attack_verb_simple = list("rip", "claw", "gash", "tear", "lacerate", "dice", "cut", "attack" )

/obj/item/melee/trick_weapon/beast_claw/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/transforming, \
		force_on = on_force, \
		w_class_on = WEIGHT_CLASS_BULKY)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src,WEAPON_UPGRADE, PROC_REF(upgrade_weapon))

/obj/item/melee/trick_weapon/beast_claw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, active ? "extended" : "collapsed")
	inhand_icon_state = active ? "Claw" : "BoneClaw"
	if(active)
		playsound(src, 'sound/weapons/fwoosh.ogg', vol = 50)
	enabled = active
	active = wound_bonus ? 45 : initial(wound_bonus)
	force = active ? upgraded_val(on_force, upgrade_level) : upgraded_val(base_force, upgrade_level)
	return COMPONENT_NO_DEFAULT_MESSAGE
