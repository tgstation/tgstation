/obj/item/toy/cards/deck/kotahi
	name = "\improper KOTAHI deck"
	desc = "A deck of kotahi cards. House rules to argue over not included."
	cardgame_desc = "KOTAHI game"
	icon_state = "deck_kotahi_full"
	deckstyle = "kotahi"

/obj/item/toy/cards/deck/kotahi/initialize_cards()
	for(var/colour in list("Red","Yellow","Green","Blue"))
		initial_cards += "[colour] 0" //kotahi decks have only one colour of each 0, weird huh?
		for(var/k in 0 to 1) //two of each colour of number
			initial_cards += "[colour] skip"
			initial_cards += "[colour] reverse"
			initial_cards += "[colour] draw 2"
			for(var/i in 1 to 9)
				initial_cards += "[colour] [i]"
	for(var/k in 0 to 3) //4 wilds and draw 4s
		initial_cards += "Wildcard"
		initial_cards += "Draw 4"
