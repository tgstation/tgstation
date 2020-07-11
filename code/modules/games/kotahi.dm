/obj/item/toy/cards/deck/kotahi
	name = "\improper KOTAHI deck"
	desc = "A deck of kotahi cards. House rules to argue over not included."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_kotahi_full"
	deckstyle = "kotahi"

//Populate the deck.
/obj/item/toy/cards/deck/kotahi/populate_deck()
	for(var/colour in list("Red","Yellow","Green","Blue"))
		cards += "[colour] 0" //kotahi decks have only one colour of each 0, weird huh?
		for(var/k in 0 to 1) //two of each colour of number
			cards += "[colour] skip"
			cards += "[colour] reverse"
			cards += "[colour] draw 2"
			for(var/i in 1 to 9)
				cards += "[colour] [i]"
	for(var/k in 0 to 3) //4 wilds and draw 4s
		cards += "Wildcard"
		cards += "Draw 4"
