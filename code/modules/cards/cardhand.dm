/obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "none"
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "card"

/obj/item/toy/cards/cardhand/Initialize(mapload, list/cards_to_combine)
	. = ..()
 
	if(!LAZYLEN(cards_to_combine))
		CRASH("[src] is being made into a cardhand without a list of cards to combine")

/** I haven't decided if I want to make it possible to mapload cardhands (meh)

	if(mapload && LAZYLEN(cards)) // these cards have not been initialized 
		for(var/card_name in cards)
			var/obj/item/toy/singlecard/new_card = new (loc, card_name)
			new_card.update_appearance()
			cards_to_combine += new_card		
		cards = list() // reset our cards to an empty list
**/
	if(LAZYLEN(cards_to_combine)) // these cards are already initialized
		for(var/obj/item/toy/singlecard/new_card in cards_to_combine)
			cards += new_card
	update_appearance()

/obj/item/toy/cards/cardhand/Destroy()
	QDEL_LIST(cards)
	return ..()

/**
/obj/item/toy/cards/cardhand/insert(mob/user, obj/item/toy/cards/card_to_add)
	. = ..()
	interact(user)
	update_appearance()
**/
/obj/item/toy/cards/cardhand/attack_self(mob/living/user)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK))
		return

	var/list/handradial = list()
	for(var/obj/item/toy/singlecard/card in cards)
		handradial[card] = image(icon = src.icon, icon_state = card.icon_state)

	//interact(user) i dont think we need this and should remove it
	var/obj/item/toy/singlecard/choice = show_radial_menu(usr, src, handradial, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	//interact(user) i dont think we need this and should remove it
	var/obj/item/toy/singlecard/selected_card = draw(user, choice)
	selected_card.pickup(user)
	user.put_in_hands(selected_card)
	user.visible_message(span_notice("[user] draws a card from [user.p_their()] hand."), span_notice("You draw a card from your hand."))
	update_appearance()

	if(length(cards) == 1)
		var/obj/item/toy/singlecard/last_card = draw(user)
		qdel(src)
		last_card.pickup(user)
		user.put_in_hands(last_card)
		to_chat(user, span_notice("You also take [last_card.cardname] and hold it."))

/**
/obj/item/toy/cards/cardhand/attackby(obj/item/toy/singlecard/card, mob/living/user, params)
	if(istype(card))
		add_card(user, cards, card)
	else
		return ..()
**/

/obj/item/toy/cards/cardhand/proc/check_menu(mob/living/user)
	return isliving(user) && !user.incapacitated()

/obj/item/toy/cards/cardhand/update_overlays()
	. = ..()
	cut_overlays()
	var/overlay_cards = cards.len

	var/k = overlay_cards == 2 ? 1 : overlay_cards - 2
	for(var/i = k; i <= overlay_cards; i++)
		var/obj/item/toy/singlecard/card = cards[i]
		var/card_overlay = image(icon, icon_state = card.icon_state, pixel_x = (1 - i + k) * 3, pixel_y = (1 - i + k) * 3)
		add_overlay(card_overlay)
