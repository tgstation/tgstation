/obj/item/toy/cards/deck/blank
	name = "custom deck of cards"
	desc = "A deck of playing cards that can be customized with writing."
	cardgame_desc = "custom card game"
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
	for(var/i in 1 to decksize)
		var/obj/item/toy/singlecard/blank_card = new (src, "blank card", src)
		blank_card.blank = TRUE
		cards += blank_card
