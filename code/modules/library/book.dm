/obj/item/book
	name = "book"
	desc = "Crack it open, inhale the musk of its pages, and learn something new."
	icon = 'icons/obj/service/library.dmi'
	icon_state ="book"
	worn_icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL  //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb_continuous = list("bashes", "whacks", "educates")
	attack_verb_simple = list("bash", "whack", "educate")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	/// Maximum icon state number
	var/maximum_book_state = 8
	/// Game time in 1/10th seconds
	var/due_date = 0
	/// false - Normal book, true - Should not be treated as normal book, unable to be copied, unable to be modified
	var/unique = FALSE
	/// whether or not we have been carved out
	var/carved = FALSE

	/// The initial title, for use in var editing and such
	var/starting_title
	/// The initial author, for use in var editing and such
	var/starting_author
	/// The initial bit of content, for use in var editing and such
	var/starting_content
	/// The packet of information that describes this book
	var/datum/book_info/book_data

/obj/item/book/Initialize(mapload)
	. = ..()
	book_data = new(starting_title, starting_author, starting_content)

	AddElement(/datum/element/falling_hazard, damage = 5, wound_bonus = 0, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)

/obj/item/book/examine(mob/user)
	. = ..()
	if(carved)
		. += span_notice("[src] has been hollowed out.")

/obj/item/book/ui_static_data(mob/user)
	var/list/data = list()
	data["author"] = book_data.get_author()
	data["title"] = book_data.get_title()
	data["content"] = book_data.get_content()
	return data

/obj/item/book/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MarkdownViewer", name)
		ui.open()

/// Proc that handles sending the book information to the user, as well as some housekeeping stuff.
/obj/item/book/proc/display_content(mob/living/user)
	credit_book_to_reader(user)
	ui_interact(user)

/// Proc that checks if the user is capable of reading the book, for UI interactions and otherwise. Returns TRUE if they can, FALSE if they can't.
/obj/item/book/proc/can_read_book(mob/living/user)
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return FALSE

	if(!user.can_read(src))
		return FALSE

	if(carved)
		balloon_alert(user, "book is carved out!")
		return FALSE

	if(!length(book_data.get_content()))
		balloon_alert(user, "book is blank!")
		return FALSE

	return TRUE

/// Proc that adds the book to a list on the user's mind so we know what works of art they've been catching up on.
/obj/item/book/proc/credit_book_to_reader(mob/living/user)
	if(!isliving(user) || isnull(user.mind))
		return

	LAZYINITLIST(user.mind.book_titles_read)
	if(starting_title in user.mind.book_titles_read)
		return

	user.add_mood_event("book_nerd", /datum/mood_event/book_nerd)
	user.mind.book_titles_read[starting_title] = TRUE

/obj/item/book/attack_self(mob/user)
	if(!can_read_book(user))
		return

	user.visible_message(span_notice("[user] opens a book titled \"[book_data.title]\" and begins reading intently."))
	display_content(user)

/obj/item/book/attackby(obj/item/attacking_item, mob/living/user, params)
	if(burn_paper_product_attackby_check(attacking_item, user))
		return

	if(IS_WRITING_UTENSIL(attacking_item))
		if(!user.can_perform_action(src) || !user.can_write(attacking_item))
			return
		if(user.is_blind())
			to_chat(user, span_warning("As you are trying to write on the book, you suddenly feel very stupid!"))
			return
		if(unique)
			to_chat(user, span_warning("These pages don't seem to take the ink well! Looks like you can't modify it."))
			return
		if(carved)
			to_chat(user, span_warning("The book has been carved out! There is nothing to be vandalized."))
			return

		var/choice = tgui_input_list(usr, "What would you like to change?", "Book Alteration", list("Title", "Contents", "Author", "Cancel"))
		if(isnull(choice))
			return
		if(!user.can_perform_action(src) || !user.can_write(attacking_item))
			return
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title", "Book Title", max_length = 30))
				if(!user.can_perform_action(src) || !user.can_write(attacking_item))
					return
				if (length_char(newtitle) > 30)
					to_chat(user, span_warning("That title won't fit on the cover!"))
					return
				if(!newtitle)
					to_chat(user, span_warning("That title is invalid."))
					return
				name = newtitle
				playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
				book_data.set_title(html_decode(newtitle)) //Don't want to double encode here
			if("Contents")
				var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed)", "Book Contents", max_length = MAX_PAPER_LENGTH, multiline = TRUE)
				if(!user.can_perform_action(src) || !user.can_write(attacking_item))
					return
				if(!content)
					to_chat(user, span_warning("The content is invalid."))
					return
				book_data.set_content(html_decode(content))
				playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			if("Author")
				var/author = tgui_input_text(user, "Write the author's name", "Author Name", max_length = MAX_NAME_LEN)
				if(!user.can_perform_action(src) || !user.can_write(attacking_item))
					return
				if(!author)
					to_chat(user, span_warning("The name is invalid."))
					return
				book_data.set_author(html_decode(author)) //Setting this encodes, don't want to double up
				playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)

	else if(istype(attacking_item, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = attacking_item
		var/obj/machinery/computer/libraryconsole/bookmanagement/computer = scanner.computer_ref?.resolve()
		if(!computer)
			user.balloon_alert(user, "not connected to computer!")
			return

		switch(scanner.scan_mode)
			if(BARCODE_SCANNER_CHECKIN)
				var/list/checkouts = computer.checkouts
				for(var/checkout_ref in checkouts)
					var/datum/borrowbook/maybe_ours = checkouts[checkout_ref]
					if(!book_data.compare(maybe_ours.book_data))
						continue
					checkouts -= checkout_ref
					computer.checkout_update()
					user.balloon_alert(user, "book checked in")
					playsound(loc, 'sound/items/barcodebeep.ogg', 20, FALSE)
					return

				user.balloon_alert(user, "book not checked out!")
				return
			if(BARCODE_SCANNER_INVENTORY)
				var/datum/book_info/our_copy = book_data.return_copy()
				computer.inventory[ref(our_copy)] = our_copy
				computer.inventory_update()
				user.balloon_alert(user, "book added to inventory")
				playsound(loc, 'sound/items/barcodebeep.ogg', 20, FALSE)

	else if(try_carve(attacking_item, user, params))
		return
	return ..()

/// Generates a random icon state for the book
/obj/item/book/proc/gen_random_icon_state()
	icon_state = "book[rand(1, maximum_book_state)]"

/// Called when user attempts to carve the book with an item
/obj/item/book/proc/try_carve(obj/item/carving_item, mob/living/user, params)
	if(carved)
		return FALSE
	if(!user.combat_mode)
		return FALSE
	//special check for wirecutter's because they don't have a sharp edge
	if((carving_item.get_sharpness() & SHARP_EDGED) || (carving_item.tool_behaviour == TOOL_WIRECUTTER))
		balloon_alert(user, "carving out...")
		if(!do_after(user, 3 SECONDS, target = src))
			balloon_alert(user, "interrupted!")
			return FALSE
		carve_out(carving_item, user)
		return TRUE
	return FALSE

/// Called when the book gets carved successfully
/obj/item/book/proc/carve_out(obj/item/carving_item, mob/living/user)
	if(user)
		balloon_alert(user, "carved out")
		playsound(src, 'sound/effects/cloth_rip.ogg', vol = 75, vary = TRUE)
	carved = TRUE
	create_storage(max_slots = 1)
	return TRUE
