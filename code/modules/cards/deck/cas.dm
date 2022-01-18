// CARDS AGAINST SPESS
// This is a parody of Cards Against Humanity (https://en.wikipedia.org/wiki/Cards_Against_Humanity)
// which is licensed under CC BY-NC-SA 2.0, the full text of which can be found at the following URL:
// https://creativecommons.org/licenses/by-nc-sa/2.0/legalcode
// Original code by Zuhayr, Polaris Station, ported with modifications
/obj/item/toy/cards/deck/cas
	name = "\improper CAS deck (white)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the white deck."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_cas_white_full"
	deckstyle = "cas_white"
	var/blanks = 25

/obj/item/toy/cards/deck/cas/black
	name = "\improper CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the black deck."
	icon_state = "deck_cas_black_full"
	deckstyle = "cas_black"
	blanks = 0

/obj/item/toy/cards/deck/cas/populate_deck()
	var/cards_against_space = world.file2list("strings/[deckstyle].txt")
	for(var/card in cards_against_space)
		cards += generate_card("[card]")
	if(!blanks)
		return
	for(var/x in 1 to blanks)
		var/obj/item/toy/cards/singlecard/blank_card = generate_card("blank card")
		blank_card.name = "blank card"
		blank_card.blank = TRUE
		cards += blank_card
