/* Library Machines
 *
 * Contains:
 * Borrowbook datum
 * Library Public Computer
 * Cachedbook datum
 * Library Computer
 * Library Scanner
 * Book Binder
 */



/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/libraryconsole
	desc = "Checked out books MUST be returned on time."
	var/screenstate = 0
	var/title
	var/category = "Any"
	var/author
	var/search_page = 0
	COOLDOWN_DECLARE(library_visitor_topic_cooldown)

/obj/machinery/computer/libraryconsole/ui_interact(mob/user)
	. = ..()
	var/list/dat = list() // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			dat += "<h2>Search Settings</h2><br>"
			dat += "<A href='?src=[REF(src)];settitle=1'>Filter by Title: [title]</A><BR>"
			dat += "<A href='?src=[REF(src)];setcategory=1'>Filter by Category: [category]</A><BR>"
			dat += "<A href='?src=[REF(src)];setauthor=1'>Filter by Author: [author]</A><BR>"
			dat += "<A href='?src=[REF(src)];search=1'>\[Start Search\]</A><BR>"
		if(1)
			if (!SSdbcore.Connect())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><BR>"
			else if(QDELETED(user))
				return
			else
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>SS<sup>13</sup>BN</td></tr>"
				var/SQLsearch = "isnull(deleted) AND "
				if(category == "Any")
					SQLsearch += "author LIKE '%[author]%' AND title LIKE '%[title]%'"
				else
					SQLsearch += "author LIKE '%[author]%' AND title LIKE '%[title]%' AND category='[category]'"
				var/bookcount = 0
				var/booksperpage = 20
				var/datum/db_query/query_library_count_books = SSdbcore.NewQuery({"
					SELECT COUNT(id) FROM [format_table_name("library")]
					WHERE isnull(deleted)
						AND author LIKE CONCAT('%',:author,'%')
						AND title LIKE CONCAT('%',:title,'%')
						AND (:category = 'Any' OR category = :category)
				"}, list("author" = author, "title" = title, "category" = category))
				if(!query_library_count_books.warn_execute())
					qdel(query_library_count_books)
					return
				if(query_library_count_books.NextRow())
					bookcount = text2num(query_library_count_books.item[1])
				qdel(query_library_count_books)
				if(bookcount > booksperpage)
					dat += "<b>Page: </b>"
					var/pagecount = 1
					var/list/pagelist = list()
					while(bookcount > 0)
						pagelist += "<a href='?src=[REF(src)];bookpagecount=[pagecount - 1]'>[pagecount == search_page + 1 ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
						bookcount -= booksperpage
						pagecount++
					dat += pagelist.Join(" | ")
				search_page = text2num(search_page)
				var/datum/db_query/query_library_list_books = SSdbcore.NewQuery({"
					SELECT author, title, category, id
					FROM [format_table_name("library")]
					WHERE isnull(deleted)
						AND author LIKE CONCAT('%',:author,'%')
						AND title LIKE CONCAT('%',:title,'%')
						AND (:category = 'Any' OR category = :category)
					LIMIT :skip, :take
				"}, list("author" = author, "title" = title, "category" = category, "skip" = booksperpage * search_page, "take" = booksperpage))
				if(!query_library_list_books.Execute())
					dat += "<font color=red><b>ERROR</b>: Unable to retrieve book listings. Please contact your system administrator for assistance.</font><BR>"
				else
					while(query_library_list_books.NextRow())
						var/author = query_library_list_books.item[1]
						var/title = query_library_list_books.item[2]
						var/category = query_library_list_books.item[3]
						var/id = query_library_list_books.item[4]
						dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				qdel(query_library_list_books)
				if(QDELETED(user))
					return
				dat += "</table><BR>"
			dat += "<A href='?src=[REF(src)];back=1'>\[Go Back\]</A><BR>"
	var/datum/browser/popup = new(user, "publiclibrary", name, 600, 400)
	popup.set_content(jointext(dat, ""))
	popup.open()

/obj/machinery/computer/libraryconsole/Topic(href, href_list)
	if(!COOLDOWN_FINISHED(src, library_visitor_topic_cooldown))
		return
	COOLDOWN_START(src, library_visitor_topic_cooldown, 1 SECONDS)
	. = ..()
	if(.)
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			title = sanitize(newtitle)
		else
			title = null
	if(href_list["setcategory"])
		var/newcategory = tgui_input_list(usr, "Choose a category to search for:",, list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion"))
		if(newcategory)
			category = sanitize(newcategory)
		else
			category = "Any"
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			author = sanitize(newauthor)
		else
			author = null
	if(href_list["search"])
		screenstate = 1

	if(href_list["bookpagecount"])
		search_page = text2num(href_list["bookpagecount"])

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

#define PRINTER_COOLDOWN 60

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/bookmanagement
	name = "book inventory management console"
	desc = "Librarian's command station."
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	pass_flags = PASSTABLE

	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/libraryconsole

	var/screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book

	var/arcanecheckout = 0
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive
	var/page = 1 //current page of the external archives
	var/printer_cooldown = 0
	COOLDOWN_DECLARE(library_console_topic_cooldown)

/obj/machinery/computer/bookmanagement/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "Book Inventory Management Console (Machine Board)"
		circuit.build_path = /obj/machinery/computer/bookmanagement

/obj/machinery/computer/bookmanagement/ui_interact(mob/user)
	. = ..()
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			// Main Menu
			dat += "<A href='?src=[REF(src)];switchscreen=1'>1. View General Inventory</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=2'>2. View Checked Out Inventory</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=3'>3. Check out a Book</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=4'>4. Connect to External Archive</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=5'>5. Upload New Title to Archive</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=6'>6. Upload Scanned Title to Newscaster</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=7'>7. Print Corporate Materials</A><BR>"
			if(obj_flags & EMAGGED)
				dat += "<A href='?src=[REF(src)];switchscreen=8'>8. Access the Forbidden Lore Vault</A><BR>"
			if(src.arcanecheckout)
				print_forbidden_lore(user)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<H3>Inventory</H3><BR>"
			for(var/obj/item/book/b in inventory)
				dat += "[b.name] <A href='?src=[REF(src)];delbook=[REF(b)]'>(Delete)</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(2)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)
				dat += "\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>"
				dat += "<A href='?src=[REF(src)];checkin=[REF(b)]'>(Check In)</A><BR><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book
			dat += "<h3>Check Out a Book</h3><BR>"
			dat += "Book: [src.buffer_book] "
			dat += "<A href='?src=[REF(src)];editbook=1'>\[Edit\]</A><BR>"
			dat += "Recipient: [src.buffer_mob] "
			dat += "<A href='?src=[REF(src)];editmob=1'>\[Edit\]</A><BR>"
			dat += "Checkout Date : [world.time/600]<BR>"
			dat += "Due Date: [(world.time + checkoutperiod)/600]<BR>"
			dat += "(Checkout Period: [checkoutperiod] minutes) (<A href='?src=[REF(src)];increasetime=1'>+</A>/<A href='?src=[REF(src)];decreasetime=1'>-</A>)"
			dat += "<A href='?src=[REF(src)];checkout=1'>(Commit Entry)</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(4)
			dat += "<h3>External Archive</h3>"
			if(!SSdbcore.Connect())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				var/booksperpage = 50
				var/pagecount
				var/datum/db_query/query_library_count_books = SSdbcore.NewQuery("SELECT COUNT(id) FROM [format_table_name("library")] WHERE isnull(deleted)")
				if(!query_library_count_books.Execute())
					qdel(query_library_count_books)
					return
				if(query_library_count_books.NextRow())
					pagecount = CEILING(text2num(query_library_count_books.item[1]) / booksperpage, 1)
				qdel(query_library_count_books)
				var/list/booklist = list()
				var/datum/db_query/query_library_get_books = SSdbcore.NewQuery({"
					SELECT id, author, title, category
					FROM [format_table_name("library")]
					WHERE isnull(deleted)
					LIMIT :skip, :take
				"}, list("skip" = booksperpage * (page - 1), "take" = booksperpage))
				if(!query_library_get_books.Execute())
					qdel(query_library_get_books)
					return
				while(query_library_get_books.NextRow())
					booklist += "<tr><td>[query_library_get_books.item[2]]</td><td>[query_library_get_books.item[3]]</td><td>[query_library_get_books.item[4]]</td><td><A href='?src=[REF(src)];targetid=[query_library_get_books.item[1]]'>\[Order\]</A></td></tr>\n"
				dat += "<A href='?src=[REF(src)];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>"
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td></td></tr>"
				dat += jointext(booklist, "")
				dat += "<tr><td><A href='?src=[REF(src)];page=[max(1,page-1)]'>&lt;&lt;&lt;&lt;</A></td> <td></td> <td></td> <td><span style='text-align:right'><A href='?src=[REF(src)];page=[min(pagecount,page+1)]'>&gt;&gt;&gt;&gt;</A></span></td></tr>"
				dat += "</table>"
				qdel(query_library_get_books)
			dat += "<BR><A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(5)
			dat += "<H3>Upload a New Title</H3>"
			if(!scanner)
				scanner = findscanner(9)
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += "<TT>Data marked for upload...</TT><BR>"
				dat += "<TT>Title: </TT>[scanner.cache.name]<BR>"
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"
				dat += "<TT>Author: </TT><A href='?src=[REF(src)];setauthor=1'>[scanner.cache.author]</A><BR>"
				dat += "<TT>Category: </TT><A href='?src=[REF(src)];setcategory=1'>[upload_category]</A><BR>"
				dat += "<A href='?src=[REF(src)];upload=1'>\[Upload\]</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(6)
			dat += "<h3>Post Title to Newscaster</h3>"
			if(!scanner)
				scanner = findscanner(9)
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += "<TT>Post [scanner.cache.name] to station newscasters?</TT>"
				dat += "<A href='?src=[REF(src)];newspost=1'>\[Post\]</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += "<h3>NTGanda(tm) Universal Printing Module</h3>"
			dat += "What would you like to print?<BR>"
			dat += "<A href='?src=[REF(src)];printbible=1'>\[Bible\]</A><BR>"
			dat += "<A href='?src=[REF(src)];printposter=1'>\[Poster\]</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
		if(8)
			dat += "<h3>Accessing Forbidden Lore Vault v 1.3</h3>"
			dat += "Are you absolutely sure you want to proceed? EldritchRelics Inc. takes no responsibilities for loss of sanity resulting from this action.<p>"
			dat += "<A href='?src=[REF(src)];arccheckout=1'>Yes.</A><BR>"
			dat += "<A href='?src=[REF(src)];switchscreen=0'>No.</A><BR>"

	var/datum/browser/popup = new(user, "library", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/bookmanagement/proc/findscanner(viewrange)
	for(var/obj/machinery/libraryscanner/S in range(viewrange, get_turf(src)))
		return S
	return null

/obj/machinery/computer/bookmanagement/proc/print_forbidden_lore(mob/user)
	new /obj/item/melee/cultblade/dagger(get_turf(src))
	to_chat(user, "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a sinister dagger sitting on the desk. You don't even remember where it came from...</span>")
	user.visible_message("<span class='warning'>[user] stares at the blank screen for a few moments, [user.p_their()] expression frozen in fear. When [user.p_they()] finally awaken[user.p_s()] from it, [user.p_they()] look[user.p_s()] a lot older.</span>", 2)

/obj/machinery/computer/bookmanagement/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = W
		scanner.computer = src
		to_chat(user, "<span class='notice'>[scanner]'s associated machine has been set to [src].</span>")
		audible_message("<span class='hear'>[src] lets out a low, short blip.</span>")
	else
		return ..()

/obj/machinery/computer/bookmanagement/emag_act(mob/user)
	if(density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED

/obj/machinery/computer/bookmanagement/Topic(href, href_list)
	if(!COOLDOWN_FINISHED(src, library_console_topic_cooldown))
		return
	COOLDOWN_START(src, library_console_topic_cooldown, 1 SECONDS)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return
	if(href_list["page"] && screenstate == 4)
		page = text2num(href_list["page"])
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
				screenstate = 6
			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
	if(href_list["arccheckout"])
		if(obj_flags & EMAGGED)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = stripped_input(usr, "Enter the book's title:", max_length = 45)
	if(href_list["editmob"])
		buffer_mob = stripped_input(usr, "Enter the recipient's name:", max_length = MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"]) in checkouts
		if(b && istype(b))
			checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/book/b = locate(href_list["delbook"]) in inventory
		if(b && istype(b))
			inventory.Remove(b)
	if(href_list["setauthor"])
		var/newauthor = stripped_input(usr, "Enter the author's name: ", max_length = 45)
		if(newauthor)
			scanner.cache.author = newauthor
	if(href_list["setcategory"])
		var/newcategory = tgui_input_list(usr, "Choose a category: ",, list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion","Technical"))
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = tgui_alert(usr, "Are you certain you wish to upload this title to the Archive?",, list("Confirm", "Abort"))
				if(choice == "Confirm")
					if (!SSdbcore.Connect())
						tgui_alert(usr,"Connection to Archive has been severed. Aborting.")
					else
						var/msg = "[key_name(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs"
						var/datum/db_query/query_library_upload = SSdbcore.NewQuery({"
							INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
							VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
						"}, list("title" = scanner.cache.name, "author" = scanner.cache.author, "content" = scanner.cache.dat, "category" = upload_category, "ckey" = usr.ckey, "round_id" = GLOB.round_id))
						if(!query_library_upload.Execute())
							qdel(query_library_upload)
							tgui_alert(usr,"Database error encountered uploading to Archive")
							return
						else
							log_game(msg)
							qdel(query_library_upload)
							tgui_alert(usr,"Upload Complete. Uploaded title will be unavailable for printing for a short period")
	if(href_list["newspost"])
		if(!GLOB.news_network)
			tgui_alert(usr,"No news network found on station. Aborting.")
		var/channelexists = 0
		for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
			if(FC.channel_name == "Nanotrasen Book Club")
				channelexists = 1
				break
		if(!channelexists)
			GLOB.news_network.CreateFeedChannel("Nanotrasen Book Club", "Library", null)
		GLOB.news_network.SubmitArticle(scanner.cache.dat, "[scanner.cache.name]", "Nanotrasen Book Club", null)
		tgui_alert(usr,"Upload complete. Your uploaded title is now available on station newscasters.")
	if(href_list["orderbyid"])
		if(printer_cooldown > world.time)
			say("Printer unavailable. Please allow a short time before attempting to print.")
		else
			var/orderid = input("Enter your order:") as num|null
			if(orderid)
				if(isnum(orderid) && ISINTEGER(orderid))
					href_list["targetid"] = num2text(orderid)

	if(href_list["targetid"])
		var/id = href_list["targetid"]
		if (!SSdbcore.Connect())
			tgui_alert(usr,"Connection to Archive has been severed. Aborting.")
		if(printer_cooldown > world.time)
			say("Printer unavailable. Please allow a short time before attempting to print.")
		else
			var/datum/db_query/query_library_print = SSdbcore.NewQuery(
				"SELECT * FROM [format_table_name("library")] WHERE id=:id AND isnull(deleted)",
				list("id" = id)
			)
			if(!query_library_print.Execute())
				qdel(query_library_print)
				say("PRINTER ERROR! Failed to print document (0x0000000F)")
				return
			printer_cooldown = world.time + PRINTER_COOLDOWN
			while(query_library_print.NextRow())
				var/author = query_library_print.item[2]
				var/title = query_library_print.item[3]
				var/content = query_library_print.item[4]
				if(!QDELETED(src))
					var/obj/item/book/B = new(get_turf(src))
					B.name = "Book: [title]"
					B.title = title
					B.author = author
					B.dat = content
					B.icon_state = "book[rand(1,8)]"
					visible_message("<span class='notice'>[src]'s printer hums as it produces a completely bound book. How did it do that?</span>")
				break
			qdel(query_library_print)
	if(href_list["printbible"])
		if(printer_cooldown < world.time)
			var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible(src.loc)
			if(GLOB.bible_icon_state && GLOB.bible_inhand_icon_state)
				B.icon_state = GLOB.bible_icon_state
				B.inhand_icon_state = GLOB.bible_inhand_icon_state
				B.name = GLOB.bible_name
				B.deity_name = GLOB.deity
			printer_cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Printer currently unavailable, please wait a moment.")
	if(href_list["printposter"])
		if(printer_cooldown < world.time)
			new /obj/item/poster/random_official(src.loc)
			printer_cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Printer currently unavailable, please wait a moment.")
	add_fingerprint(usr)
	updateUsrDialog()

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	desc = "It servers the purpose of scanning stuff."
	density = TRUE
	var/obj/item/book/cache // Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=[REF(src)];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=[REF(src)];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=[REF(src)];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	var/datum/browser/popup = new(user, "scanner", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/book/B in contents)
			B.forceMove(drop_location())
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	desc = "Only intended for binding paper products."
	density = TRUE
	var/busy = FALSE

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/paper))
		bind_book(user, O)
	else if(default_unfasten_wrench(user, O))
		return 1
	else
		return ..()

/obj/machinery/bookbinder/proc/bind_book(mob/user, obj/item/paper/P)
	if(machine_stat)
		return
	if(busy)
		to_chat(user, "<span class='warning'>The book binder is busy. Please wait for completion of previous operation.</span>")
		return
	if(!user.transferItemToLoc(P, src))
		return
	user.visible_message("<span class='notice'>[user] loads some paper into [src].</span>", "<span class='notice'>You load some paper into [src].</span>")
	audible_message("<span class='hear'>[src] begins to hum as it warms up its printing drums.</span>")
	busy = TRUE
	sleep(rand(200,400))
	busy = FALSE
	if(P)
		if(!machine_stat)
			visible_message("<span class='notice'>[src] whirs as it prints and binds a new book.</span>")
			var/obj/item/book/B = new(src.loc)
			B.dat = P.info
			B.name = "Print Job #" + "[rand(100, 999)]"
			B.icon_state = "book[rand(1,7)]"
			qdel(P)
		else
			P.forceMove(drop_location())
