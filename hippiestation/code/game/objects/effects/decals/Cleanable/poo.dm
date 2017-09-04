//Poo (sorry -MRTY)
/obj/effect/decal/cleanable/poo
	name = "poo"
	desc = "A pile of poo. Gross!"
	icon = 'hippiestation/icons/effects/poo.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/effect/decal/cleanable/poo/attack_hand(mob/user)
	user.visible_message("<span class='danger'>[user] puts their hand in the poo! Gross!</span>", "<span class='danger'>You put your hand in the poo, and immediatly regret it</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/mutable_appearance/poohands = mutable_appearance('hippiestation/icons/effects/poo.dmi', "poohands")
		H.add_overlay(poohands)

/obj/effect/decal/cleanable/poo/Initialize()
	..()
	reagents.add_reagent("poo", 5)

/obj/effect/decal/cleanable/poo/can_bloodcrawl_in()
	return FALSE