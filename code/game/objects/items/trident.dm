/obj/item/trident
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "trident0"
	base_icon_state = "trident"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "trident"
	desc = "An ancient relic often associated with the sea."
	force = 7
	throwforce = 20
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_simple = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_BELT

	///How much extra damage the pitchfork will do while wielded.
	var/force_wielded = 15

/obj/item/trident/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/trident/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/trident/electrified
	name = "trident"
	desc = "An ancient relic often associated with the sea."
	icon_state = "trident_tesla0"
	base_icon_state = "trident_tesla"
	slot_flags = ITEM_SLOT_BELT
	force = 7
	throwforce = 40
	force_wielded = 20

/obj/item/trident/electrified/afterattack(atom/target, mob/user, proximity = TRUE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/H = target
		H.reagents.add_reagent(/datum/reagent/teslium, 3)
