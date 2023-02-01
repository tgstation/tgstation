//Some information about how html sanitization is handled
//All book info datums should store sanitized data. This cannot be worked around
//All inputs and outputs from the round (DB calls) need to use sanitized data
//All tgui menus should get unsanitized data, since jsx handles that on its own
//Everything else should use sanitized data. Yes including names, it's an xss vuln because of how chat works
///A datum which contains all the metadata of a book
/datum/book_info
	///The title of the book
	var/title
	///The "author" of the book
	var/author
	///The info inside the book
	var/content

/datum/book_info/New(_title, _author, _content)
	title = _title
	author = _author
	content = _content

/datum/book_info/proc/set_title(_title, trusted = FALSE)  //Trusted should only be used for books read from the db, or in cases that we can be sure the info has already been sanitized
	if(trusted)
		title = _title
		return
	title = reject_bad_text(trim(html_encode(_title), 30))

/datum/book_info/proc/get_title(default="N/A") //Loads in an html decoded version of the title. Only use this for tgui menus, absolutely nothing else.
	return html_decode(title) || "N/A"

/datum/book_info/proc/set_author(_author, trusted = FALSE)
	if(trusted)
		author = _author
		return
	author = trim(html_encode(_author), MAX_NAME_LEN)

/datum/book_info/proc/get_author(default="N/A")
	return html_decode(author) || "N/A"

/datum/book_info/proc/set_content(_content, trusted = FALSE)
	if(trusted)
		content = _content
		return
	content = trim(html_encode(_content), MAX_PAPER_LENGTH)

/datum/book_info/proc/set_content_using_paper(obj/item/paper/paper)
	// Just the paper's raw data.
	var/raw_content = ""

	for(var/datum/paper_input/text_input as anything in paper.raw_text_inputs)
		raw_content += text_input.raw_text

	// Content from paper is never trusted. It it raw, unsanitised, unparsed user input.
	content = trim(html_encode(raw_content), MAX_PAPER_LENGTH)

/datum/book_info/proc/get_content(default="N/A")
	return html_decode(content) || "N/A"

///Returns a copy of the book_info datum
/datum/book_info/proc/return_copy()
	var/datum/book_info/copycat = new(title, author, content)
	return copycat

///Modify an existing book_info datum to match your data
/datum/book_info/proc/copy_into(datum/book_info/copycat)
	copycat.set_title(title, trusted = TRUE)
	copycat.set_author(author, trusted = TRUE)
	copycat.set_content(content, trusted = TRUE)
	return copycat

/datum/book_info/proc/compare(datum/book_info/cmp_with)
	if(author != cmp_with.author)
		return FALSE
	if(title != cmp_with.title)
		return FALSE
	if(content != cmp_with.content)
		return FALSE
	return TRUE

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
	///Game time in 1/10th seconds
	var/due_date = 0
	///false - Normal book, true - Should not be treated as normal book, unable to be copied, unable to be modified
	var/unique = FALSE
	/// Specific window size for the book, i.e: "1920x1080", Size x Width
	var/window_size = null
	///The initial title, for use in var editing and such
	var/starting_title
	///The initial author, for use in var editing and such
	var/starting_author
	///The initial bit of content, for use in var editing and such
	var/starting_content
	///The packet of information that describes this book
	var/datum/book_info/book_data
	///Maximum icon state number
	var/maximum_book_state = 8

/obj/item/book/Initialize(mapload)
	. = ..()
	book_data = new(starting_title, starting_author, starting_content)

	AddElement(/datum/element/falling_hazard, damage = 5, wound_bonus = 0, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)

/obj/item/book/proc/on_read(mob/living/user)
	if(book_data?.content)
		user << browse("<meta charset=UTF-8><TT><I>Penned by [book_data.author].</I></TT> <BR>" + "[book_data.content]", "window=book[window_size != null ? ";size=[window_size]" : ""]")

		LAZYINITLIST(user.mind?.book_titles_read)
		var/has_not_read_book = isnull(user.mind?.book_titles_read[starting_title])

		if(has_not_read_book) // any new books give bonus mood
			user.add_mood_event("book_nerd", /datum/mood_event/book_nerd)
			user.mind?.book_titles_read[starting_title] = TRUE
		onclose(user, "book")
	else
		to_chat(user, span_notice("This book is completely blank!"))

/// Generates a random icon state for the book
/obj/item/book/proc/gen_random_icon_state()
	icon_state = "book[rand(1, maximum_book_state)]"

/obj/item/book/attack_self(mob/user)
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return
	if(!user.can_read(src))
		return
	user.visible_message(span_notice("[user] opens a book titled \"[book_data.title]\" and begins reading intently."))
	on_read(user)

/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen))
		if(!user.canUseTopic(src, be_close = TRUE) || !user.can_write(I))
			return
		if(user.is_blind())
			to_chat(user, span_warning("As you are trying to write on the book, you suddenly feel very stupid!"))
			return
		if(unique)
			to_chat(user, span_warning("These pages don't seem to take the ink well! Looks like you can't modify it."))
			return

		var/choice = tgui_input_list(usr, "What would you like to change?", "Book Alteration", list("Title", "Contents", "Author", "Cancel"))
		if(isnull(choice))
			return
		if(!user.canUseTopic(src, be_close = TRUE) || !user.can_write(I))
			return
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title", "Book Title", max_length = 30))
				if(!user.canUseTopic(src, be_close = TRUE) || !user.can_write(I))
					return
				if (length_char(newtitle) > 30)
					to_chat(user, span_warning("That title won't fit on the cover!"))
					return
				if(!newtitle)
					to_chat(user, span_warning("That title is invalid."))
					return
				name = newtitle
				book_data.set_title(html_decode(newtitle)) //Don't want to double encode here
			if("Contents")
				var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed)", "Book Contents", multiline = TRUE)
				if(!user.canUseTopic(src, be_close = TRUE) || !user.can_write(I))
					return
				if(!content)
					to_chat(user, span_warning("The content is invalid."))
					return
				book_data.set_content(html_decode(content))
			if("Author")
				var/author = tgui_input_text(user, "Write the author's name", "Author Name")
				if(!user.canUseTopic(src, be_close = TRUE) || !user.can_write(I))
					return
				if(!author)
					to_chat(user, span_warning("The name is invalid."))
					return
				book_data.set_author(html_decode(author)) //Setting this encodes, don't want to double up
			else
				return

	else if(istype(I, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = I
		var/obj/machinery/computer/libraryconsole/bookmanagement/computer = scanner.computer_ref?.resolve()
		if(!computer)
			to_chat(user, span_alert("[scanner]'s screen flashes: 'No associated computer found!'"))
			return ..()

		scanner.book_data = book_data.return_copy()
		switch(scanner.mode)
			if(0)
				to_chat(user, span_notice("[scanner]'s screen flashes: 'Book stored in buffer.'"))
			if(1)
				computer.buffer_book = book_data.return_copy()
				to_chat(user, span_notice("[scanner]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'"))
			if(2)
				var/list/checkouts = computer.checkouts
				for(var/checkout_ref in checkouts)
					var/datum/borrowbook/maybe_ours = checkouts[checkout_ref]
					if(!book_data.compare(maybe_ours.book_data))
						continue
					checkouts -= checkout_ref
					computer.checkout_update()
					to_chat(user, span_notice("[scanner]'s screen flashes: 'Book stored in buffer. Book has been checked in.'"))
					return

				to_chat(user, span_notice("[scanner]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'"))
			if(3)
				var/datum/book_info/our_copy = book_data.return_copy()
				computer.inventory[ref(our_copy)] = our_copy
				computer.inventory_update()
				to_chat(user, span_notice("[scanner]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'"))

	else if((istype(I, /obj/item/knife) || I.tool_behaviour == TOOL_WIRECUTTER) && !(flags_1 & HOLOGRAM_1))
		to_chat(user, span_notice("You begin to carve out [book_data.title]..."))
		if(do_after(user, 30, target = src))
			to_chat(user, span_notice("You carve out the pages from [book_data.title]! You didn't want to read it anyway."))
			var/obj/item/storage/book/carved_out = new
			carved_out.name = src.name
			carved_out.title = book_data.title
			carved_out.icon_state = src.icon_state
			if(user.is_holding(src))
				qdel(src)
				user.put_in_hands(carved_out)
				return
			else
				carved_out.forceMove(drop_location())
				qdel(src)
				return
		return
	else
		..()
