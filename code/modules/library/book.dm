
/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	worn_icon_state = "book"
	desc = "Crack it open, inhale the musk of its pages, and learn something new."
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL  //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb_continuous = list("bashes", "whacks", "educates")
	attack_verb_simple = list("bash", "whack", "educate")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	var/dat //Actual page content
	var/due_date = 0 //Game time in 1/10th seconds
	var/author //Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = FALSE //false - Normal book, true - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title //The real name of the book.
	var/window_size = null // Specific window size for the book, i.e: "1920x1080", Size x Width
	/// Maximum icon state number
	var/maximum_book_state = 8

/obj/item/book/attack_self(mob/user)
	if(!user.can_read(src))
		return
	user.visible_message(span_notice("[user] opens a book titled \"[title]\" and begins reading intently."))
	on_read(user)

/obj/item/book/proc/on_read(mob/user)
	if(dat)
		if(ishuman(user))
			var/mob/living/carbon/human/reader = user
			LAZYINITLIST(reader.book_titles_read)
			var/has_not_read_book = isnull(reader.book_titles_read[title])
			var/is_book_manual = istype(src, /obj/item/book/manual)

			if(has_not_read_book || !is_book_manual) // any new books give bonus mood except for boring manuals zzzzz
				if(HAS_TRAIT(reader, TRAIT_BOOKWORM))
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "reading_excited", /datum/mood_event/reading_excited)
				else
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "reading", /datum/mood_event/reading)
			if(is_book_manual && reader.drowsyness) // manuals are so boring they put us to sleep if we are already drowsy
				to_chat(user, span_warning("As you are reading the boring [src], you suddenly doze off!"))
				reader.AdjustSleeping(100)

			reader.book_titles_read[title] = TRUE

		user << browse("<meta charset=UTF-8><TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book[window_size != null ? ";size=[window_size]" : ""]")
		onclose(user, "book")
	else
		to_chat(user, span_notice("This book is completely blank!"))


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen))
		if(!user.canUseTopic(src, BE_CLOSE) || !user.can_write(I))
			return
		if(unique)
			to_chat(user, span_warning("These pages don't seem to take the ink well! Looks like you can't modify it."))
			return
		var/choice = tgui_input_list(usr, "What would you like to change?", "Book Alteration", list("Title", "Contents", "Author", "Cancel"))
		if(isnull(choice))
			return
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title", "Book Title", max_length = 30))
				if(!user.canUseTopic(src, BE_CLOSE) || !user.can_write(I))
					return
				if (length_char(newtitle) > 30)
					to_chat(user, span_warning("That title won't fit on the cover!"))
					return
				if(!newtitle)
					to_chat(user, span_warning("That title is invalid."))
					return
				else
					name = newtitle
					title = newtitle
			if("Contents")
				var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed)", "Book Contents", max_length = 8192, multiline = TRUE)
				if(!user.canUseTopic(src, BE_CLOSE) || !user.can_write(I))
					return
				if(!content)
					to_chat(user, span_warning("The content is invalid."))
					return
				else
					dat += content
			if("Author")
				var/newauthor = tgui_input_text(user, "Write the author's name", "Author Name", max_length = MAX_NAME_LEN)
				if(!user.canUseTopic(src, BE_CLOSE) || !user.can_write(I))
					return
				if(!newauthor)
					to_chat(user, span_warning("The name is invalid."))
					return
				else
					author = newauthor
			else
				return

	else if(istype(I, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = I
		if(!scanner.computer)
			to_chat(user, span_alert("[I]'s screen flashes: 'No associated computer found!'"))
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, span_notice("[I]'s screen flashes: 'Book stored in buffer.'"))
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = name
					to_chat(user, span_notice("[I]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'"))
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, span_notice("[I]'s screen flashes: 'Book stored in buffer. Book has been checked in.'"))
							return
					to_chat(user, span_notice("[I]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'"))
				if(3)
					scanner.book = src
					for(var/obj/item/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, span_alert("[I]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'"))
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, span_notice("[I]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'"))

	else if((istype(I, /obj/item/knife) || I.tool_behaviour == TOOL_WIRECUTTER) && !(flags_1 & HOLOGRAM_1))
		to_chat(user, span_notice("You begin to carve out [title]..."))
		if(do_after(user, 30, target = src))
			to_chat(user, span_notice("You carve out the pages from [title]! You didn't want to read it anyway."))
			var/obj/item/storage/book/B = new
			B.name = src.name
			B.title = src.title
			B.icon_state = src.icon_state
			if(user.is_holding(src))
				qdel(src)
				user.put_in_hands(B)
				return
			else
				B.forceMove(drop_location())
				qdel(src)
				return
		return
	else
		..()
