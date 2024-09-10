/datum/quirk/item_quirk/ration_system
	name = "Ration Ticket Receiver"
	desc = "Due to some circumstance of your life, you have enrolled in the ration tickets program, \
		which will halve all of your paychecks in exchange for granting you ration tickets, which can be \
		redeemed at a cargo console for food and other items."
	icon = FA_ICON_DONATE
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_HIDE_FROM_SCAN
	medical_record_text = "Has enrolled in the ration ticket program."
	value = 0
	hardcore_value = 0

/datum/quirk/item_quirk/ration_system/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.account_id)
		return
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[human_holder.account_id]"]

	var/obj/new_ticket_book = new /obj/item/storage/ration_ticket_book(get_turf(human_holder))
	give_item_to_holder(
		new_ticket_book,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
	)
	account.tracked_ticket_book = WEAKREF(new_ticket_book)
	account.payday_modifier = 0.5
	to_chat(client_source.mob, span_notice("You remember to keep close hold of your ticket book, it can't be replaced if lost and all of your ration tickets are placed there!"))

// Edits to bank accounts to make the above possible

/datum/bank_account
	/// Tracks a linked ration ticket book. If we have one of these, then we'll put tickets in it every payday.
	var/datum/weakref/tracked_ticket_book
	/// Tracks if the last ticket we got was for luxury items, if this is true we get a normal food ticket
	var/last_ticket_luxury = TRUE

/datum/bank_account/payday(amount_of_paychecks, free = FALSE)
	. = ..()
	if(!.)
		return
	if(isnull(tracked_ticket_book))
		return
	make_ration_ticket()

/// Attempts to create a ration ticket book in the card holder's hand, and failing that, the drop location of the card
/datum/bank_account/proc/make_ration_ticket()
	if(!(SSeconomy.times_fired % 3 == 0))
		return

	if(!bank_cards.len)
		return

	var/obj/item/storage/ration_ticket_book/ticket_book = tracked_ticket_book.resolve()
	if(!ticket_book)
		tracked_ticket_book = null
		return

	var/obj/item/created_ticket
	for(var/obj/card in bank_cards)
		// We want to only make one ticket pr account per payday
		if(created_ticket)
			continue
		var/ticket_to_make
		if(!last_ticket_luxury)
			ticket_to_make = /obj/item/paper/paperslip/ration_ticket/luxury
		else
			ticket_to_make = /obj/item/paper/paperslip/ration_ticket
		created_ticket = new ticket_to_make(card)
		last_ticket_luxury = !last_ticket_luxury
		if(!ticket_book.atom_storage.can_insert(created_ticket, messages = FALSE))
			qdel(created_ticket)
			bank_card_talk("ERROR: Failed to place ration ticket in ticket book, ensure book is not full.")
			// We can stop here, it's joever for trying to place tickets in the book this payday. You snooze you lose!
			return
		created_ticket.forceMove(ticket_book)
		bank_card_talk("A new [last_ticket_luxury ? "luxury item" : "standard"] ration ticket has been placed in your ticket book.")
