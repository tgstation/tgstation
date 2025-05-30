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
	/// Whether or not we have been carved out.
	var/carved = FALSE
	/// The typepath for the storage datum we use when carved out.
	var/carved_storage_type = /datum/storage/carved_book

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
	AddElement(/datum/element/burn_on_item_ignition)
	register_context()

/obj/item/book/examine(mob/user)
	. = ..()
	if(carved)
		. += span_notice("[src] has been hollowed out.")

/obj/item/book/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item == src)
		var/attack_self_context = get_attack_self_context(user)
		if(!attack_self_context)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = attack_self_context
		return CONTEXTUAL_SCREENTIP_SET

	if(IS_WRITING_UTENSIL(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Vandalize"
		if(is_carving_tool(held_item))
			context[SCREENTIP_CONTEXT_RMB] = "Carve out"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_carving_tool(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Carve out"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/// Gets the context to add for clicking the book inhand. Returns null if none.
/obj/item/book/proc/get_attack_self_context(mob/living/user)
	return "Read"

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

/obj/item/book/proc/is_carving_tool(obj/item/tool)
	PRIVATE_PROC(TRUE)
	if(tool.get_sharpness() & SHARP_EDGED)
		return TRUE
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		return TRUE
	return FALSE

/// Checks for whether we can vandalize this book, to ensure we still can after each input.
/// Uses to_chat over balloon alerts to give more detailed information as to why.
/obj/item/book/proc/can_vandalize(mob/living/user, obj/item/tool)
	if(!user.can_perform_action(src) || !user.can_write(tool))
		return FALSE
	if(user.is_blind())
		to_chat(user, span_warning("As you are trying to write on the book, you suddenly feel very stupid!"))
		return FALSE
	if(unique)
		to_chat(user, span_warning("These pages don't seem to take the ink well! Looks like you can't modify it."))
		return FALSE
	if(carved)
		to_chat(user, span_warning("The book has been carved out! There is nothing to be vandalized."))
		return FALSE
	return TRUE

/obj/item/book/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// Items can both be carving tools and writing utensils.
	// Because of this, we flip interaction priority on secondary.
	// This means pure writing utensils have writing as their primary action,
	// pure carving tools have carving as their primary action,
	// but items with both have primary write secondary carve.
	if(IS_WRITING_UTENSIL(tool))
		return writing_utensil_act(user, tool)
	if(is_carving_tool(tool))
		return carving_act(user, tool)
	return NONE

/obj/item/book/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(is_carving_tool(tool))
		return carving_act(user, tool)
	if(IS_WRITING_UTENSIL(tool))
		return writing_utensil_act(user, tool)
	return NONE

/// Called when user clicks on the book with a writing utensil. Attempts to vandalize the book.
/obj/item/book/proc/writing_utensil_act(mob/living/user, obj/item/tool)
	if(!can_vandalize(user, tool))
		return ITEM_INTERACT_BLOCKING

	var/choice = tgui_input_list(usr, "What would you like to change?", "Book Alteration", list("Title", "Contents", "Author", "Cancel"))
	if(isnull(choice))
		return ITEM_INTERACT_BLOCKING
	if(!can_vandalize(user, tool))
		return ITEM_INTERACT_BLOCKING

	switch(choice)
		if("Title")
			return vandalize_title(user, tool)
		if("Contents")
			return vandalize_contents(user, tool)
		if("Author")
			return vandalize_author(user, tool)

	return NONE

/obj/item/book/proc/vandalize_title(mob/living/user, obj/item/tool)
	var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title", "Book Title", max_length = 30))
	if(!newtitle)
		balloon_alert(user, "invalid input!")
		return ITEM_INTERACT_BLOCKING
	if(length_char(newtitle) > 30)
		balloon_alert(user, "too long!")
		return ITEM_INTERACT_BLOCKING
	if(!can_vandalize(user, tool))
		return ITEM_INTERACT_BLOCKING

	name = newtitle
	book_data.set_title(html_decode(newtitle)) //Don't want to double encode here
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/book/proc/vandalize_contents(mob/living/user, obj/item/tool)
	var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed)", "Book Contents", max_length = MAX_PAPER_LENGTH, multiline = TRUE)
	if(!content)
		balloon_alert(user, "invalid input!")
		return ITEM_INTERACT_BLOCKING
	if(!can_vandalize(user, tool))
		return ITEM_INTERACT_BLOCKING

	book_data.set_content(html_decode(content))
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/book/proc/vandalize_author(mob/living/user, obj/item/tool)
	var/author = tgui_input_text(user, "Write the author's name", "Author Name", max_length = MAX_NAME_LEN)
	if(!author)
		balloon_alert(user, "invalid input!")
		return ITEM_INTERACT_BLOCKING
	if(!can_vandalize(user, tool))
		return ITEM_INTERACT_BLOCKING

	book_data.set_author(html_decode(author)) //Setting this encodes, don't want to double up
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	return ITEM_INTERACT_SUCCESS

/// Called when user clicks on the book with a carving utensil. Attempts to carve the book.
/obj/item/book/proc/carving_act(mob/living/user, obj/item/tool)
	if(carved)
		balloon_alert(user, "already carved!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "carving out...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "carved out")
	playsound(src, 'sound/effects/cloth_rip.ogg', vol = 75, vary = TRUE)
	carve_out()
	return ITEM_INTERACT_SUCCESS

/// Handles setting everything a carved book needs.
/obj/item/book/proc/carve_out()
	carved = TRUE
	create_storage(storage_type = carved_storage_type)

/// Generates a random icon state for the book
/obj/item/book/proc/gen_random_icon_state()
	icon_state = "book[rand(1, maximum_book_state)]"
