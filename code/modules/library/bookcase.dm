#define BOOKCASE_UNANCHORED 0
#define BOOKCASE_ANCHORED 1
#define BOOKCASE_FINISHED 2

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/service/library.dmi'
	icon_state = "bookempty"
	desc = "A great place for storing knowledge."
	anchored = FALSE
	density = TRUE
	opacity = FALSE
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor_type = /datum/armor/structure_bookcase
	var/state = BOOKCASE_UNANCHORED
	/// When enabled, books_to_load number of random books will be generated for this bookcase
	var/load_random_books = FALSE
	/// The category of books to pick from when populating random books.
	var/random_category = BOOK_CATEGORY_RANDOM
	/// Probability that a category will be changed to random regardless of what it was set to.
	var/category_prob = 25
	/// How many random books to generate.
	var/books_to_load = 0

/datum/armor/structure_bookcase
	fire = 50

/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	if(!mapload || QDELETED(src))
		return
	// Only mapload from here on
	set_anchored(TRUE)
	state = BOOKCASE_FINISHED
	for(var/obj/item/I in loc)
		if(!isbook(I))
			continue
		I.forceMove(src)
	update_appearance()

	if(SSlibrary.initialized)
		INVOKE_ASYNC(src, PROC_REF(load_shelf))
	else
		SSlibrary.shelves_to_load += src

///proc for doing things after a bookcase is randomly populated
/obj/structure/bookcase/proc/after_random_load()
	return

///Loads the shelf, both by allowing it to generate random items, and by adding its contents to a list used by library machines
/obj/structure/bookcase/proc/load_shelf()
	//Loads a random selection of books in from the db, adds a copy of their info to a global list
	//To send to library consoles as a starting inventory
	if(load_random_books)
		var/randomizing_categories = prob(category_prob) || random_category == BOOK_CATEGORY_RANDOM
		// We only need to run this special logic if we're randomizing a non-adult bookshelf
		if(randomizing_categories && random_category != BOOK_CATEGORY_ADULT)
			// Category is manually randomized rather than using BOOK_CATEGORY_RANDOM
			// So we can exclude adult books in non-adult bookshelves
			// And also weight the prime category more heavily
			var/list/category_pool = list(
				BOOK_CATEGORY_FICTION,
				BOOK_CATEGORY_NONFICTION,
				BOOK_CATEGORY_REFERENCE,
				BOOK_CATEGORY_RELIGION,
			)
			if(random_category != BOOK_CATEGORY_RANDOM)
				category_pool += random_category
			var/sub_books_to_load = books_to_load
			while(sub_books_to_load > 0 && length(category_pool) > 0)
				var/cat_amount = min(rand(1, 2), sub_books_to_load)
				sub_books_to_load -= cat_amount
				create_random_books(amount = cat_amount, location = src, category = pick_n_take(category_pool))
		// Otherwise we can just let the proc handle everything, it will even do randomization for us
		else
			create_random_books(amount = books_to_load, location = src, category = randomizing_categories ? BOOK_CATEGORY_RANDOM : random_category)

		after_random_load()
		update_appearance() //Make sure you look proper

	var/area/our_area = get_area(src)
	var/area_type = our_area.type //Save me from the dark

	if(!SSlibrary.books_by_area[area_type])
		SSlibrary.books_by_area[area_type] = list()

	//Time to populate that list
	var/list/books_in_area = SSlibrary.books_by_area[area_type]
	for(var/obj/item/book/book in contents)
		var/datum/book_info/info = book.book_data
		books_in_area += info.return_copy()

/obj/structure/bookcase/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_notice("The <i>bolts</i> on the bottom are unsecured.")
	else
		. += span_notice("It's secured in place with <b>bolts</b>.")
	switch(state)
		if(BOOKCASE_UNANCHORED)
			. += span_notice("There's a <b>small crack</b> visible on the back panel.")
		if(BOOKCASE_ANCHORED)
			. += span_notice("There's space inside for a <i>wooden</i> shelf.")
		if(BOOKCASE_FINISHED)
			. += span_notice("There's a <b>small crack</b> visible on the shelf.")

/obj/structure/bookcase/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	state = anchorvalue
	if(!anchorvalue) //in case we were vareditted or uprooted by a hostile mob, ensure we drop all our books instead of having them disappear till we're rebuild.
		var/atom/Tsec = drop_location()
		for(var/obj/I in contents)
			if(!isbook(I))
				continue
			I.forceMove(Tsec)
	update_appearance()

/obj/structure/bookcase/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(state == BOOKCASE_UNANCHORED)
		if(attacking_item.tool_behaviour == TOOL_WRENCH)
			if(attacking_item.use_tool(src, user, 20, volume=50))
				balloon_alert(user, "wrenched in place")
				set_anchored(TRUE)
			return

		if(attacking_item.tool_behaviour == TOOL_CROWBAR)
			if(attacking_item.use_tool(src, user, 20, volume=50))
				balloon_alert(user, "pried apart")
				deconstruct(TRUE)
			return
		return ..()

	if(state == BOOKCASE_ANCHORED)
		if(istype(attacking_item, /obj/item/stack/sheet/mineral/wood))
			var/obj/item/stack/sheet/mineral/wood/W = attacking_item
			if(W.get_amount() < 2)
				balloon_alert(user, "not enough wood")
				return
			W.use(2)
			balloon_alert(user, "shelf added")
			state = BOOKCASE_FINISHED
			update_appearance()
			return

		if(attacking_item.tool_behaviour == TOOL_WRENCH)
			attacking_item.play_tool_sound(src, 100)
			balloon_alert(user, "unwrenched the frame")
			set_anchored(FALSE)
			return
		return ..()

	if(isbook(attacking_item))
		if(!user.transferItemToLoc(attacking_item, src))
			return ..()
		update_appearance()
		return

	if(atom_storage)
		var/found_anything = FALSE
		for(var/obj/item/T in attacking_item.contents)
			if(istype(T, /obj/item/book) || istype(T, /obj/item/spellbook))
				atom_storage.attempt_remove(T, src)
				found_anything = TRUE

		if (found_anything)
			balloon_alert(user, "emptied into [src]")
			update_appearance()
			return

	if(IS_WRITING_UTENSIL(attacking_item))
		if(!user.can_perform_action(src) || !user.can_write(attacking_item))
			return ..()
		var/newname = tgui_input_text(user, "What would you like to title this bookshelf?", "Bookshelf Renaming", max_length = MAX_NAME_LEN)
		if(!user.can_perform_action(src) || !user.can_write(attacking_item))
			return ..()
		if(!newname)
			return
		name = "bookcase ([sanitize(newname)])"
		return

	if(attacking_item.tool_behaviour == TOOL_CROWBAR)
		if(length(contents))
			balloon_alert(user, "remove the books first")
			return
		attacking_item.play_tool_sound(src, 100)
		balloon_alert(user, "pried the shelf out")
		new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
		state = BOOKCASE_ANCHORED
		update_appearance()
		return

	return ..()

/obj/structure/bookcase/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return
	if(!length(contents))
		return
	var/obj/item/book/choice = tgui_input_list(user, "Book to remove from the shelf", "Remove Book", sort_names(contents.Copy()))
	if(isnull(choice))
		return
	if(!(user.mobility_flags & MOBILITY_USE) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_range(loc, user))
		return
	if(ishuman(user))
		if(!user.get_active_held_item())
			user.put_in_hands(choice)
	else
		choice.forceMove(drop_location())
	update_appearance()

/obj/structure/bookcase/atom_deconstruct(disassembled = TRUE)
	var/atom/Tsec = drop_location()
	new /obj/item/stack/sheet/mineral/wood(Tsec, 4)
	for(var/obj/item/I in contents)
		if(!isbook(I)) //Wake me up inside
			continue
		I.forceMove(Tsec)

/obj/structure/bookcase/update_icon_state()
	if(state == BOOKCASE_UNANCHORED || state == BOOKCASE_ANCHORED)
		icon_state = "bookempty"
		return ..()
	var/amount = length(contents)
	icon_state = "book-[clamp(amount, 0, 5)]"
	return ..()

/obj/structure/bookcase/manuals/engineering
	name = "engineering manuals bookcase"

/obj/structure/bookcase/manuals/engineering/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/engineering_construction(src)
	new /obj/item/book/manual/wiki/engineering_hacking(src)
	new /obj/item/book/manual/wiki/engineering_guide(src)
	new /obj/item/book/manual/wiki/robotics_cyborgs(src)
	update_appearance()

/obj/structure/bookcase/manuals/research_and_development
	name = "\improper R&D manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/research_and_development(src)
	update_appearance()

#undef BOOKCASE_UNANCHORED
#undef BOOKCASE_ANCHORED
#undef BOOKCASE_FINISHED
