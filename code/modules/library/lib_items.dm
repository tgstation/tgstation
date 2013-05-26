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
	anchored = 0
	density = 1
	opacity = 1
	var/state = 0


/obj/structure/bookcase/initialize()
	state = 2
	icon_state = "book-0"
	anchored = 1
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/weapon/book))
			I.loc = src
	update_icon()


/obj/structure/bookcase/attackby(obj/item/I, mob/user)
	switch(state)
		if(0)
			if(istype(I, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				if(do_after(user, 20))
					user << "<span class='notice'>You wrench the frame into place.</span>"
					anchored = 1
					state = 1
			if(istype(I, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
				if(do_after(user, 20))
					user << "<span class='notice'>You pry the frame apart.</span>"
					new /obj/item/stack/sheet/wood(loc, 4)
					del(src)

		if(1)
			if(istype(I, /obj/item/stack/sheet/wood))
				var/obj/item/stack/sheet/wood/W = I
				W.use(2)
				user << "<span class='notice'>You add a shelf.</span>"
				state = 2
				icon_state = "book-0"
			if(istype(I, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class='notice'>You unwrench the frame.</span>"
				anchored = 0
				state = 0

		if(2)
			if(istype(I, /obj/item/weapon/book))
				user.drop_item()
				I.loc = src
				update_icon()
			else if(istype(I, /obj/item/weapon/pen))
				var/newname = stripped_input(usr, "What would you like to title this bookshelf?")
				if(!newname)
					return
				else
					name = ("bookcase ([sanitize(newname)])")
			else if(istype(I, /obj/item/weapon/crowbar))
				if(contents.len)
					user << "<span class='notice'>You need to remove the books first.</span>"
				else
					playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
					user << "<span class='notice'>You pry the shelf out.</span>"
					new /obj/item/stack/sheet/wood(loc, 1)
					state = 1
					icon_state = "bookempty"
			else
				..()


/obj/structure/bookcase/attack_hand(mob/user)
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
				del(b)
			del(src)
		if(2.0)
			for(var/obj/item/weapon/book/b in contents)
				if(prob(50))
					b.loc = (get_turf(src))
				else
					del(b)
			del(src)
		if(3.0)
			if(prob(50))
				for(var/obj/item/weapon/book/b in contents)
					b.loc = (get_turf(src))
				del(src)


/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "medical manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/medical_cloning(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "engineering manuals bookcase"

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
	name = "\improper R&D manuals bookcase"

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
	var/dat				//Actual page content
	var/due_date = 0	//Game time in 1/10th seconds
	var/author			//Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0		//0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title			//The real name of the book.
	var/carved = 0		//Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	//What's in the book?


/obj/item/weapon/book/attack_self(mob/user)
	if(carved)
		if(store)
			user << "<span class='notice'>[store] falls out of [title]!</span>"
			store.loc = get_turf(loc)
			store = null
			return
		else
			user << "<span class='notice'>The pages of [title] have been cut out!</span>"
			return

	if(is_blind(user))
		return

	if(dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")
		user.visible_message("[user] opens a book titled \"[title]\" and begins reading intently.")
		onclose(user, "book")
	else
		user << "<span class='notice'>This book is completely blank!</span>"


/obj/item/weapon/book/attackby(obj/item/I, mob/user)
	if(carved)
		if(!store)
			if(I.w_class < 3)
				user.drop_item()
				I.loc = src
				store = I
				user << "<span class='notice'>You put [I] in [title].</span>"
				return
			else
				user << "<span class='notice'>[I] won't fit in [title].</span>"
				return
		else
			user << "<span class='notice'>There's already something in [title]!</span>"
			return

	if(istype(I, /obj/item/weapon/pen))
		if(is_blind(user))
			return
		if(unique)
			user << "<span class='notice'>These pages don't seem to take the ink well. Looks like you can't modify it.</span>"
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					usr << "The title is invalid."
					return
				else
					name = newtitle
					title = newtitle
			if("Contents")
				var/content = strip_html(input(usr, "Write your book's contents (HTML NOT allowed):"),8192) as message|null
				if(!content)
					usr << "The content is invalid."
					return
				else
					dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					usr << "The name is invalid."
					return
				else
					author = newauthor
			else
				return

	else if(istype(I, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = I
		if(!scanner.computer)
			user << "[I]'s screen flashes: 'No associated computer found!'"
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					user << "[I]'s screen flashes: 'Book stored in buffer.'"
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = name
					user << "[I]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'"
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == name)
							scanner.computer.checkouts.Remove(b)
							user << "[I]'s screen flashes: 'Book stored in buffer. Book has been checked in.'"
							return
					user << "[I]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'"
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							user << "[I]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'"
							return
					scanner.computer.inventory.Add(src)
					user << "[I]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'"

	else if(istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/wirecutters))
		if(carved)
			return
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
	var/obj/machinery/librarycomp/computer	//Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book			//Currently scanned book
	var/mode = 0							//0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

	attack_self(mob/user)
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
		if(computer)
			user << "<font color=green>Computer has been associated with this unit.</font>"
		else
			user << "<font color=red>No associated computer found. Only local scans will function properly.</font>"
		user << "\n"