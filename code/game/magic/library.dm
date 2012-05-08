//*******************************
//
//	Library SQL Configuration
//
//*******************************

// Deprecated! See global.dm for new SQL config vars -- TLE
/*
#define SQL_ADDRESS ""
#define SQL_DB ""
#define SQL_PORT "3306"
#define SQL_LOGIN ""
#define SQL_PASS ""
*/

//*******************************
// Requires Dantom.DB library ( http://www.byond.com/developer/Dantom/DB )


/*
   The Library
   ------------
   A place for the crew to go, relax, and enjoy a good book.
   Aspiring authors can even self publish and, if they're lucky
   convince the on-staff Librarian to submit it to the Archives
   to be chronicled in history forever - some say even persisting
   through alternate dimensions.


   Written by TLE for /tg/station 13
   Feel free to use this as you like. Some credit would be cool.
   Check us out at http://nanotrasen.com/ if you're so inclined.
*/

// CONTAINS:

// Objects:
//  - bookcase
//  - book
//  - barcode scanner
// Machinery:
//  - library computer
//  - visitor's computer
//  - book binder
//  - book scanner
// Datum:
//	- borrowbook


// Ideas for the future
// ---------------------
// 	- Visitor's computer should be able to search the current in-round library inventory (that the Librarian has stocked and checked in)
//  -- Give computer other features like an Instant Messenger application, or the ability to edit, save, and print documents.
//	- Admin interface directly tied to the Archive DB. Right now there's no way to delete uploaded books in-game.
//  -- If this gets implemented, allow Librarians to "tag" or "suggest" books to be deleted. The DB ID of the tagged books gets saved to a text file (or another table in the DB maybe?).
//	   The admin interface would automatically take these IDs and SELECT them all from the DB to be displayed along with a Delete link to drop the row from the table.
//	- When the game sets up and the round begins, have it automatically pick random books from the DB to populate the library with. Even if the Librarian is a useless fuck there are at least a few books around.
//  - Allow books to be "hollowed out" like the Chaplain's Bible, allowing you to store one pocket-sized item inside.
//  - Make books/book cases burn when exposed to flame.
//  - Make book binder hackable.
//  - Books shouldn't print straight from the library computer. Make it synch with a machine like the book binder to print instead. This should consume some sort of resource.


// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(var/t as text)
	var/sanitized_text = dd_replacetext(t, "'", "\\'")
	sanitized_text = dd_replacetext(sanitized_text, "\"", "\\\"")
	return sanitized_text



/obj/structure/bookcase
	name = "bookcase"
	icon = 'library.dmi'
	icon_state = "bookcase"
	anchored = 1
	density = 1
	opacity = 1

	attackby(obj/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/book))
			user.drop_item()
			O.loc = src
		else if(istype(O, /obj/item/weapon/pen))
			var/newname = input("What would you like to title this bookshelf?") as text|null
			if(!newname)
				return
			else
				src.setname(sanitize(newname))
		else
			..()
	attack_hand(var/mob/user as mob)
		var/list/books = list()
		for(var/obj/item/weapon/book/b in src.contents)
			books.Add(b)
		if(books.len)
			var/obj/item/weapon/book/choice = input("Which book would you like to remove from the shelf?") in books as obj|null
			if(choice)
				choice.loc = src.loc
			else
				return
		else
			user << "None of these books pique your interest in the slightest."

	proc
		setname(var/t as text)
			if(t)
				src.name = "bookcase ([t])"

	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/obj/item/weapon/book/b in src.contents)
					del(b)
				del(src)
				return
			if(2.0)
				for(var/obj/item/weapon/book/b in src.contents)
					if (prob(50)) b.loc = (get_turf(src))
					else del(b)
				del(src)
				return
			if(3.0)
				if (prob(50))
					for(var/obj/item/weapon/book/b in src.contents)
						b.loc = (get_turf(src))
					del(src)
				return
			else
		return


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/medical_cloning(src)


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

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/research_and_development(src)






/obj/item/weapon/book
	name = "book"
	icon = 'library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var
		dat			 // Actual page content
		due_date = 0 // Game time in 1/10th seconds
		author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
		unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
		title		 // The real name of the book.

	attack_self(var/mob/user as mob)
		if(src.dat)
			user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")
			user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
			onclose(user, "book")
		else
			user << "This book is completely blank!"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/pen))
			if(unique)
				user << "These pages don't seem to take the ink well. Looks like you can't modify it."
				return
			var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
			switch(choice)
				if("Title")
					var/title = input("Write a new title:") as text|null
					if(!title)
						return
					else
						src.name = sanitize(title)
				else if("Contents")
					var/content = strip_html(input("Write your book's contents (HTML NOT allowed):"),8192) as message|null
					if(!content)
						return
					else
						src.dat += content
				else if("Author")
					var/nauthor = input("Write the author's name:") as text|null
					if(!nauthor)
						return
					else
						src.author = sanitize(nauthor)
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
		else
			..()












/obj/item/weapon/barcodescanner
	name = "barcode scanner"
	icon = 'library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var
		obj/machinery/librarycomp/computer // Associated computer - Modes 1 to 3 use this
		obj/item/weapon/book/book	 //  Currently scanned book
		mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

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










datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var
		bookname
		mobname
		getdate
		duedate








/obj/machinery/librarypubliccomp
	name = "visitor computer"
	icon = 'library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var
		screenstate = 0
		title
		category = "Any"
		author
		SQLquery


/obj/machinery/librarypubliccomp/attack_hand(var/mob/user as mob)
	usr.machine = src
	var/dat = "<HEAD><TITLE>Library Visitor</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			dat += "<h2>Search Settings</h2><br>"
			dat += "<A href='?src=\ref[src];settitle=1'>Filter by Title: [title]</A><BR>"
			dat += "<A href='?src=\ref[src];setcategory=1'>Filter by Category: [category]</A><BR>"
			dat += "<A href='?src=\ref[src];setauthor=1'>Filter by Author: [author]</A><BR>"
			dat += "<A href='?src=\ref[src];search=1'>\[Start Search\]</A><BR>"
		if(1)
			var/DBConnection/dbcon = new()
			dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
			if(!dbcon.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><BR>"
			else if(!SQLquery)
				dat += "<font color=red><b>ERROR</b>: Malformed search request. Please contact your system administrator for assistance.</font><BR>"
			else
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>SS<sup>13</sup>BN</td></tr>"

				var/DBQuery/query = dbcon.NewQuery(SQLquery)
				query.Execute()

				while(query.NextRow())
					var/author = query.item[1]
					var/title = query.item[2]
					var/category = query.item[3]
					var/id = query.item[4]
					dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				dat += "</table><BR>"
			dbcon.Disconnect()
			dat += "<A href='?src=\ref[src];back=1'>\[Go Back\]</A><BR>"
	user << browse(dat, "window=publiclibrary")
	onclose(user, "publiclibrary")


/obj/machinery/librarypubliccomp/Topic(href, href_list)
	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			title = sanitize(newtitle)
		else
			title = null
		title = sanitizeSQL(title)
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			category = sanitize(newcategory)
		else
			category = "Any"
		category = sanitizeSQL(category)
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			author = sanitize(newauthor)
		else
			author = null
		author = sanitizeSQL(author)
	if(href_list["search"])
		SQLquery = "SELECT author, title, category, id FROM library WHERE "
		if(category == "Any")
			SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%'"
		else
			SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%' AND category='[category]'"
		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return



// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such

/obj/machinery/librarycomp
	name = "Check-In/Out Computer"
	icon = 'library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var
		arcanecheckout = 0
		screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
		buffer_book
		buffer_mob
		upload_category = "Fiction"
		list/checkouts = list()
		list/inventory = list()
		checkoutperiod = 5 // In minutes
		obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive

		bibledelay = 0 // LOL NO SPAM (1 minute delay) -- Doohl

/obj/machinery/librarycomp/attack_hand(var/mob/user as mob)
	usr.machine = src
	var/dat = "<HEAD><TITLE>Book Inventory Management</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			// Main Menu
			dat += "<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=2'>2. View Checked Out Inventory</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=3'>3. Check out a Book</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=4'>4. Connect to External Archive</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=5'>5. Upload New Title to Archive</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=6'>6. Print a Bible</A><BR>"
			if(src.emagged)
				dat += "<A href='?src=\ref[src];switchscreen=7'>7. Access the Forbidden Lore Vault</A><BR>"
			if(src.arcanecheckout)
				new /obj/item/weapon/tome(src.loc)
				user << "<font color=red>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a dusty old tome sitting on the desk. You don't really remember printing it.</font>"
				for (var/mob/V in hearers(src))
					V.show_message("[usr] stares at the blank screen for a few moments, his expression frozen in fear. When he finally awakens from it, he looks a lot older.", 2)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<H3>Inventory</H3><BR>"
			for(var/obj/item/weapon/book/b in inventory)
				dat += "[b.name] <A href='?src=\ref[src];delbook=\ref[b]'>(Delete)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(2)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				//timetaken *= 10
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				//timedue *= 10
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)
				dat += "\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>"
				dat += "<A href='?src=\ref[src];checkin=\ref[b]'>(Check In)</A><BR><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book
			dat += "<h3>Check Out a Book</h3><BR>"
			dat += "Book: [src.buffer_book] "
			dat += "<A href='?src=\ref[src];editbook=1'>\[Edit\]</A><BR>"
			dat += "Recipient: [src.buffer_mob] "
			dat += "<A href='?src=\ref[src];editmob=1'>\[Edit\]</A><BR>"
			dat += "Checkout Date : [world.time/600]<BR>"
			dat += "Due Date: [(world.time + checkoutperiod)/600]<BR>"
			dat += "(Checkout Period: [checkoutperiod] minutes) (<A href='?src=\ref[src];increasetime=1'>+</A>/<A href='?src=\ref[src];decreasetime=1'>-</A>)"
			dat += "<A href='?src=\ref[src];checkout=1'>(Commit Entry)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(4)
			dat += "<h3>External Archive</h3>"
			var/DBConnection/dbcon = new()
			dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
			if(!dbcon.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				dat += "<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>"
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td></td></tr>"

				var/DBQuery/query = dbcon.NewQuery("SELECT id, author, title, category FROM library")
				query.Execute()

				while(query.NextRow())
					var/id = query.item[1]
					var/author = query.item[2]
					var/title = query.item[3]
					var/category = query.item[4]
					dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td><A href='?src=\ref[src];targetid=[id]'>\[Order\]</A></td></tr>"
				dat += "</table><BR>"
				dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
			dbcon.Disconnect()
		if(5)
			dat += "<H3>Upload a New Title</H3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += "<TT>Data marked for upload...</TT><BR>"
				dat += "<TT>Title: </TT>[scanner.cache.name]<BR>"
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"
				dat += "<TT>Author: </TT><A href='?src=\ref[src];setauthor=1'>[scanner.cache.author]</A><BR>"
				dat += "<TT>Category: </TT><A href='?src=\ref[src];setcategory=1'>[upload_category]</A><BR>"
				dat += "<A href='?src=\ref[src];upload=1'>\[Upload\]</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += "<h3>Accessing Forbidden Lore Vault v 1.3</h3>"
			dat += "Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no responsibilities for loss of sanity resulting from this action.<p>"
			dat += "<A href='?src=\ref[src];arccheckout=1'>Yes.</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>No.</A><BR>"

	//dat += "<A HREF='?src=\ref[user];mach_close=library'>Close</A><br><br>"
	user << browse(dat, "window=library")
	onclose(user, "library")

/obj/machinery/librarycomp/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.density && istype(W, /obj/item/weapon/card/emag))
		src.emagged = 1
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		user << "[scanner]'s associated machine has been set to [src]."
		for (var/mob/V in hearers(src))
			V.show_message("[src] lets out a low, short blip.", 2)
	else
		..()

/obj/machinery/librarycomp/Topic(href, href_list)
	if(href_list["switchscreen"])
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				if(!bibledelay)

					var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(src.loc)
					if(ticker && ( ticker.Bible_icon_state && ticker.Bible_item_state) )
						B.icon_state = ticker.Bible_icon_state
						B.item_state = ticker.Bible_item_state
						B.name = ticker.Bible_name
						B.deity_name = ticker.Bible_deity_name

					bibledelay = 1
					spawn(60)
						bibledelay = 0

				else
					for (var/mob/V in hearers(src))
						V.show_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")

			if("7")
				screenstate = 7
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = input("Enter the book's title:") as text|null
	if(href_list["editmob"])
		buffer_mob = input("Enter the recipient's name:") as text|null
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"])
		checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/weapon/book/b = locate(href_list["delbook"])
		inventory.Remove(b)
	if(href_list["setauthor"])
		var/newauthor = input("Enter the author's name: ") as text|null
		if(newauthor)
			scanner.cache.author = sanitize(newauthor)
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					var/DBConnection/dbcon = new()
					dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
					if(!dbcon.IsConnected())
						alert("Connection to Archive has been severed. Aborting.")
					else
						/*
						var/sqltitle = dbcon.Quote(scanner.cache.name)
						var/sqlauthor = dbcon.Quote(scanner.cache.author)
						var/sqlcontent = dbcon.Quote(scanner.cache.dat)
						var/sqlcategory = dbcon.Quote(upload_category)
						*/
						var/sqltitle = sanitizeSQL(scanner.cache.name)
						var/sqlauthor = sanitizeSQL(scanner.cache.author)
						var/sqlcontent = sanitizeSQL(scanner.cache.dat)
						var/sqlcategory = sanitizeSQL(upload_category)
						var/DBQuery/query = dbcon.NewQuery("INSERT INTO library (author, title, content, category) VALUES ('[sqlauthor]', '[sqltitle]', '[sqlcontent]', '[sqlcategory]')")
						if(!query.Execute())
							usr << query.ErrorMsg()
						else
							log_game("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs")
							alert("Upload Complete.")
						dbcon.Disconnect()
	if(href_list["targetid"])




		var/sqlid = sanitizeSQL(href_list["targetid"])
		var/DBConnection/dbcon = new()
		dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
		if(!dbcon.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
		if(bibledelay)
			for (var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			var/DBQuery/query = dbcon.NewQuery("SELECT * FROM library WHERE id=\"[sqlid]\"")
			query.Execute()

			while(query.NextRow())
				var/author = query.item[2]
				var/title = query.item[3]
				var/content = query.item[4]
				var/obj/item/weapon/book/B = new(src.loc)
				B.name = "Book: [title]"
				B.title = title
				B.author = author
				B.dat = content
				B.icon_state = "book[rand(1,7)]"
				src.visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
				break
			dbcon.Disconnect()
	if(href_list["orderbyid"])
		var/orderid = input("Enter your order:") as num|null
		if(orderid)
			orderid = sanitizeSQL(orderid)
			var/nhref = "src=\ref[src];targetid=[orderid]"
			spawn() src.Topic(nhref, params2list(nhref), src)
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return













/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var
		obj/item/weapon/book/cache		// Last scanned book



/obj/machinery/libraryscanner/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src


/obj/machinery/libraryscanner/attack_hand(var/mob/user as mob)
	usr.machine = src
	var/dat = "<HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	user << browse(dat, "window=scanner")
	onclose(user, "scanner")

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return








/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

	attackby(var/obj/O as obj, var/mob/user as mob)
		if(istype(O, /obj/item/weapon/paper))
			user.drop_item()
			O.loc = src
			user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
			src.visible_message("[src] begins to hum as it warms up its printing drums.")
			sleep(rand(200,400))
			src.visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/weapon/book/b = new(src.loc)
			b.dat = O:info
			b.name = "Print Job #" + "[rand(100, 999)]"
			b.icon_state = "book[rand(1,7)]"
			del(O)
		else
			..()