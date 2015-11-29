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
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10

	var/health = 50
	var/tmp/busy = 0
	var/list/valid_types = list(/obj/item/weapon/book, \
								/obj/item/weapon/tome, \
								/obj/item/weapon/spellbook, \
								/obj/item/weapon/storage/bible)

/obj/structure/bookcase/cultify()
	return

/obj/structure/bookcase/initialize()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, valid_types))
			I.forceMove(src)
	update_icon()

/obj/structure/bookcase/proc/healthcheck()

	if(health <= 0)
		visible_message("<span class='warning'>\The [src] breaks apart!</span>")
		getFromPool(/obj/item/stack/sheet/wood, get_turf(src), 3)
		qdel(src)

/obj/structure/bookcase/attackby(obj/O as obj, mob/user as mob)

	if(busy) //So that you can't mess with it while deconstructing
		return
	if(is_type_in_list(O, valid_types))
		user.drop_item(O, src)
		update_icon()
	else if(iscrowbar(O) && user.a_intent == I_HELP) //Only way to deconstruct, needs help intent
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 75, 1)
		user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		busy = 1

		if(do_after(user, src, 50))
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 75, 1)
			user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
			"<span class='notice'>You disassemble \the [src].</span>")
			busy = 0
			getFromPool(/obj/item/stack/sheet/wood, get_turf(src), 5)
			qdel(src)
			return
		else
			busy = 0
		return
	else if(iswrench(O))
		anchored = !anchored
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] [anchored ? "":"un"]anchors \the [src] [anchored ? "to":"from"] the floor.</span>", \
		"<span class='notice'>You [anchored ? "":"un"]anchor the [src] [anchored ? "to":"from"] the floor.</span>")
	else if(istype(O, /obj/item/weapon/pen))
		var/newname = stripped_input(user, "What category title would you like to give to this [name]?")
		if(!newname)
			return
		else
			name = ("bookcase ([sanitize(newname)])")
	else if(O.damtype == BRUTE || O.damtype == BURN)
		user.delayNextAttack(10) //We are attacking the bookshelf
		health -= O.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [O].</span>", \
		"<span class='warning'>You hit \the [src] with \the [O].</span>")
		healthcheck()
	else
		return ..() //Weapon checks for weapons without brute or burn damage type and grab check

/obj/structure/bookcase/attack_hand(var/mob/user as mob)
	if(contents.len)
		var/obj/item/weapon/book/choice = input("Which book would you like to remove from \the [src]?") as null|obj in contents
		if(choice)
			if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting || get_dist(user, src) > 1)
				return
			if(!user.get_active_hand())
				user.put_in_hands(choice)
			else
				choice.forceMove(get_turf(src))
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/I in contents)
				qdel(I)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/I in contents)
				if(prob(50))
					qdel(I)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				qdel(src)
			return
	return

/obj/structure/bookcase/Destroy()

	for(var/obj/item/I in contents)
		if(is_type_in_list(I, valid_types))
			I.forceMove(get_turf(src))
	..()

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
	flags = FPRINT
	attack_verb = list("bashed", "whacked", "educated")

	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 3

	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/wiki_page       // Title of the book's wiki page.
	var/forbidden = 0     // Prevent ordering of this book. (0=no, 1=yes, 2=emag only)
	var/obj/item/store	// What's in the book?

/obj/item/weapon/book/New()
	..()
	if(wiki_page)
		dat = {"
		<html>
			<body>
				<iframe width='100%' height='100%' src="http://ss13.pomf.se/wiki/index.php?title=[wiki_page]&printable=yes"></iframe>
			</body>
		</html>
		"}

/obj/item/weapon/book/cultify()
	new /obj/item/weapon/tome(loc)
	..()

/obj/item/weapon/book/attack_self(var/mob/user as mob)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.loc = get_turf(src.loc)
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")
		user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/weapon/book/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(carved)
		if(!store)
			if(W.w_class < 3)
				user.drop_item(W, src)
				store = W
				to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
				return
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return
	if(istype(W, /obj/item/weapon/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = sanitize(input(usr, "Write your book's contents (HTML NOT allowed):") as message|null)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					src.dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					src.author = newauthor
			else
				return
	else if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		if(!scanner.computer)
			to_chat(user, "[W]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")
	else if(istype(W, /obj/item/weapon/kitchen/utensil/knife/large) || istype(W, /obj/item/weapon/wirecutters))
		if(carved)	return
		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		if(do_after(user, src, 30))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
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
	flags = FPRINT
	var/obj/machinery/computer/library/checkout/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

	attack_self(mob/user as mob)
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
		if(src.computer)
			to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
		else
			to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
		to_chat(user, "\n")
