/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"
	var/suit
	var/number

/* Deck */

/obj/item/weapon/deck
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "deck"
	w_class = WEIGHT_CLASS_SMALL
	flags = NOBLUDGEON

	var/list/cards = list()

/obj/item/weapon/deck/New()
	. = ..()

	var/cardcolor
	var/datum/playingcard/card

	for (var/suit in list("spades", "clubs", "diamonds", "hearts"))
		if (suit == "spades" || suit == "clubs")
			cardcolor = "black_"
		else
			cardcolor = "red_"

		for (var/number in list("ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"))
			card               = new()
			card.name          = "[number] of [suit]"
			card.card_icon     = "[cardcolor]num"
			card.suit          = suit
			card.number        = number

			src.cards.Add(card)

		for (var/number in list("jack", "queen", "king"))
			card               = new()
			card.name          = "[number] of [suit]"
			card.card_icon     = "[cardcolor]col"
			card.suit          = suit
			card.number        = number

			src.cards.Add(card)

	for (var/i = 0, i < 2, i++)
		card                   = new()
		card.name              = "joker"
		card.card_icon         = "joker"
		card.suit              = "joker"
		card.number            = ""

		src.cards.Add(card)

/obj/item/weapon/deck/attackby(obj/O, mob/user)
	if (istype(O, /obj/item/weapon/hand))
		var/obj/item/weapon/hand/H = O

		for (var/datum/playingcard/P in H.cards) src.cards.Add(P)

		qdel (O)

		user.show_message("You place your cards on the bottom of the deck.")
	else return ..()

/obj/item/weapon/deck/attack_self(mob/user)
	var/list/newcards           = list()
	var/datum/playingcard/card

	while (cards.len)
		card                    = pick(cards)
		newcards.Add(card)
		src.cards.Remove(card)

	src.cards                   = newcards

	user.visible_message("\The [user] shuffles [src].")

/obj/item/weapon/deck/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)
		return //It's adjacent, is the user, or is on the user's person

	if(isliving(A))
		src.dealTo(A, user)
	else
		return ..()

/obj/item/weapon/deck/attack(mob/living/M, mob/living/user, def_zone)
	if (istype(M))
		src.dealTo(M, user)
	else
		return ..()

/obj/item/weapon/deck/proc/dealTo(mob/living/target, mob/living/source)
	if (!cards.len)
		source.show_message("There are no cards in the deck.")
		return

	var/datum/playingcard/card = src.cards[1]

	src.cards.Remove(card)

	var/obj/item/weapon/hand/H = new(get_turf(src))

	H.concealed = 1
	H.update_conceal()

	H.cards.Add(card)
	H.update_icon()

	source.visible_message("\The [source] deals a card to \the [target].")
	H.throw_at(get_step(target, target.dir), 10, 1, source)

/* Hand */

/obj/item/weapon/hand
	name           = "hand of cards"
	desc           = "Some playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state     = "empty"
	w_class        = WEIGHT_CLASS_TINY

	var/concealed  = 0
	var/blank = 0
	var/list/cards = list()
	var/datum/html_interface/hi
	resistance_flags = FLAMMABLE

/obj/item/weapon/hand/New(loc)
	. = ..()

	src.hi = new/datum/html_interface/cards(src, "Your hand", 540, 302)
	src.update_conceal()

/obj/item/weapon/hand/Destroy()
	if (src.hi)
		qdel(src.hi)

	return ..()

/obj/item/weapon/hand/attackby(obj/O, mob/user)
	if(cards.len == 1 && istype(O, /obj/item/weapon/pen))
		var/datum/playingcard/P = cards[1]
		if(!blank)
			to_chat(user, "You cannot write on that card.")
			return
		var/cardtext = sanitize(input(user, "What do you wish to write on the card?", "Card Writing") as text|null, 50)
		if(!cardtext)
			return
		P.name = cardtext
		blank = 0
	else if(istype(O, /obj/item/weapon/hand))
		var/obj/item/weapon/hand/H = O

		for(var/datum/playingcard/P in src.cards) H.cards.Add(P)

		H.update_icon()

		qdel(src)
	else
		return ..()

/obj/item/weapon/hand/verb/discard(datum/playingcard/card in cards)
	set category = "Object"
	set name     = "Discard"
	set desc     = "Place a card from your hand in front of you."

	if (!card)
		return

	var/obj/item/weapon/hand/H = new(src.loc)

	H.concealed = 0
	H.update_conceal()

	H.cards.Add(card)
	src.cards.Remove(card)

	H.update_icon()

	ASSERT(H)

	usr.visible_message("\The [usr] plays \the [card.name].")
	H.loc = get_step(usr,usr.dir)

	src.update_icon()

/obj/item/weapon/hand/verb/toggle_conceal()
	set category  = "Object"
	set name      = "Toggle conceal"
	set desc      = "Toggle concealment of your hand"

	src.concealed = !src.concealed

	src.update_conceal()

	usr.visible_message("\The [usr] [concealed ? "conceals" : "reveals"] their hand.")

	src.update_icon()

/obj/item/weapon/hand/attack_self(mob/user)
	src.hi.show(user)

/obj/item/weapon/hand/examine()
	. = ..()

	if((!concealed || src.loc == usr) && cards.len)
		usr.show_message("It contains: ", 1)

		for (var/datum/playingcard/card in cards)
			usr.show_message("The [card.name].", 1)

/obj/item/weapon/hand/proc/update_conceal()
	if (src.concealed)
		src.hi.updateContent("headbar", "You are currently concealing your hand. <a href=\"byond://?src=\ref[hi]&action=toggle_conceal\">Reveal your hand.</a>")
	else
		src.hi.updateContent("headbar", "You are currently revealing your hand. <a href=\"byond://?src=\ref[hi]&action=toggle_conceal\">Conceal your hand.</a>")

/obj/item/weapon/hand/update_icon()
	if (!cards.len)
		qdel (src)
	else
		if(cards.len > 1)
			name = "hand of cards"
			desc = "Some playing cards."
		else
			name = "a playing card"
			desc = "A playing card."

		cut_overlays()

		if (cards.len == 1)
			var/datum/playingcard/P = cards[1]
			var/mutable_appearance/card_overlay = mutable_appearance(icon, (concealed ? "card_back" : "[P.card_icon]") )

			card_overlay.pixel_x = card_overlay.pixel_x + (-5 + rand(10))
			card_overlay.pixel_y = card_overlay.pixel_y + (-5 + rand(10))

			add_overlay(card_overlay)
		else
			var/origin = -12
			var/offset = round(32 / cards.len)

			var/i = 0
			var/mutable_appearance/card_overlay

			for(var/datum/playingcard/P in cards)
				card_overlay = mutable_appearance(icon, (concealed ? "card_back" : P.card_icon))
				card_overlay.pixel_x = origin + (offset * i)

				add_overlay(card_overlay)
				i = i + 1

		var/html = ""

		for(var/datum/playingcard/card in cards)
			html = html + "<a href=\"byond://?src=\ref[src.hi]&action=play_card&card=\ref[card]\" class=\"card [card.suit] [card.number]\"></a>"

		src.hi.updateContent("hand", html)

/obj/item/weapon/hand/Topic(href, href_list[], datum/html_interface_client/hclient)
	if (istype(hclient))
		switch (href_list["action"])
			if ("play_card")
				var/datum/playingcard/card = locate(href_list["card"]) in cards
				if (card && istype(card))
					src.discard(card)
			if ("toggle_conceal")
				src.toggle_conceal()

// Hook for html_interface module to prevent updates to clients who don't have this in their inventory.
/obj/item/weapon/hand/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	return (hclient.client.mob && hclient.client.mob.stat == 0 && (src in hclient.client.mob.contents))
