/obj/item/melee/beelibsword
	name = "The Stinger"
	desc = "Taken from a giant bee and folded over one thousand times in pure honey. Can sting through anything."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "beesword"
	item_state = "stinger"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	force = 20
	throwforce = 30
	block_chance = 20
	armour_penetration = 85
	attack_verb = list("slashed", "stung", "prickled", "poked")
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/melee/beelibsword/afterattack(atom/target, mob/user, proximity = TRUE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/H = target
		H.reagents.add_reagent(/datum/reagent/toxin/histamine, 6)