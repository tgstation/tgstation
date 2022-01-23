/obj/item/toy/cards/deck/blank
	name = "custom deck of cards"
	desc = "A deck of playing cards that can be customized with writing."
	icon_state = "deck_white_full"
	deckstyle = "white"
	custom_deck = TRUE
	/// Amount of blank cards in the deck
	var/blanks = 25

/obj/item/toy/cards/deck/blank/black
	icon_state = "deck_black_full"
	deckstyle = "black"

/obj/item/toy/cards/deck/cas/populate_deck()
	for(var/x in 1 to blanks)
		var/obj/item/toy/cards/singlecard/blank_card = generate_card("blank card")
		blank_card.name = "blank card"
		blank_card.blank = TRUE
		cards += blank_card
