/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/weapon/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/weapon/saddle
	desc = "A saddle composed of sinew wrapped tightly around bone."
	name = "goliath saddle"
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_saddle"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("saddled up")

/obj/item/weapon/saddle/afterattack(mob/living/simple_animal/S, mob/user, proximity)
	if(!proximity)
		return

	if(S.stat == CONSCIOUS	&& S.can_buckle && S.can_tame)
		S.add_overlay("[S.name]_saddled")
		S.can_buckle = 1
		S.buckle_lying = 0 //Override for resting buckles
		S.regenerate_icons()
		qdel(S)

