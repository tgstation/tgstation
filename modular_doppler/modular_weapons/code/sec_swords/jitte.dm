/obj/item/melee/sec_jitte
	name = "security jitte"
	desc = "A blunt weapon designed for incapacitating threats and breaking bones. \
		This is a less-than-lethal, but not non-lethal, weapon. \
		Its guard is a useful mechanism for blocking strikes."

	icon = 'modular_doppler/modular_weapons/icons/obj/sec_swords.dmi'
	icon_state = "sec_jitte"
	lefthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/melee_righthand.dmi'
	inhand_icon_state = "sec_jitte"

	hitsound = 'modular_doppler/modular_sounds/sound/items/sec_jitte.ogg'
	block_sound = 'sound/items/weapons/parry.ogg'

	obj_flags = CONDUCTS_ELECTRICITY
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = UNIQUE_RENAME

	force = 18
	throwforce = 12
	block_chance = 5
	wound_bonus = 5
	bare_wound_bonus = 5

	attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
	attack_verb_simple = list("smack", "strike", "crack", "beat")
