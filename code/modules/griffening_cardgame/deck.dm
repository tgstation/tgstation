/obj/item/griffening_deck
	name = "deck of griffening cards"
	desc = "A deck of griffening playing cards."
	icon = 'icons/obj/toy.dmi'
	var/deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/list/cards = list()


/obj/item/griffening_deck/Initialize()
	. = ..()

/obj/item/griffening_deck/examine(mob/user)
	to_chat(user, "<b>[src] has [cards.len] cards.</b>")
	..()

/obj/item/griffening_deck/attack_hand(mob/user)
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/choice = null
	choice = cards[1]
	user.put_in_hands(choice)
	cards -= choice
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()
	. = ..()

/obj/item/griffening_deck/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in cards)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Deck of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()
	. = ..()

/obj/item/griffening_deck/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.is_holding(src))
			var/choice = href_list["pick"]
			var/N = new choice(src.loc)
			src.cards -= choice
			cardUser.put_in_hands(N)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] deck.</span>", "<span class='notice'>You take the card from your deck.</span>")
			interact(cardUser)
			if(src.cards.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.cards.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.cards.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.cards.len == 1)
				var/A = src.cards[1]
				qdel(src)
				cardUser.put_in_hands(A)
				to_chat(cardUser, "<span class='notice'>You also take [A] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
			return

/obj/item/griffening_deck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/griffening_single))
		if(!user.temporarilyRemoveItemFromInventory(I))
			to_chat(user, "<span class='warning'>The card is stuck to your hand, you can't add it to the deck!</span>")
			return
		cards += I
		user.visible_message("[user] adds a card to the bottom of the deck.","<span class='notice'>You add the card to the bottom of the deck.</span>")
		update_icon()
	if(istype(I, /obj/item/griffening_cardhand))
		to_chat(user, "<span class='warning'>Separate the cards before putting them into the deck.</span>")
		return

