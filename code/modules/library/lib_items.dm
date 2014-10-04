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
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1
	var/health = 50

	autoignition_temperature = AUTOIGNITION_WOOD


/obj/structure/bookcase/initialize()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/weapon/book))
			I.loc = src
	update_icon()

/obj/structure/bookcase/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src
		update_icon()
	else if(istype(O, /obj/item/weapon/wrench))
		user << "\blue Now disassembling bookcase"
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user,50))
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			density = 0
			qdel(src)
		return
	else if(istype(O, /obj/item/weapon/pen))
		var/newname = stripped_input(usr, "What would you like to title this bookshelf?")
		if(!newname)
			return
		else
			name = ("bookcase ([sanitize(newname)])")
	else
		switch(O.damtype)
			if("fire")
				src.health -= O.force * 1
			if("brute")
				src.health -= O.force * 0.75
			else
		if (src.health <= 0)
			visible_message("<span class=warning>The bookcase is smashed apart!</span>")
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			new /obj/item/stack/sheet/wood(get_turf(src))
			qdel(src)
		..()

/obj/structure/bookcase/attack_hand(var/mob/user as mob)
	if(contents.len)
		var/obj/item/weapon/book/choice = input("Which book would you like to remove from the shelf?") in contents as obj|null
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/book/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/weapon/book/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else qdel(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/weapon/book/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
		else
	return

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/medical_cloning(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/engineering_construction(src)
		new /obj/item/weapon/book/manual/engineering_particle_accelerator(src)
		new /obj/item/weapon/book/manual/engineering_hacking(src)
		new /obj/item/weapon/book/manual/engineering_guide(src)
		new /obj/item/weapon/book/manual/engineering_singularity_safety(src)
		new /obj/item/weapon/book/manual/robotics_cyborgs(src)
		update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/research_and_development(src)
		update_icon()


/*
 * Book
 */
/obj/item/weapon/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 3		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	flags = FPRINT | TABLEPASS
	attack_verb = list("bashed", "whacked", "educated")

	autoignition_temperature = AUTOIGNITION_PAPER


	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	//What's in the book?

/obj/item/weapon/book/attack_self(var/mob/user as mob)
	if(carved)
		if(store)
			user << "<span class='notice'>[store] falls out of [title]!</span>"
			store.loc = get_turf(src.loc)
			store = null
			return
		else
			user << "<span class='notice'>The pages of [title] have been cut out!</span>"
			return
	if(src.dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")
		user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else
		user << "This book is completely blank!"

/obj/item/weapon/book/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(carved)
		if(!store)
			if(W.w_class < 3)
				user.drop_item()
				W.loc = src
				store = W
				user << "<span class='notice'>You put [W] in [title].</span>"
				return
			else
				user << "<span class='notice'>[W] won't fit in [title].</span>"
				return
		else
			user << "<span class='notice'>There's already something in [title]!</span>"
			return
	if(istype(W, /obj/item/weapon/pen))
		if(unique)
			user << "These pages don't seem to take the ink well. Looks like you can't modify it."
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					usr << "The title is invalid."
					return
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = sanitize(input(usr, "Write your book's contents (HTML NOT allowed):") as message|null)
				if(!content)
					usr << "The content is invalid."
					return
				else
					src.dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					usr << "The name is invalid."
					return
				else
					src.author = newauthor
			else
				return
	else if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		if(!scanner.computer)
			user << "[W]'s screen flashes: 'No associated computer found!'"
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					user << "[W]'s screen flashes: 'Book stored in buffer.'"
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					user << "[W]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'"
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							user << "[W]'s screen flashes: 'Book stored in buffer. Book has been checked in.'"
							return
					user << "[W]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'"
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							user << "[W]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'"
							return
					scanner.computer.inventory.Add(src)
					user << "[W]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'"
	else if(istype(W, /obj/item/weapon/kitchenknife) || istype(W, /obj/item/weapon/wirecutters))
		if(carved)	return
		user << "<span class='notice'>You begin to carve out [title].</span>"
		if(do_after(user, 30))
			user << "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>"
			carved = 1
			return
	else
		..()


/*
 * Barcode Scanner
 */
/obj/item/weapon/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var/obj/machinery/librarycomp/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

	attack_self(mob/user as mob)
		mode += 1
		if(mode > 3)
			mode = 0
		user << "[src] Status Display:"
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
		user << " - Mode [mode] : [modedesc]"
		if(src.computer)
			user << "<font color=green>Computer has been associated with this unit.</font>"
		else
			user << "<font color=red>No associated computer found. Only local scans will function properly.</font>"
		user << "\n"