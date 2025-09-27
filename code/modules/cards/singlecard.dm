/obj/item/toy/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/toys/playing_cards.dmi'
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
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH|ALLOW_RESTING
	/// Artistic style of the deck
	var/deckstyle = "nanotrasen"
	/// If the cards in the deck have different icon states (blank and CAS decks do not)
	var/has_unique_card_icons = TRUE
	/// The name of the card
	var/cardname = "Ace of Spades"
	/// Is the card flipped facedown (FALSE) or flipped faceup (TRUE)
	var/flipped = CARD_FACEDOWN
	/// The card is blank and can be written on with a pen.
	var/blank = FALSE
	/// The color used to mark a card for cheating (by pens or crayons)
	var/marked_color

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

		if(parent_deck.holodeck)
			flags_1 |= HOLOGRAM_1
			parent_deck.holodeck.spawned += src
	if(mapload)
		//maploaded card needs to be faceup anyways, and doing this will give it its name and appearance properly
		Flip(CARD_FACEUP)

	register_context()


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

	var/marked_color = getMarkedColor(user)
	if(marked_color)
		. += span_notice("The card has a [marked_color] mark on the corner!")

/obj/item/toy/singlecard/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item) || src == held_item)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Rotate counter-clockwise" // add a ALT_RMB screentip to rotate clockwise
		context[SCREENTIP_CONTEXT_RMB] = "Flip card"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = held_item
		if(HAS_TRAIT(dealer_deck, TRAIT_WIELDED))
			context[SCREENTIP_CONTEXT_LMB] = "Deal card"
			context[SCREENTIP_CONTEXT_RMB] = "Deal card faceup"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Recycle card"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/singlecard))
		context[SCREENTIP_CONTEXT_LMB] = "Combine cards"
		context[SCREENTIP_CONTEXT_RMB] = "Combine cards faceup"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/cards/cardhand))
		context[SCREENTIP_CONTEXT_LMB] = "Combine cards"
		return CONTEXTUAL_SCREENTIP_SET

	if(IS_WRITING_UTENSIL(held_item))
		context[SCREENTIP_CONTEXT_LMB] = blank ? "Write on card" : "Mark card"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/toy/singlecard/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] an unlucky card!"))
	playsound(src, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)
	return BRUTELOSS

/**
 * Flips the card over
 *
 * * Arguments:
 * * is_face_up (optional) - Sets flipped state to CARD_FACEDOWN or CARD_FACEUP if given (otherwise just invert the flipped state)
 */
/obj/item/toy/singlecard/proc/Flip(is_face_up)
	if(!isnull(is_face_up))
		flipped = is_face_up
	else
		flipped = !flipped

	name = flipped ? cardname : "card"
	update_appearance()

/**
 * Returns a color if a card is marked and the user can see it
 *
 * * Arguments:
 * * user - We need to check if the user see the marked card
 */
/obj/item/toy/singlecard/proc/getMarkedColor(mob/living/carbon/user)
	if(!istype(user))
		return
	var/is_marked_with_visible_color = (marked_color && marked_color != "invisible")
	if(is_marked_with_visible_color || (marked_color == "invisible" && HAS_TRAIT(user, TRAIT_REAGENT_SCANNER)))
		return marked_color

/obj/item/toy/singlecard/update_icon_state()
	if(!flipped)
		icon_state = "singlecard_down_[deckstyle]"
	else if(has_unique_card_icons) // each card in a deck has a different icon
		icon_state = "sc_[cardname]_[deckstyle]"
	else // all cards are the same icon state (blank or scribble)
		icon_state = blank ? "sc_blank_[deckstyle]" : "sc_scribble_[deckstyle]"
	return ..()

/obj/item/toy/singlecard/update_name()
	name = flipped ? cardname : "card"
	return ..()

/obj/item/toy/singlecard/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/toy/singlecard/card = null

	if(istype(tool, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = tool
		if(!HAS_TRAIT(dealer_deck, TRAIT_WIELDED)) // recycle card into deck (if unwielded)
			if(dealer_deck.insert(src))
				user.balloon_alert_to_viewers("puts card in deck")
				return ITEM_INTERACT_SUCCESS

			to_chat(user, span_warning("\The [dealer_deck] is stacked too high!"))
			return ITEM_INTERACT_BLOCKING

		card = dealer_deck.draw(user)

	if(istype(tool, /obj/item/toy/singlecard))
		card = tool

	if(card) // card + card = combine into cardhand
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			card.Flip()

		if(istype(tool, /obj/item/toy/cards/deck))
			// only decks cause a balloon alert
			user.balloon_alert_to_viewers("deals a card")

		var/obj/item/toy/cards/cardhand/new_cardhand = new (drop_location())
		new_cardhand.pixel_x = pixel_x
		new_cardhand.pixel_y = pixel_y
		new_cardhand.insert(src)
		new_cardhand.insert(card)

		if(!isturf(loc)) // make a cardhand in our active hand
			user.temporarilyRemoveItemFromInventory(src, TRUE)
			new_cardhand.pickup(user)
			user.put_in_active_hand(new_cardhand)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/toy/cards/cardhand)) // insert into cardhand
		return tool.item_interaction(user, src, modifiers)

	var/marked_cheating_color

	if(istype(tool, /obj/item/pen))
		var/obj/item/pen/pen = tool
		marked_cheating_color = (pen.colour == "white" && "invisible") || pen.colour

	if(istype(tool, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = tool
		marked_cheating_color = (crayon.crayon_color == "mime" && "invisible") || crayon.crayon_color

	if(marked_cheating_color && !blank && IS_WRITING_UTENSIL(tool)) // You cheated not only the game, but yourself
		marked_color = marked_cheating_color
		to_chat(user, span_notice("You put a [marked_color] mark in the corner of [src] with the [tool]. Cheat to win!"))
		return ITEM_INTERACT_SUCCESS

	if(!user.can_write(tool))
		return NONE

	var/cardtext = stripped_input(user, "What do you wish to write on the card?", "Card Writing", "", 50)
	if(!cardtext || !user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING

	cardname = cardtext
	blank = FALSE
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/singlecard/attack_hand_secondary(mob/living/carbon/human/user, modifiers)
	attack_self(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return

	Flip()
	if(isturf(src.loc)) // only display this message when flipping in a visible spot like on a table
		user.balloon_alert_to_viewers("flips a card")

/obj/item/toy/singlecard/click_alt(mob/living/carbon/human/user)
	transform = turn(transform, 90)
		// use the simple_rotation component to make this turn with Alt+RMB & Alt+LMB at some point in the future - TimT
	return CLICK_ACTION_SUCCESS
