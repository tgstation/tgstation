/**
 *A storage component to be used on card piles, for use as hands/decks/discard piles. Don't use on something that's not a card pile!
 */
/datum/storage/tcg
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 30
	max_total_storage = WEIGHT_CLASS_TINY * 30

/datum/storage/tcg/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(/obj/item/tcgcard)

/datum/storage/tcg/attempt_remove(obj/item/thing, atom/remove_to_loc, silent = FALSE)
	. = ..()
	handle_empty_deck()

/datum/storage/tcg/show_contents(mob/to_show)
	. = ..()
	to_show.visible_message(
		span_notice("[to_show] starts to look through the contents of [parent]!"),
		span_notice("You begin looking into the contents of [parent]."),
	)

/datum/storage/tcg/hide_contents()
	. = ..()
	real_location.visible_message(span_notice("[parent] is shuffled after looking through it."))
	real_location.contents = shuffle(real_location.contents)

// Melbert todo
// /datum/storage/tcg/dump_content_at(atom/dest_object, mob/user)
// 	. = ..()
// 	if(real_location.contents.len == 0)
// 		qdel(parent)

/datum/storage/tcg/proc/handle_empty_deck()
	//You can't have a deck of one card!
	if(real_location.contents.len != 1)
		return

	var/obj/item/tcgcard_deck/deck = real_location
	var/obj/item/tcgcard/card = real_location.contents[1]
	attempt_remove(card, card.drop_location())
	card.flipped = deck.flipped
	card.update_icon_state()
	qdel(parent)
