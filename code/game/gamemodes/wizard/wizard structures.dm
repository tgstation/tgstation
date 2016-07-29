/obj/structure/wizard/scrying
	name = "eye of the beholder"
	desc = "Staring into the eye gives you vision beyond mortal means."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "beholder"
	density = 1
	anchored = 1

/obj/structure/wizard/scrying/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>You can see...everything!</span>")
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)
	user.mind.isScrying = 1
	return

/obj/structure/wizard/altar
	name = "ominous altar"
	desc = "How many rituals have been held over this is a mystery."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "altar"
	density = 1
	anchored = 1