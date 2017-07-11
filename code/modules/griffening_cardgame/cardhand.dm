/obj/item/griffening_cardhand
	name = "Griffening Card Hand"
	desc = "You shouldn't be seeing this, tell ma44."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = WEIGHT_CLASS_TINY
	var/deckstyle = "nanotrasen"
	var/list/currenthand = list()
	var/LVL = 0
	var/ATK = 0
	var/DEF = 0

/obj/item/griffening_cardhand/examine(mob/user) //TODO: show all cards in the hand
	to_chat(user, "[ATK] ATK| [DEF] DEF| [LVL] LVL| [desc]")
	. = ..()

/obj/item/griffening_cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/griffening_cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()

/obj/item/griffening_cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.is_holding(src))
			var/choice = href_list["pick"]
			var/C = new choice(cardUser.loc)
			src.currenthand -= choice
			cardUser.put_in_hands(C)
			cardUser.visible_message("<span class='notice'>[cardUser] takes a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the card from your hand.</span>")

			interact(cardUser)
			if(src.currenthand.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.currenthand.len == 1)
				var/A = src.currenthand[1]
				cardUser.put_in_hands(A)
				to_chat(cardUser, "<span class='notice'>You also take [A] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				return

/obj/item/griffening_cardhand/attack_hand(mob/user)
		user.put_in_hands(src)

/obj/item/griffening_cardhand/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/griffening_cardhand))
		return ..()
	currenthand += I
	user.visible_message("[user] adds a card to [user.p_their()] hand.", "<span class='notice'>You add the [I.name] to your hand.</span>")
	qdel(I)
	interact(user)
	if(currenthand.len > 4)
		icon_state = "[deckstyle]_hand5"
	else if(currenthand.len > 3)
		icon_state = "[deckstyle]_hand4"
	else if(currenthand.len > 2)
		icon_state = "[deckstyle]_hand3"
