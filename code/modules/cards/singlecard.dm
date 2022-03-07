#define CARD_FACEDOWN 0
#define CARD_FACEUP 1

/obj/item/toy/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "sc_Ace of Spades_nanotrasen"
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "card"
	pixel_x = -5
	resistance_flags = FLAMMABLE
	max_integrity = 50
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	attack_verb_continuous = list("attacks")
	attack_verb_simple = list("attack")
	///Artistic style of the deck
	var/deckstyle = "nanotrasen"
	///If the cards in the deck have different card faces icons (blank and CAS decks do not)
	var/has_unique_card_icons = TRUE
	///The name of the card
	var/cardname = "Ace of Spades"
	///is the card flipped facedown (FALSE) or flipped faceup (TRUE)
	var/flipped = FALSE
	/// The card is blank and can be written on with a pen.
	var/blank = FALSE

/obj/item/toy/singlecard/Initialize(mapload, cardname, obj/item/toy/cards/deck/parent_deck)
	. = ..()
	src.cardname = cardname || src.cardname
	if(istype(parent_deck))
		deckstyle = parent_deck.deckstyle
		has_unique_card_icons = parent_deck.has_unique_card_icons
		icon_state = "singlecard_down_[parent_deck.deckstyle]"
		hitsound = parent_deck.hitsound
		force = parent_deck.force
		throwforce = parent_deck.throwforce
		throw_speed = parent_deck.throw_speed
		throw_range = parent_deck.throw_range
		attack_verb_continuous = parent_deck.attack_verb_continuous
		attack_verb_simple = parent_deck.attack_verb_simple
	// we need to figure out how to do holodeck cards
	//if(holo)
	//	holo.spawned += card_to_add

/obj/item/toy/singlecard/examine(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return 
		
	if(user.is_holding(src))
		user.visible_message(span_notice("[user] checks [user.p_their()] card."), span_notice("The card reads: [cardname]."))
		if(blank)
			. += span_notice("The card is blank. Write on it with a pen.")
	else if(HAS_TRAIT(user, TRAIT_XRAY_VISION))
		. += span_notice("You scan the card with your x-ray vision and it reads: [cardname].")
	else
		. += span_warning("You need to have the card in your hand to check it!")
	. += span_notice("Right-click to flip it.")
	. += span_notice("Alt-click to rotate it 90 degrees.")

/obj/item/toy/singlecard/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] an unlucky card!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	return BRUTELOSS

/**
 * Flips the card over
 * 
 * * Arguments:
 * * orientation (optional) - Sets flipped state to CARD_FACEDOWN or CARD_FACEUP if given orientation (otherwise just invert the flipped state)
 */
/obj/item/toy/singlecard/proc/Flip(orientation)
	if(!isnull(orientation))
		flipped = orientation
	else
		flipped = !flipped

	name = flipped ? cardname : "card"
	update_appearance()

/obj/item/toy/singlecard/update_icon_state()
	if(!flipped) 
		icon_state = "singlecard_down_[deckstyle]"
	else if(has_unique_card_icons) // each card in a deck has a different icon
		icon_state = "sc_[cardname]_[deckstyle]"
	else // all cards are the same icon state (blank or scribble)
		icon_state = blank ? "sc_blank_[deckstyle]" : "sc_scribble_[deckstyle]" 
	return ..()

/obj/item/toy/singlecard/attackby(obj/item/item, mob/living/user, params, flip_card=FALSE)
	var/obj/item/toy/singlecard/card
	
	if(istype(item, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = item
		if(!dealer_deck.wielded) // recycle card into deck (if unwielded)
			dealer_deck.insert(list(src))
			user.balloon_alert_to_viewers("puts card in deck", vision_distance = COMBAT_MESSAGE_RANGE)
			return
		card = dealer_deck.draw(user)

	if(istype(item, /obj/item/toy/singlecard))
		card = item
	
	if(card) // card + card = combine into cardhand
		if(flip_card)
			card.Flip()
			card.update_appearance()
			
		if(istype(item, /obj/item/toy/cards/deck)) 
			// only decks cause a balloon alert
			user.balloon_alert_to_viewers("deals a card", vision_distance = COMBAT_MESSAGE_RANGE)

		var/obj/item/toy/cards/cardhand/new_cardhand = new (drop_location(), list(src, card))
		new_cardhand.pixel_x = src.pixel_x
		new_cardhand.pixel_y = src.pixel_y

		if(!isturf(loc)) // make a cardhand in our active hand
			user.temporarilyRemoveItemFromInventory(src, TRUE)
			new_cardhand.pickup(user)
			user.put_in_active_hand(new_cardhand)
		return

	if(istype(item, /obj/item/toy/cards/cardhand)) // insert into cardhand
		var/obj/item/toy/cards/cardhand/target_cardhand = item
		target_cardhand.insert(list(src))
		return

	if(istype(item, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on [src]!"))
			return
		if(!blank)
			to_chat(user, span_warning("You cannot write on that card!"))
			return
		var/cardtext = stripped_input(user, "What do you wish to write on the card?", "Card Writing", "", 50)
		if(!cardtext || !user.canUseTopic(src, BE_CLOSE))
			return
		name = cardtext
		cardname = cardtext
		blank = FALSE
		update_appearance()
		return 
	return ..()
	
/obj/item/toy/singlecard/attackby_secondary(obj/item/item, mob/living/user, modifiers)
	attackby(item, user, modifiers, flip_card=TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/singlecard/attack_hand_secondary(mob/living/carbon/human/user, modifiers)
	attack_self(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/singlecard/attack_self_secondary(mob/living/carbon/human/user, modifiers)
	attack_self(user)

/obj/item/toy/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		return

	Flip()
	if(isturf(src)) // only display tihs message when flipping in a visible spot like on a table
		user.balloon_alert_to_viewers("flips a card", vision_distance = COMBAT_MESSAGE_RANGE)


/obj/item/toy/singlecard/AltClick(mob/living/carbon/human/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		src.transform = turn(src.transform, 90)
		// use the simple_rotation component to make this turn with Alt+RMB & Alt+LMB at some point in the future - TimT
	return ..()
