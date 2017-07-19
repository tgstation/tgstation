/obj/item/griffening_boosterpack
	name = "A Griffening Booster Pack"
	desc = "A booster pack that contains Griffening cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_nanotrasen" //Lazy sprites
	w_class = WEIGHT_CLASS_TINY
	var/NumberOfCards = 10

/obj/item/griffening_boosterpack/Initialize()
	. = ..()

/obj/item/griffening_boosterpack/interact(mob/user)
	to_chat(user, "You open the booster pack with a satisfying rip, some cards drop on the ground.")
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)
	var/obj/item/weapon/storage/backpack/deckgriffening/I = new /obj/item/weapon/storage/backpack/deckgriffening(user.loc)
	I.isboosterpack = TRUE
	SScard.make_physical_card(NumberOfCards, I)
	new /obj/item/trash(src)
	qdel(src)

/obj/item/griffening_boosterpack/deck40
	NumberOfCards = 40

/obj/item/griffening_boosterpack/mega100
	NumberOfCards = 100
