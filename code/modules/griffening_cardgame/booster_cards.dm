/obj/item/griffening_boosterpack
	name = "Griffening Booster Pack"
	desc = "A booster pack that contains Griffening cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_down" //Lazy sprites
	w_class = WEIGHT_CLASS_TINY
	var/NumberOfCards = 10

/obj/item/griffening_boosterpack/Initialize()
	. = ..()

/obj/item/griffening_boosterpack/interact(mob/user)
	to_chat(user, "You open the booster pack with satisfaction, some cards drop on the ground.")
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)
	var/obj/item/griffening_cardhand/I = new /obj/item/griffening_cardhand(user)
	I.currenthand += SScard.get_cards(NumberOfCards)
	new /obj/item/trash(src)
	qdel(src)
