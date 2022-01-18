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
	//var/decksize = 150
	//var/list/allcards = list()

/obj/item/toy/cards/deck/cas/black
	name = "\improper CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the black deck."
	icon_state = "deck_cas_black_full"
	deckstyle = "cas_black"
	blanks = 0
	//decksize = 50

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

/**
/obj/item/toy/cards/deck/cas/draw_card(mob/user)
	var/obj/item/toy/cards/singlecard/cas/H = new/obj/item/toy/cards/singlecard/cas(user.loc)
	var/datum/playingcard/choice = cards[1]
	if (choice.name == "Blank Card")
		H.blank = TRUE
	H.name = choice.name
	H.icon_state = choice.card_icon
	H.card_face = choice.card_icon
	H.parentdeck = WEAKREF(src)
	src.cards -= choice
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message(span_notice("[user] draws a card from the deck."), span_notice("You draw a card from the deck."))
	update_appearance()
**/

/**
/obj/item/toy/cards/deck/cas/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/cas))
		var/obj/item/toy/cards/singlecard/cas/SC = I
		if(!user.temporarilyRemoveItemFromInventory(SC))
			to_chat(user, span_warning("The card is stuck to your hand, you can't add it to the deck!"))
			return
		var/datum/playingcard/RC // replace null datum for the re-added card
		RC = new()
		RC.name = "[SC.name]"
		RC.card_icon = SC.card_face
		cards += RC
		user.visible_message(span_notice("[user] adds a card to the bottom of the deck."),span_notice("You add the card to the bottom of the deck."))
		qdel(SC)
	update_appearance()
**/
