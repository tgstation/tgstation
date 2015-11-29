#define CARD_DISPLACE	9
#define CARD_WIDTH		7 //width of the icon

/*
 *	Taken from /tg/
 */

/datum/context_click/cardhand/return_clicked_id(x_pos, y_pos)
	var/obj/item/toy/cardhand/hand = holder

	var/card_distance = CARD_DISPLACE - hand.currenthand.len //how far apart each card is
	var/starting_card_x = hand.currenthand.len * (CARD_DISPLACE - hand.currenthand.len) - CARD_DISPLACE

	if(x_pos < starting_card_x + CARD_WIDTH)
		return 1
	else
		return round( ( x_pos - (starting_card_x + CARD_WIDTH) ) / card_distance ) + 2 //+2, because we floor, and because we skipped the first card

/datum/context_click/cardhand/action(obj/item/used_item, mob/user, params)
	var/obj/item/toy/cardhand/hand = holder
	if(!used_item)
		var/index = Clamp(return_clicked_id_by_params(params), 1, hand.currenthand.len)
		var/obj/item/toy/singlecard/card = hand.currenthand[index]
		hand.currenthand.Remove(card)
		user.put_in_hands(card)
		hand.update_icon()
	else if(istype(used_item, /obj/item/toy/singlecard))
		var/index = Clamp(return_clicked_id_by_params(params), 1, hand.currenthand.len)
		hand.currenthand.Insert(index, used_item) //we put it where we specified
		hand.update_icon()



/obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_full"

	var/list/cards  //list of the singlecard items we carry
	var/strict_deck = 1 //if we only accept cards that came from us

/obj/item/toy/cards/New()
	..()
	cards = list()
	generate_cards()
	update_icon()

/obj/item/toy/cards/proc/generate_cards()
	for(var/i = 2; i <= 10; i++)
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Hearts")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Spades")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Clubs")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Diamonds")

	cards += new/obj/item/toy/singlecard(src, src, "King of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "King of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "King of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "King of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Diamonds")

/obj/item/toy/cards/attack_hand(mob/user as mob)
	var/choice = null
	if(!cards.len)
		src.icon_state = "deck_empty"
		to_chat(user, "<span class = 'notice'>There are no more cards to draw.</span>")
		return
	choice = cards[1]
	src.cards -= choice
	user.put_in_active_hand(choice)
	src.visible_message("<span class = 'notice'>[user] draws a card from the deck.</span>",
						"<span class = 'notice'>You draw a card from the deck.")

	update_icon()

/obj/item/toy/cards/attack_self(mob/user as mob)
	cards = shuffle(cards)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class = 'notice'>[user] shuffles the deck.</span>",
						 "<span class = 'notice'>You shuffle the deck.</span>")

/obj/item/toy/cards/attackby(obj/item/I, mob/living/user)
	..()
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if((!C.parentdeck && !strict_deck) || C.parentdeck == src)
			src.cards += C
			user.drop_item(C, src)
			user.visible_message("<span class = 'notice'>[user] adds a card to the bottom of the deck.</span>",
								 "You add the card to the bottom of the deck.</span>")
		else
			to_chat(user, "<span class = 'warning'>You can't mix cards from other decks.</span>")
			update_icon()

	if(istype(I, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/C = I
		if((!C.parentdeck && !strict_deck) || C.parentdeck == src)
			for(var/obj/item/toy/singlecard/card in C.currenthand)
				card.loc = src
				cards += card
			user.drop_item(C)
			user.visible_message("<span class = 'notice'>[user] puts their hand of cards into the deck.</span>",
								 "<span class = 'notice'>You put the hand into the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class = 'warning'>You can't mix cards from other decks.</span>")
		update_icon()

/obj/item/toy/cards/update_icon()
	if(cards.len > 26)
		src.icon_state = "deck_full"
	else if(cards.len > 10)
		src.icon_state = "deck_half"
	else if(cards.len > 1)
		src.icon_state = "deck_low"

/obj/item/toy/cards/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M)
			M.put_in_hands(src)
			to_chat(usr, "<span class = 'notice'>You pick up the deck.</span>")
		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src, 0)
					M.put_in_r_hand(src)
					to_chat(usr, "<span class = 'notice'>You pick up the deck.</span>")
				if("l_hand")
					M.u_equip(src, 0)
					M.put_in_l_hand(src)
					to_chat(usr, "<span class = 'notice'>You pick up the deck.</span>")
	else
		to_chat(usr, "<span class = 'warning'>You can't reach it from here.</span>")

////////////////////////////
/////////CARD HANDS/////////
////////////////////////////

/obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A nmber of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "handbase"
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/max_hand_size = 5

	var/datum/context_click/cardhand/hand_click

/obj/item/toy/cardhand/New()
	..()
	hand_click = new(src)

/obj/item/toy/cardhand/examine(mob/user)
	..()
	var/name_list = list()
	for(var/obj/item/toy/singlecard/card in currenthand)
		name_list += card.name //we don't use cardname because they might be flipped
	user.show_message("It holds [english_list(name_list)]", 1)

/obj/item/toy/cardhand/attackby(obj/item/toy/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(!(C.parentdeck || src.parentdeck) || C.parentdeck == src.parentdeck)
			if(currenthand.len >= max_hand_size)
				to_chat(user, "<span class = 'warning'> You can't add any more cards to this hand.</span>")
				return
			hand_click.action(C, user, params)
			user.drop_item(C, src)
			user.visible_message("<span class = 'notice'>[user] adds a card to their hand.</span>",
								 "<span class = 'notice'>You add the [C.cardname] to your hand.</span>")
			update_icon()
		else
			to_chat(user, "<span class = 'warning'> You can't mix cards from other decks.</span>")
		return 1
	if(istype(C, /obj/item/toy/cards)) //shuffle us in
		return C.attackby(src, user)
	return ..()

/obj/item/toy/cardhand/attack_self(mob/user)
	for(var/obj/item/toy/singlecard/card in currenthand)
		card.Flip()
		update_icon()
	return ..()

/obj/item/toy/cardhand/attack_hand(mob/user, params)
	if(user.get_inactive_hand() == src)
		return hand_click.action(null, user, params)
	return ..()

/obj/item/toy/cardhand/update_icon()
	overlays.len = 0
	for(var/i = currenthand.len; i >= 1; i--)
		var/obj/item/toy/singlecard/card = currenthand[i]
		if(card)
			card.layer = FLOAT_LAYER
			card.pixel_x = i * (CARD_DISPLACE - currenthand.len) - CARD_DISPLACE
			overlays += card

/*
/obj/item/toy/cardhand/pickup(mob/user)
	update_icon()

/obj/item/toy/cardhand/dropped(mob/user)
	update_icon()
*/

///////////////////////////
/////////CARD ITEMS////////
///////////////////////////

/obj/item/toy/singlecard
	name = "card"
	desc = "\a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down"
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = 0
	pixel_x = -5

/obj/item/toy/singlecard/New(NewLoc, cardsource, newcardname)
	..(NewLoc)
	if(cardsource)
		parentdeck = cardsource
	if(newcardname)
		cardname = newcardname
		name = cardname
	update_icon()

/obj/item/toy/singlecard/update_icon()
	if(flipped)
		icon_state = "singlecard_down"
		pixel_x = -5
		name = "card"
	else
		if(cardname)
			src.icon_state = "sc_[cardname]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades"
			src.name = "What Card"
		src.pixel_x = 5

/obj/item/toy/singlecard/examine(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class = 'notice'>[cardUser] checks \his card.",
									 "<span class = 'notice'>The card reads: [src.name]</span>")
		else
			to_chat(cardUser, "<span class = 'notice'>You need to have the card in your hand to check it.</span>")

/obj/item/toy/singlecard/proc/Flip()
	flipped = !flipped
	update_icon()

/obj/item/toy/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if(!(C.parentdeck || src.parentdeck) || C.parentdeck == src.parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.parentdeck = C.parentdeck
			user.put_in_active_hand(H)
			to_chat(user, "<span class = 'notice'>You combine \the [C] and \the [src] into a hand.</span>")
			user.drop_item(C, H)
			user.remove_from_mob(src) //we could be anywhere!
			src.forceMove(H)
			H.currenthand += C
			H.currenthand += src
			H.update_icon()
			user.put_in_hands(H)
		else
			to_chat(user, "<span class = 'notice'>You can't mix cards from other decks.</span>")

/obj/item/toy/singlecard/attack_self(mob/user)
	Flip()
	return ..()