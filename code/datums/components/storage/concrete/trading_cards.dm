/**
  *A storage component to be used on card piles, for use as hands/decks/discard piles. Don't use on something that's not a card pile!
  */
/datum/component/storage/concrete/tcg
	display_numerical_stacking = FALSE
	max_w_class = WEIGHT_CLASS_TINY
	max_combined_w_class = WEIGHT_CLASS_TINY * 30

/datum/component/storage/concrete/tcg/Initialize()
	. = ..()
	set_holdable(list(/obj/item/tcgcard))

/datum/component/storage/concrete/tcg/PostTransfer()
	. = ..()
	handle_empty_deck()

/datum/component/storage/concrete/tcg/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	handle_empty_deck()

/datum/component/storage/concrete/tcg/proc/handle_empty_deck()
	var/list/contents = contents()
	var/obj/item/tcgcard_deck/deck = parent
	//You can't have a deck of one card!
	if(contents.len <= 1)
		var/obj/item/tcgcard/card = contents[1]
		card.forceMove(card.drop_location())
		card.flipped = deck.flipped
		card.update_icon_state()
		qdel(parent)
