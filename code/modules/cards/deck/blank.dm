/obj/item/toy/cards/deck/blank
	name = "custom deck of cards"
	desc = "A deck of playing cards that can be customized with writing."
	icon_state = "deck_white_full"
	deckstyle = "white"
	has_unique_card_icons = FALSE
	is_standard_deck = FALSE
	decksize = 25
	can_play_52_card_pickup = FALSE

/obj/item/toy/cards/deck/blank/black
	icon_state = "deck_black_full"
	deckstyle = "black"

/obj/item/toy/cards/deck/blank/Initialize(mapload)
	. = ..()
	for(var/_ in 1 to decksize)
		var/obj/item/toy/singlecard/blank_card = new (cardname = "blank card", parent_deck = src)
		blank_card.name = "blank card"
		blank_card.blank = TRUE
		cards += blank_card
