#define CARD_FACEDOWN 0
#define CARD_FACEUP 1

/obj/item/toy/cards/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_nanotrasen"
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "card"
	pixel_x = -5
	///The name of the card
	var/cardname = null
	///is the card facedown (F), or faceup (T)?
	var/flipped = FALSE
	/// The card is blank and can be written on with a pen.
	var/blank = FALSE

/obj/item/toy/cards/singlecard/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.is_holding(src))
			cardUser.visible_message(span_notice("[cardUser] checks [cardUser.p_their()] card."), span_notice("The card reads: [cardname]."))
			if(blank)
				. += span_notice("The card is blank. Write on it with a pen.")
		else if(HAS_TRAIT(user, TRAIT_XRAY_VISION))
			. += span_notice("You scan the card with your x-ray vision and it reads: [cardname].")
		else
			. += span_warning("You need to have the card in your hand to check it!")
		. += span_notice("Right-click to flip it.")
		. += span_notice("Alt-click to rotate it 90 degrees.")

/**
 * ## Flip
 *
 * Flips the card over
 * 
 * * Arguments:
 * * orientation (optional) - Force the card to be flipped faceup or facedown
 */
/obj/item/toy/cards/singlecard/proc/Flip(orientation)
	if(!isnull(orientation))
		flipped = orientation
	else
		flipped = !flipped

	name = flipped ? cardname : "card"
	update_appearance()

/obj/item/toy/cards/singlecard/update_icon_state()
	if(!flipped) 
		icon_state = "singlecard_down_[deckstyle]"
	else if(blank) // only appears in white cas decks for now
		icon_state = "sc_blank_[deckstyle]"
	else if(deckstyle == "cas_white" | deckstyle == "cas_black")
		icon_state = "sc_scribble_[deckstyle]"
	else
		icon_state = "sc_[cardname]_[deckstyle]"

	return ..()

/**
 * ## do_cardhand
 *
 * Creates, or adds to an existing hand of cards
 *
 * Arguments:
 * * mob/living/user - the user
 * * list/cards - the list of cards being added together (/obj/item/toy/cards/singlecard)
 * * obj/item/toy/cards/cardhand/given_hand (optional) - the cardhand to add said cards into
 */
/obj/item/toy/cards/singlecard/proc/do_cardhand(mob/living/user, list/cards, obj/item/toy/cards/cardhand/given_hand = null)
	if (given_hand && (given_hand?.parentdeck != parentdeck))
		to_chat(user, span_warning("You can't mix cards from other decks!"))
		return
	for (var/obj/item/toy/cards/singlecard/card in cards)
		if (card.parentdeck != parentdeck)
			to_chat(user, span_warning("You can't mix cards from other decks!"))
			return

	var/obj/item/toy/cards/cardhand/new_cardhand = given_hand
	var/preexisting = TRUE // does the cardhand already exist, or are we making a new one
	if (!new_cardhand)
		preexisting = FALSE
		new_cardhand = new /obj/item/toy/cards/cardhand(user.loc)

	for (var/obj/item/toy/cards/singlecard/card in cards)
		user.dropItemToGround(card) // drop them all so the loc will properly update
		new_cardhand.cards += card

	if (preexisting)
		new_cardhand.interact(user)
		new_cardhand.update_sprite()

		user.visible_message(span_notice("[user] adds a card to [user.p_their()] hand."), span_notice("You add the [cardname] to your hand."))
	else
		new_cardhand.parentdeck = parentdeck
		new_cardhand.apply_card_vars(new_cardhand, src)
		to_chat(user, span_notice("You combine the cards into a hand."))

		new_cardhand.pickup(user)
		user.put_in_active_hand(new_cardhand)

	for (var/obj/item/toy/cards/singlecard/card in cards)
		card.loc = new_cardhand // move the cards into the cardhand

/obj/item/toy/cards/singlecard/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/toy/cards/singlecard/))
		do_cardhand(user, list(src, item))
	if(istype(item, /obj/item/toy/cards/cardhand/))
		do_cardhand(user, list(src), item)
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
	else
		return ..()

/obj/item/toy/cards/singlecard/attack_hand_secondary(mob/living/carbon/human/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!ishuman(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	Flip()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/cards/singlecard/attack_self_secondary(mob/living/carbon/human/user, modifiers)
	if(!ishuman(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	Flip()

/obj/item/toy/cards/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	Flip()

/obj/item/toy/cards/singlecard/AltClick(mob/living/carbon/human/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		src.transform = turn(src.transform, 90)
/**		
		var/matrix/M = matrix()
		M.Turn(90)
		transform = M
		// OR
		var/matrix/M = matrix()
		M.Turn(45)
		src.transform = M
**/
	return ..()

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.attack_verb_continuous = newobj.card_attack_verb_continuous = sourceobj.card_attack_verb_continuous //null or unique list made by string_list()
	newobj.attack_verb_simple = newobj.card_attack_verb_simple = sourceobj.card_attack_verb_simple //null or unique list made by string_list()
