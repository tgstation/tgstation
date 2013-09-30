/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)

///////HUMAN LIMB WEAPONS///////
//Yes these are joke items, yes they are necessary, they are spawned during limb replacement surgery
//Rob Richards's babby, Please only improve, not remove! (unless y'know, major bugs that can't be fixed)
//(if you do remove Robo limb surgery, keep the items as a joke or whatever)

/obj/item/weapon/melee/human_arm
	name = "arm"
	desc = "A Human's arm... why is it detached from them?"
	icon_state = "human_arm"
	item_state = "human_arm"
	flags = FPRINT | TABLEPASS
	force = 5
	throwforce = 3
	w_class = 3
	attack_verb = list("slapped", "punched", "hit", "disrespected")

	suicide_act(mob/user)
		viewers(user) << "\red <b> [user] is punching \himself with the [src.name]! it looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS)

/obj/item/weapon/melee/human_leg
	name = "leg"
	desc = "A Human's leg... why is it detached from them?"
	icon_state = "human_leg"
	item_state = "human_leg"
	flags = FPRINT | TABLEPASS
	force = 5
	throwforce = 3
	w_class = 3
	attack_verb = list("kicked", "punted", "hit")

	suicide_act(mob/user)
		viewers(user) << "\red <b> [user] is kicking \himself with the [src.name]! it looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS)


///////END OF HUMAN LIMB WEAPONS///////