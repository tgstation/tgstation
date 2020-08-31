/**
  *A storage component to be used on card piles, for use as hands/decks/discard piles. Don't use on something that's not a card pile!
  */
/datum/component/storage/concrete/tcg
	display_numerical_stacking = FALSE
	max_w_class = WEIGHT_CLASS_TINY
	max_items = 30
	max_combined_w_class = WEIGHT_CLASS_TINY * 30
	///The deck that the card pile is using for FAIR PLAY.

/datum/component/storage/concrete/tcg/Initialize()
	. = ..()
	set_holdable(list(/obj/item/tcgcard))

/datum/component/storage/concrete/tcg/can_be_inserted(obj/item/I, stop_messages, mob/M)
	if(istype(I, /obj/item/tcgcard))
		var/obj/item/tcgcard/nu_card = I
		nu_card.zoom_out()
	return ..()

/datum/component/storage/concrete/tcg/PostTransfer()
	. = ..()
	handle_empty_deck()

/datum/component/storage/concrete/tcg/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	handle_empty_deck()

/datum/component/storage/concrete/tcg/show_to(mob/M)
	. = ..()
	M.visible_message("<span class='notice'>[M] starts to look through the contents of \the [parent]!</span>", \
					"<span class='notice'>You begin looking into the contents of \the [parent]!</span>")

/datum/component/storage/concrete/tcg/close(mob/M)
	. = ..()
	var/list/card_contents = contents()
	var/obj/temp_parent = parent
	temp_parent.visible_message("<span class='notice'>\the [parent] is shuffled after looking through it.</span>")
	card_contents = shuffle(card_contents)

/datum/component/storage/concrete/tcg/mass_remove_from_storage(atom/target, list/things, datum/progressbar/progress, trigger_on_found)
	for(var/item in 1 to things.len)
		if(istype(things[item], /obj/item/tcgcard))
			var/obj/item/tcgcard/card = things[item]
			if(isturf(target))
				card.zoom_out()
			else
				card.zoom_in()
	. = ..()
	if(!things.len)
		qdel(parent)

/datum/component/storage/concrete/tcg/proc/handle_empty_deck()
	var/list/contents = contents()
	//You can't have a deck of one card!
	if(contents.len <= 1)
		var/obj/item/tcgcard_deck/deck = parent
		var/obj/item/tcgcard/card = contents[1]
		card.forceMove(card.drop_location())
		card.flipped = deck.flipped
		card.update_icon_state()
		if(isturf(card.drop_location()))
			card.zoom_out()
		else
			card.zoom_in()
		qdel(parent)
