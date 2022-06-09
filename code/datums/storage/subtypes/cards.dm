/**
 *A storage component to be used on card piles, for use as hands/decks/discard piles. Don't use on something that's not a card pile!
 */
/datum/storage/tcg
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 30
	max_total_storage = WEIGHT_CLASS_TINY * 30
	///The deck that the card pile is using for FAIR PLAY.

/datum/storage/tcg/New()
	. = ..()
	set_holdable(list(/obj/item/tcgcard))

/datum/storage/tcg/attempt_remove()
	. = ..()
	handle_empty_deck()

/datum/storage/tcg/show_contents(mob/to_show)
	. = ..()

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	to_show.visible_message(span_notice("[to_show] starts to look through the contents of \the [resolve_parent]!"), \
					span_notice("You begin looking into the contents of \the [resolve_parent]!"))

/datum/storage/tcg/hide_contents()
	. = ..()
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	resolve_parent.visible_message(span_notice("\the [resolve_parent] is shuffled after looking through it."))
	resolve_parent.contents = shuffle(resolve_parent.contents)

/datum/storage/tcg/remove_all()
	. = ..()

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!resolve_parent.contents.len)
		qdel(resolve_parent)

/datum/storage/tcg/proc/handle_empty_deck()
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	//You can't have a deck of one card!
	if(resolve_parent.contents.len == 1)
		var/obj/item/tcgcard_deck/deck = resolve_parent
		var/obj/item/tcgcard/card = resolve_parent.contents[1]
		attempt_remove(card, card.drop_location())
		card.flipped = deck.flipped
		card.update_icon_state()
		qdel(resolve_parent)
