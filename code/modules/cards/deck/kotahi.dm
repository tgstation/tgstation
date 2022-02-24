/obj/item/toy/cards/deck/kotahi
	name = "\improper KOTAHI deck"
	desc = "A deck of kotahi cards. House rules to argue over not included."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_kotahi_full"
	deckstyle = "kotahi"

/obj/item/toy/cards/deck/kotahi/Initialize(mapload)
	. = ..()
	for(var/colour in list("Red","Yellow","Green","Blue"))
		cards += new /obj/item/toy/singlecard(loc, "[colour] 0", parent_deck = src) //kotahi decks have only one colour of each 0, weird huh?
		for(var/k in 0 to 1) //two of each colour of number
			cards += new /obj/item/toy/singlecard(name = "[colour] skip", parent_deck = src)
			cards += new /obj/item/toy/singlecard(name = "[colour] reverse", parent_deck = src)
			cards += new /obj/item/toy/singlecard(name = "[colour] draw 2", parent_deck = src)
			for(var/i in 1 to 9)
				cards += new /obj/item/toy/singlecard(name = "[colour] [i]", parent_deck = src)
	for(var/k in 0 to 3) //4 wilds and draw 4s
		cards += new /obj/item/toy/singlecard(name = "Wildcard", parent_deck = src)
		cards += new /obj/item/toy/singlecard(name = "Draw 4", parent_deck = src)
