/**
 * Pitchfork item
 *
 * Essentially spears with different stats and sprites.
 * Also fireproof for some reason.
 */
/obj/item/pitchfork
	icon_state = "pitchfork0"
	base_icon_state = "pitchfork"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	atom_size = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("attacks", "impales", "pierces")
	attack_verb_simple = list("attack", "impale", "pierce")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

/obj/item/pitchfork/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=7, force_wielded=15, icon_wielded="[base_icon_state]1")

/obj/item/pitchfork/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()
