/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Cachedbook datum from tkdrg, thanks
 *		Library Public Computer
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */

/*
 * Borrowbook datum
 */
datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/category
	var/content

var/global/list/datum/cachedbook/cachedbooks // List of our cached book datums
var/global/list/obj/machinery/librarycomp/library_computers = list()
var/libcomp_menu

/proc/add_book_to_cache(author, title, category, id)
	for(var/obj/machinery/librarycomp/L in library_computers)
		L.booklist += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td><A href='?src=\ref[L];cacheid=[id]'>\[Order\]</A></td></tr>"

/proc/load_library_db_to_cache(force = FALSE)
	if(cachedbooks && !force)
		return

	establish_db_connection()

	if(!dbcon.IsConnected())
		return

	cachedbooks = list()
	var/DBQuery/query = dbcon.NewQuery("SELECT id, author, title, category FROM library")
	query.Execute()

	while(query.NextRow())
		var/datum/cachedbook/newbook = new/datum/cachedbook()
		newbook.id = query.item[1]
		newbook.author = query.item[2]
		newbook.title = query.item[3]
		newbook.category = query.item[4]

		cachedbooks["[newbook.id]"] = newbook

	if(force)
		for(var/obj/machinery/librarycomp/L in library_computers)
			L.build_library_menu()

/*
 * Library Public Computer
 */
/obj/machinery/librarypubliccomp
	name = "visitor computer"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var/screenstate = 0
	var/title
	var/category = "Any"
	var/author
	var/SQLquery

/obj/machinery/librarypubliccomp/cultify()
	new /obj/structure/cult/tome(loc)
	..()

/obj/machinery/librarypubliccomp/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		user << "<span class='danger'>Nope.</span>"
		return
	usr.set_machine(src)
	var/dat = "<HEAD><TITLE>Library Visitor</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:40: dat += "<h2>Search Settings</h2><br>"
			dat += {"<h2>Search Settings</h2><br>
				<A href='?src=\ref[src];settitle=1'>Filter by Title: [title]</A><BR>
				<A href='?src=\ref[src];setcategory=1'>Filter by Category: [category]</A><BR>
				<A href='?src=\ref[src];setauthor=1'>Filter by Author: [author]</A><BR>
				<A href='?src=\ref[src];search=1'>\[Start Search\]</A><BR>"}
			// END AUTOFIX
		if(1)
			establish_old_db_connection()
			if(!dbcon_old.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><BR>"
			else if(!SQLquery)
				dat += "<font color=red><b>ERROR</b>: Malformed search request. Please contact your system administrator for assistance.</font><BR>"
			else

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:52: dat += "<table>"
				dat += {"<table>
					<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>SS<sup>13</sup>BN</td></tr>"}
				// END AUTOFIX
				var/DBQuery/query = dbcon_old.NewQuery(SQLquery)
				query.Execute()

				while(query.NextRow())
					var/author = query.item[2]
					var/title = query.item[3]
					var/category = query.item[4]
					var/id = query.item[1]
					dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				dat += "</table><BR>"
			dat += "<A href='?src=\ref[src];back=1'>\[Go Back\]</A><BR>"
	user << browse(dat, "window=publiclibrary")
	onclose(user, "publiclibrary")

/obj/machinery/librarypubliccomp/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

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
		SQLquery = "SELECT id, author, title, category FROM library WHERE "
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


/*
 * Library Computer
 *
 * TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
 * It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
 * It's 25th of January in the year of (our) Lord 2015... And it's still not a computer.
 */
/obj/machinery/librarycomp
	name = "Check-In/Out Computer"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var/arcanecheckout = 0
	var/screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive

	var/bibledelay = 0 // LOL NO SPAM (1 minute delay) -- Doohl
	var/booklist

	machine_flags = EMAGGABLE

/obj/machinery/librarycomp/New(loc)
	..(loc)
	library_computers.Add(src)

	if(ticker)
		initialize()

/obj/machinery/librarycomp/initialize()
	..()
	build_library_menu()

/obj/machinery/librarycomp/Destroy()
	library_computers -= src
	..()

/obj/machinery/librarycomp/cultify()
	new /obj/structure/cult/tome(loc)
	..()

/obj/machinery/librarycomp/proc/build_library_menu()
	var/menu

	for(var/ID in cachedbooks)
		var/datum/cachedbook/C = cachedbooks[ID]
		menu += "<tr><td>[C.author]</td><td>[C.title]</td><td>[C.category]</td><td><A href='?src=\ref[src];cacheid=[ID]'>\[Order\]</A></td></tr>"

	booklist = menu

/obj/machinery/librarycomp/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		user << "<span class='danger'>Nope.</span>"
		return

	user.set_machine(src)

	var/dat = "<HEAD><TITLE>Book Inventory Management</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>

	switch(screenstate)
		if(0)
			// Main Menu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:141: dat += "<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>"
			dat += {"<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>
				<A href='?src=\ref[src];switchscreen=2'>2. View Checked Out Inventory</A><BR>
				<A href='?src=\ref[src];switchscreen=3'>3. Check out a Book</A><BR>
				<A href='?src=\ref[src];switchscreen=4'>4. Connect to External Archive</A><BR>
				<A href='?src=\ref[src];switchscreen=5'>5. Upload New Title to Archive</A><BR>
				<A href='?src=\ref[src];switchscreen=6'>6. Print a Bible</A><BR>
				<A href='?src=\ref[src];switchscreen=7'>7. Print a Manual</A><BR>"}
			// END AUTOFIX
			if(src.emagged)
				dat += "<A href='?src=\ref[src];switchscreen=8'>8. Access the Forbidden Lore Vault</A><BR>"
			if(src.arcanecheckout)
				new /obj/item/weapon/tome(src.loc)
				user << "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a dusty old tome sitting on the desk. You don't really remember printing it.</span>"
				user.visible_message("[user] stares at the blank screen for a few moments, his expression frozen in fear. When he finally awakens from it, he looks a lot older.", 2)
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

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:175: dat += "\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>"
				dat += {"\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>
					<A href='?src=\ref[src];checkin=\ref[b]'>(Check In)</A><BR><BR>"}
				// END AUTOFIX
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:180: dat += "<h3>Check Out a Book</h3><BR>"
			dat += {"<h3>Check Out a Book</h3><BR>
				Book: [src.buffer_book]
				<A href='?src=\ref[src];editbook=1'>\[Edit\]</A><BR>
				Recipient: [src.buffer_mob]
				<A href='?src=\ref[src];editmob=1'>\[Edit\]</A><BR>
				Checkout Date : [world.time/600]<BR>
				Due Date: [(world.time + checkoutperiod)/600]<BR>
				(Checkout Period: [checkoutperiod] minutes) (<A href='?src=\ref[src];increasetime=1'>+</A>/<A href='?src=\ref[src];decreasetime=1'>-</A>)
				<A href='?src=\ref[src];checkout=1'>(Commit Entry)</A><BR>
				<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"}
			// END AUTOFIX
		if(4)
			dat += "<h3>External Archive</h3>"
			if(!cachedbooks)
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:196: dat += "<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>"
				dat += {"<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>
					<table>
					<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td></td></tr>"}
				// END AUTOFIX
				dat += booklist

				dat += "</table>"
			dat += "<BR><A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
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

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:222: dat += "<TT>Data marked for upload...</TT><BR>"
				dat += {"<TT>Data marked for upload...</TT><BR>
					<TT>Title: </TT>[scanner.cache.name]<BR>"}
				// END AUTOFIX
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:226: dat += "<TT>Author: </TT><A href='?src=\ref[src];setauthor=1'>[scanner.cache.author]</A><BR>"
				dat += {"<TT>Author: </TT><A href='?src=\ref[src];setauthor=1'>[scanner.cache.author]</A><BR>
					<TT>Category: </TT><A href='?src=\ref[src];setcategory=1'>[upload_category]</A><BR>
					<A href='?src=\ref[src];upload=1'>\[Upload\]</A><BR>"}
				// END AUTOFIX
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += "<H3>Print a Manual</H3>"
			dat += "<table>"

			var/list/forbidden = list(
				/obj/item/weapon/book/manual
				)

			if(!emagged)
				forbidden |= /obj/item/weapon/book/manual/nuclear

			var/manualcount = 0
			var/obj/item/weapon/book/manual/M = null

			for(var/manual_type in (typesof(/obj/item/weapon/book/manual) - forbidden))
				M = new manual_type()
				dat += "<tr><td><A href='?src=\ref[src];manual=[manualcount]'>[M.title]</A></td></tr>"
				manualcount++
				del(M)
			dat += "</table>"
			dat += "<BR><A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"

		if(8)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:231: dat += "<h3>Accessing Forbidden Lore Vault v 1.3</h3>"
			dat += {"<h3>Accessing Forbidden Lore Vault v 1.3</h3>
				Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no responsibilities for loss of sanity resulting from this action.<p>
				<A href='?src=\ref[src];arccheckout=1'>Yes.</A><BR>
				<A href='?src=\ref[src];switchscreen=0'>No.</A><BR>"}
			// END AUTOFIX
	//dat += "<A HREF='?src=\ref[user];mach_close=library'>Close</A><br><br>"
	user << browse(dat, "window=library")
	onclose(user, "library")

/obj/machinery/librarycomp/emag(mob/user)
	if(!emagged)
		src.emagged = 1
		user << "\blue You override the library computer's printing restrictions."
		return 1
	return

/obj/machinery/librarycomp/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		user << "[scanner]'s associated machine has been set to [src]."
		for (var/mob/V in hearers(src))
			V.show_message("[src] lets out a low, short blip.", 2)
	else
		return ..()

/obj/machinery/librarycomp/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return

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
					visible_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")

			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
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
		buffer_book = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["editmob"])
		buffer_mob = copytext(sanitize(input("Enter the recipient's name:") as text|null),1,MAX_NAME_LEN)
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
		var/newauthor = copytext(sanitize(input("Enter the author's name: ") as text|null),1,MAX_MESSAGE_LEN)
		if(newauthor)
			scanner.cache.author = newauthor
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					establish_old_db_connection()
					if(!dbcon_old.IsConnected())
						alert("Connection to Archive has been severed. Aborting.")
					else
						var/sqltitle = sanitizeSQL(scanner.cache.name)
						var/sqlauthor = sanitizeSQL(scanner.cache.author)
						var/sqlcontent = sanitizeSQL(scanner.cache.dat)
						var/sqlcategory = sanitizeSQL(upload_category)
						var/DBQuery/query = dbcon_old.NewQuery("INSERT INTO library (author, title, content, category) VALUES ('[sqlauthor]', '[sqltitle]', '[sqlcontent]', '[sqlcategory]')")
						var/response = query.Execute()
						if(!response)
							usr << query.ErrorMsg()
						else
							world.log << response
							log_admin("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs")
							message_admins("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs")
							query = dbcon_old.NewQuery("SELECT id, author, title, content FROM library WHERE title = '[sqltitle]' AND author = '[sqlauthor]' AND category = '[sqlcategory]' ")
							var/datum/cachedbook/newbook = new()
							while(query.NextRow())
								if(query.item[1] in cachedbooks)
									continue //already have this book
								newbook.id = query.item[1]
								newbook.author = query.item[2]
								newbook.title = query.item[3]
								newbook.content = query.item[4]

							cachedbooks["[newbook.id]"] = newbook
							alert("Upload Complete.")
							if(newbook && newbook.id)
								add_book_to_cache(sqlauthor,sqltitle,sqlcategory,newbook.id)

	if(href_list["cacheid"])
		//var/sqlid = sanitizeSQL(href_list["targetid"])
		/*
		establish_old_db_connection()
		if(!dbcon_old.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
		*/
		if(bibledelay)
			for (var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			//var/DBQuery/query = dbcon_old.NewQuery("SELECT * FROM library WHERE id=[sqlid]")
			//query.Execute()
			var/datum/cachedbook/newbook = cachedbooks["[href_list["cacheid"]]"]
			if(!newbook)
				return
			make_external_book(newbook)

	if(href_list["orderbyid"])
		var/orderid = input("Enter your order:") as num|null
		if(orderid)
			if(isnum(orderid))
				spawn()
					orderByID(orderid)
				return

	if(href_list["manual"])
		if(!bibledelay)
			var/list/forbidden = list(
				/obj/item/weapon/book/manual
				)

			if(!emagged)
				forbidden |= /obj/item/weapon/book/manual/nuclear

			var/targetmanual = text2num(href_list["manual"])
			var/currentmanual = 0
			for(var/manual_type in (typesof(/obj/item/weapon/book/manual) - forbidden))
				if(currentmanual == targetmanual)
					new manual_type(src.loc)
					break
				else
					currentmanual++

			bibledelay = 1
			spawn(60)
				bibledelay = 0

		else
			visible_message("<b>[src]</b>'s monitor flashes, \"Manual printer currently unavailable, please wait a moment.\"")


	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Library Scanner
 */

/obj/machinery/librarycomp/proc/make_external_book(var/datum/cachedbook/newbook)
	if(!newbook || !newbook.id)
		return
	var/list/_http = world.Export("http://vg13.undo.it/index.php/book?id=[newbook.id]")
	if(!_http || !_http["CONTENT"])
		return
	var/http = file2text(_http["CONTENT"])
	if(!http)
		return
	var/obj/item/weapon/book/B = new(src.loc)

	B.name = "Book: [newbook.title]"
	B.title = newbook.title
	B.author = newbook.author
	B.dat = http
	B.icon_state = "book[rand(1,7)]"
	src.visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")

/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/libraryscanner/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		user << "<span class='danger'>Nope.</span>"
		return
	usr.set_machine(src)
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
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

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


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

/obj/machinery/bookbinder/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/paper/nano))
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
		return ..()

/obj/machinery/librarycomp/proc/orderByID(var/id)
	if(!id || !isnum(id) || id < 1)
		usr << "<span class='warning'>Invalid SS<sup>13</sup>BN</span>"
		return
	var/datum/cachedbook/found = cachedbooks["[id]"]
	/*
	for(var/datum/cachedbook/newbook in cachedbooks)
		testing("Checking book [newbook]. ([newbook.title], [newbook.id])")
		if(newbook.id == id)
			testing("Found book matching our [id] ([newbook.title], [newbook.id])")
			found = newbook
			break
	*/
	if(!found)
		usr << "<span class='warning'>Unable to locate a book with an SS<sup>13</sup>BN of [id]</span>"
		return
	make_external_book(found)