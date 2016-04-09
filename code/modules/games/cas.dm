// CARDS AGAINST SPESS
// This is a parody of Cards Against Humanity (https://en.wikipedia.org/wiki/Cards_Against_Humanity)
// which is licensed under CC BY-NC-SA 2.0, the full text of which can be found at the following URL:
// https://creativecommons.org/licenses/by-nc-sa/2.0/legalcode
// Original code by Zuhayr, Polaris Station, ported with modifications

var/global/list/cards_against_space

/obj/item/toy/cards/deck/cas
	name = "\improper CAS deck (white)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the white deck."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_caswhite_full"
	deckstyle = "caswhite"
	var/card_face = "cas_white"
	var/blanks = 10
	var/decksize = 150
	var/card_text_file = "config/cas_white.txt"
	var/list/allcards = list()

/obj/item/toy/cards/deck/cas/black
	name = "\improper CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the black deck."
	icon_state = "deck_casblack_full"
	deckstyle = "casblack"
	card_face = "cas_black"
	blanks = 0
	decksize = 50
	card_text_file = "config/cas_black.txt"

/obj/item/toy/cards/deck/cas/New()
	if(!cards_against_space)  //saves loading from the files every single time a new deck is created, but still lets each deck have a random assortment, it's purely an optimisation. k
		cards_against_space = list("cas_white" = file2list("config/cas_white.txt"),"cas_black" = file2list("config/cas_black.txt"))
	allcards = cards_against_space[card_face]
	var/list/possiblecards = allcards.Copy()
	var/list/randomcards = list()
	while (randomcards.len < decksize)
		randomcards += pick_n_take(possiblecards)
	for(var/i=1 to randomcards.len)
		var/cardtext = randomcards[i]
		var/datum/playingcard/P
		P = new()
		P.name = "[cardtext]"
		P.card_icon = "[src.card_face]"
		cards += P
	if(!blanks)
		return
	for(var/x=1 to blanks)
		var/datum/playingcard/P
		P = new()
		P.name = "Blank Card"
		P.card_icon = "cas_white"
		cards += P

/obj/item/toy/cards/deck/attack_hand(mob/user)
	if(user.lying)
		return
	if(cards.len == 0)
		user << "<span class='warning'>There are no more cards to draw!</span>"
		return
	var/obj/item/toy/cards/singlecard/cas/H = new/obj/item/toy/cards/singlecard/cas(user.loc)
	var/datum/playingcard/choice = cards[1]
	H.name = choice.name
	H.icon_state = choice.card_icon
	H.parentdeck = src
	src.cards -= choice
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

/obj/item/toy/cards/deck/cas/update_icon()
	if(cards.len < 26)
		icon_state = "deck_[deckstyle]_low"

/obj/item/toy/cards/singlecard/cas
	name = "CAS card"
	desc = "A CAS card."
	icon_state = "cas_white"

/obj/item/toy/cards/singlecard/cas/examine(mob/user)
	user << "<span class='notice'>The card reads: [name]</span>"

/obj/item/toy/cards/singlecard/cas/Flip()
	return

/obj/item/toy/cards/singlecard/cas/attackby(obj/item/I, mob/living/user, params)
	return