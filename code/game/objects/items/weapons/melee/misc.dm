/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	hitsound = "sound/weapons/whip.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogs", "whips", "lashes", "disciplines")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (OXYLOSS)

/obj/item/weapon/melee/morningstar
	name = "morningstar"
	desc = "A long mace with a round, spiky end. Very heavy."
	icon_state = "morningstar"
	item_state = "morningstar"
	hitsound = 'sound/weapons/heavysmash.ogg'
	w_class = 4
	origin_tech = "combat=4"
	attack_verb = list("bashes", "smashes", "pulverizes")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')

	throwforce = 5
	force = 20
