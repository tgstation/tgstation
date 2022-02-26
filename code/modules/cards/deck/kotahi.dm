/obj/item/toy/cards/deck/kotahi
	name = "\improper KOTAHI deck"
	desc = "A deck of kotahi cards. House rules to argue over not included."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_kotahi_full"
	deckstyle = "kotahi"
	is_standard_deck = FALSE

/obj/item/toy/cards/deck/kotahi/Initialize(mapload)
	. = ..()
	for(var/colour in list("Red","Yellow","Green","Blue"))
		cards += new /obj/item/toy/singlecard(mapload, "[colour] 0", src) //kotahi decks have only one colour of each 0, weird huh?
		for(var/k in 0 to 1) //two of each colour of number
			cards += new /obj/item/toy/singlecard(mapload, "[colour] skip", src)
			cards += new /obj/item/toy/singlecard(mapload, "[colour] reverse", src)
			cards += new /obj/item/toy/singlecard(mapload, "[colour] draw 2", src)
			for(var/i in 1 to 9)
				cards += new /obj/item/toy/singlecard(mapload, "[colour] [i]", src)
	for(var/k in 0 to 3) //4 wilds and draw 4s
		cards += new /obj/item/toy/singlecard(mapload, "Wildcard", src)
		cards += new /obj/item/toy/singlecard(mapload, "Draw 4", src)
