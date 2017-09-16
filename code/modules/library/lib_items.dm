/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */

/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookempty"
	anchored = FALSE
	density = TRUE
	opacity = 0
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 0)
	var/state = 0
	var/list/allowed_books = list(/obj/item/book, /obj/item/spellbook, /obj/item/storage/book) //Things allowed in the bookcase


/obj/structure/bookcase/Initialize(mapload)
	..()
	if(!mapload)
		return
	state = 2
	icon_state = "book-0"
	anchored = TRUE
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/book))
			I.loc = src
	update_icon()


/obj/structure/bookcase/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 100, 1)
				if(do_after(user, 20*I.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = TRUE
					state = 1
			if(istype(I, /obj/item/crowbar))
				playsound(loc, I.usesound, 100, 1)
				if(do_after(user, 20*I.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You pry the frame apart.</span>")
					deconstruct(TRUE)

		if(1)
			if(istype(I, /obj/item/stack/sheet/mineral/wood))
				var/obj/item/stack/sheet/mineral/wood/W = I
				if(W.get_amount() >= 2)
					W.use(2)
					to_chat(user, "<span class='notice'>You add a shelf.</span>")
					state = 2
					icon_state = "book-0"
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You unwrench the frame.</span>")
				anchored = FALSE
				state = 0

		if(2)
			if(is_type_in_list(I, allowed_books))
				if(!user.drop_item())
					return
				I.loc = src
				update_icon()
			else if(istype(I, /obj/item/storage/bag/books))
				var/obj/item/storage/bag/books/B = I
				for(var/obj/item/T in B.contents)
					if(istype(T, /obj/item/book) || istype(T, /obj/item/spellbook))
						B.remove_from_storage(T, src)
				to_chat(user, "<span class='notice'>You empty \the [I] into \the [src].</span>")
				update_icon()
			else if(istype(I, /obj/item/pen))
				var/newname = stripped_input(user, "What would you like to title this bookshelf?")
				if(!newname)
					return
				else
					name = ("bookcase ([sanitize(newname)])")
			else if(istype(I, /obj/item/crowbar))
				if(contents.len)
					to_chat(user, "<span class='warning'>You need to remove the books first!</span>")
				else
					playsound(loc, I.usesound, 100, 1)
					to_chat(user, "<span class='notice'>You pry the shelf out.</span>")
					new /obj/item/stack/sheet/mineral/wood(loc, 2)
					state = 1
					icon_state = "bookempty"
			else
				return ..()


/obj/structure/bookcase/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/book/choice = input("Which book would you like to remove from the shelf?") as null|obj in contents
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_held_item())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()


/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(loc, 4)
	for(var/obj/item/book/B in contents)
		B.forceMove(get_turf(src))
	qdel(src)


/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "medical manuals bookcase"

/obj/structure/bookcase/manuals/medical/New()
	..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "engineering manuals bookcase"

/obj/structure/bookcase/manuals/engineering/New()
	..()
	new /obj/item/book/manual/wiki/engineering_construction(src)
	new /obj/item/book/manual/engineering_particle_accelerator(src)
	new /obj/item/book/manual/wiki/engineering_hacking(src)
	new /obj/item/book/manual/wiki/engineering_guide(src)
	new /obj/item/book/manual/engineering_singularity_safety(src)
	new /obj/item/book/manual/robotics_cyborgs(src)
	update_icon()


/obj/structure/bookcase/manuals/research_and_development
	name = "\improper R&D manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/New()
	..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon()


/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	resistance_flags = FLAMMABLE
	var/dat				//Actual page content
	var/due_date = 0	//Game time in 1/10th seconds
	var/author			//Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0		//0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title			//The real name of the book.
	var/window_size = null // Specific window size for the book, i.e: "1920x1080", Size x Width

/obj/item/book/attack_self(mob/user)
	if(is_blind(user))
		to_chat(user, "<span class='warning'>As you are trying to read, you suddenly feel very stupid!</span>")
		return
	if(ismonkey(user))
		to_chat(user, "<span class='notice'>You skim through the book but can't comprehend any of it.</span>")
		return
	if(dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book[window_size != null ? ";size=[window_size]" : ""]")
		user.visible_message("[user] opens a book titled \"[title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "<span class='notice'>This book is completely blank!</span>")


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen))
		if(is_blind(user))
			to_chat(user, "<span class='warning'> As you are trying to write on the book, you suddenly feel very stupid!</span>")
			return
		if(unique)
			to_chat(user, "<span class='warning'>These pages don't seem to take the ink well! Looks like you can't modify it.</span>")
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if (length(newtitle) > 20)
					to_chat(usr, "That title won't fit on the cover!")
					return
				if(!newtitle)
					to_chat(usr, "That title is invalid.")
					return
				else
					name = newtitle
					title = newtitle
			if("Contents")
				var/content = stripped_input(usr, "Write your book's contents (HTML NOT allowed):","","",8192)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					author = newauthor
			else
				return

	else if(istype(I, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = I
		if(!scanner.computer)
			to_chat(user, "[I]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = name
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")

	else if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>You begin to carve out [title]...</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
			var/obj/item/storage/book/B = new
			B.name = src.name
			B.title = src.title
			B.icon_state = src.icon_state
			if(user.is_holding(src))
				qdel(src)
				user.put_in_hands(B)
				return
			else
				B.loc = src.loc
				qdel(src)
				return
		return
	else
		..()


/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/computer/libraryconsole/bookmanagement/computer	//Associated computer - Modes 1 to 3 use this
	var/obj/item/book/book			//Currently scanned book
	var/mode = 0							//0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > 3)
		mode = 0
	to_chat(user, "[src] Status Display:")
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Scan book to local buffer."
		if(1)
			modedesc = "Scan book to local buffer and set associated computer buffer to match."
		if(2)
			modedesc = "Scan book to local buffer, attempt to check in scanned book."
		if(3)
			modedesc = "Scan book to local buffer, attempt to add book to general inventory."
		else
			modedesc = "ERROR"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(computer)
		to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
	else
		to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
	to_chat(user, "\n")
