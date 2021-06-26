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

GLOBAL_LIST_INIT(book_categories, list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion"))
GLOBAL_VAR_INIT(default_book_category, "Any")

///How many books should we load per page?
#define BOOKS_PER_PAGE 20

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
	///The current title we're searching for
	var/title = ""
	///The category we're searching for
	var/category = ""
	///The author we're searching for
	var/author = ""
	///The results of our last query
	var/list/page_content = list()
	///The the total pages last we checked
	var/page_count = 0
	///The page of our current query
	var/search_page = 0
	///Can we connect to the db?
	var/can_connect = FALSE
	///A hash of the last search we did, prevents spam in a different way then the cooldown
	var/last_search_hash = ""
	///Have the search params changed at all since the last search?
	var/params_changed = FALSE
	///Prevents spamming the search button
	COOLDOWN_DECLARE(search_run_cooldown)

/obj/machinery/computer/libraryconsole/Initialize(mapload)
	. = ..()
	category = GLOB.default_book_category
	INVOKE_ASYNC(src, .proc/update_db_info)

/obj/machinery/computer/libraryconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryVisitor")
		ui.open()

/obj/machinery/computer/libraryconsole/ui_data(mob/user)
	var/list/data = list()
	data["categories"] = GLOB.book_categories
	data["category"] = category || GLOB.default_book_category
	data["author"] = author
	data["title"] = title
	data["page_count"] = page_count + 1 //Increase these by one so it looks like we're not indexing at 0
	data["our_page"] = search_page + 1
	data["pages"] = page_content
	data["can_connect"] = can_connect
	data["params_changed"] = params_changed
	return data

/obj/machinery/computer/libraryconsole/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set-title")
			var/newtitle = params["title"]
			newtitle = sanitize(newtitle)
			if(newtitle != title)
				params_changed = TRUE
			title = newtitle
			return TRUE
		if("set-category")
			var/newcategory = params["category"]
			if(!(newcategory in GLOB.book_categories)) //Nice try
				newcategory = GLOB.default_book_category
			newcategory = sanitize(newcategory)
			if(newcategory != category)
				params_changed = TRUE
			category = newcategory
			return TRUE
		if("set-author")
			var/newauthor = params["author"]
			newauthor = sanitize(newauthor)
			if(newauthor != author)
				params_changed = TRUE
			author = newauthor
			return TRUE
		if("search")
			INVOKE_ASYNC(src, .proc/update_db_info)
			return TRUE
		if("switch-page")
			var/parsed = text2num(params["page"])
			search_page = parsed || params["page"]
			//We expect the search page to be one greater then it should be, because we're lying about indexing at 1
			search_page = min(max(0, search_page - 1), page_count)
			INVOKE_ASYNC(src, .proc/update_db_info)
			return TRUE
		if("clear-data") //The cap just walked in on your browsing, quick! delete it!
			title = initial(title)
			author = initial(author)
			category = GLOB.default_book_category
			INVOKE_ASYNC(src, .proc/update_db_info)
			return TRUE

/obj/machinery/computer/libraryconsole/proc/update_db_info()
	var/hashed_search = hash_search_info()
	if(last_search_hash == hashed_search) //You're not allowed to make the same search twice, waste of resources
		return
	if(!COOLDOWN_FINISHED(src, search_run_cooldown))
		say("Database cables refreshing. Please wait a moment.")
		return
	COOLDOWN_START(src, search_run_cooldown, 1 SECONDS)
	if (!SSdbcore.Connect())
		can_connect = FALSE
		page_count = 0
		page_content = list()
		return
	can_connect = TRUE
	params_changed = FALSE
	last_search_hash = hashed_search

	update_page_count()
	update_page_contents()
	SStgui.update_uis(src) //We need to do this because we sleep here, so we've gotta update manually

/obj/machinery/computer/libraryconsole/proc/hash_search_info()
	return "[title]-[author]-[category]-[search_page]-[page_count]"

/obj/machinery/computer/libraryconsole/proc/update_page_contents()
	page_content.Cut()
	search_page = clamp(search_page, 0, page_count)
	var/datum/db_query/query_library_list_books = SSdbcore.NewQuery({"
		SELECT author, title, category, id
		FROM [format_table_name("library")]
		WHERE isnull(deleted)
			AND author LIKE CONCAT('%',:author,'%')
			AND title LIKE CONCAT('%',:title,'%')
			AND (:category = 'Any' OR category = :category)
		ORDER BY id DESC
		LIMIT :skip, :take
	"}, list("author" = author, "title" = title, "category" = category, "skip" = BOOKS_PER_PAGE * search_page, "take" = BOOKS_PER_PAGE))
	if(!query_library_list_books.Execute())
		qdel(query_library_list_books)
		return
	while(query_library_list_books.NextRow())
		page_content += list(list(
			"author" = query_library_list_books.item[1],
			"title" = query_library_list_books.item[2],
			"category" = query_library_list_books.item[3],
			"id" = query_library_list_books.item[4]
		))
	qdel(query_library_list_books)

/obj/machinery/computer/libraryconsole/proc/update_page_count()
	page_count = 0
	var/bookcount = 0
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

	if(bookcount > BOOKS_PER_PAGE)
		page_count = round(bookcount / BOOKS_PER_PAGE) //This is just floor()

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/datum/book_info/book_data
	var/loanedto
	var/checkout
	var/duedate

#define PRINTER_COOLDOWN 6 SECONDS
#define BOOK_CLUB "Nanotrasen Book Club"
//The different states the computer can be in, only send the info we need yeah?
#define LIBRARY_INVENTORY 0
#define LIBRARY_CHECKOUT_LISTING 1
#define LIBRARY_CHECKOUT 2
#define LIBRARY_ARCHIVE 3
#define LIBRARY_UPLOAD 4
#define LIBRARY_PRINT 5
#define LIBRARY_TOP_SNEAKY 6
#define MIN_LIBRARY LIBRARY_INVENTORY
#define MAX_LIBRARY LIBRARY_TOP_SNEAKY

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
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
	///Can spawn secret lore item
	var/can_spawn_lore = TRUE
	///The screen we're currently on, sent to the ui
	var/screen_state = LIBRARY_INVENTORY
	///Should we show the buttons required for changing screens?
	var/show_dropdown = TRUE
	///The set checkout time, in minutes
	var/checkoutperiod = 5
	///The name of the book being checked out
	var/buffer_book
	///The name of the mob currently checking out the book
	var/buffer_mob
	///Category to upload to
	var/upload_category
	///List of checked out books, /datum/borrowbook
	var/list/checkouts = list()
	///List of book info datums to display to the user as our "inventory"
	var/list/inventory = list()
	///Book scanner that will be used when uploading books to the Archive
	var/datum/weakref/scanner
	///Our cooldown on using the printer
	COOLDOWN_DECLARE(printer_cooldown)
	///Our upload cooldown, prevents spamming the db
	COOLDOWN_DECLARE(upload_cooldown)

/obj/machinery/computer/libraryconsole/bookmanagement/Initialize(mapload)
	. = ..()
	upload_category = GLOB.default_book_category

/obj/machinery/computer/libraryconsole/bookmanagement/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryConsole")
		ui.open()

/obj/machinery/computer/libraryconsole/bookmanagement/ui_data(mob/user)
	var/list/data = list()
	data["screen_state"] = screen_state
	data["show_dropdown"] = show_dropdown
	data["display_lore"] = (obj_flags & EMAGGED && can_spawn_lore)
	data["world_time"] = world.time

	if(screen_state == LIBRARY_INVENTORY)
		var/id = 0
		data["inventory"] = list()
		for(var/datum/book_info/info in inventory)
			data["inventory"] += list(list(
				"id" = id,
				"title" = info.title,
				"author" = info.author,
			))
			id += 1

	if(screen_state == LIBRARY_CHECKOUT_LISTING)
		var/id = 0
		for(var/datum/borrowbook/loan as anything in checkouts)
			var/checkedout = (world.time - loan.checkout) / (1 MINUTES)
			checkedout = round(checkedout)
			var/timedue = (loan.duedate - world.time) / (1 MINUTES)
			timedue = round(timedue)
			data["checkouts"] += list(list(
				"id" = id,
				"borrower" = loan.loanedto,
				"checked_out_at" = checkedout,
				"overdue" = (timedue <= 0),
				"due_in" = timedue,
				"due_time" = loan.duedate,
				"title" = loan.book_data.title,
				"author" = loan.book_data.author
			))
			id += 1

	if(screen_state == LIBRARY_CHECKOUT)
		data["checkoutee"] = buffer_mob
		data["checking_out"] = buffer_book
		data["checkout_for"] = checkoutperiod

	//Copypasta from the visitor console
	if(screen_state == LIBRARY_ARCHIVE)
		data["categories"] = GLOB.book_categories
		data["category"] = category || GLOB.default_book_category
		data["author"] = author
		data["title"] = title
		data["page_count"] = page_count + 1 //Increase these by one so it looks like we're not indexing at 0
		data["our_page"] = search_page + 1
		data["pages"] = page_content
		data["can_connect"] = can_connect
		data["params_changed"] = params_changed

	if(screen_state == LIBRARY_UPLOAD)
		var/obj/machinery/libraryscanner/scan = get_scanner()
		data["has_scanner"] = !!(scan)
		data["has_cache"] = !!(scan?.cache)
		if(scan?.cache)
			data["cache_info"] = list(
				"title" = scan.cache.title,
				"author" = scan.cache.author
			)

	return data

/*
/obj/machinery/computer/libraryconsole/bookmanagement/ui_interact(mob/user)
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
				var/timetaken = world.time - b.checkout
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
				dat += "<TT>Title: </TT>[scanner.cache.title]<BR>"
				if(!scanner.cache.author)
					scanner.cache.set_author("Anonymous")
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
				dat += "<TT>Post [scanner.cache.title] to station newscasters?</TT>"
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

*/

/obj/machinery/computer/libraryconsole/bookmanagement/proc/get_scanner(viewrange)
	if(scanner)
		var/obj/machinery/libraryscanner/potential_scanner = scanner.resolve()
		if(potential_scanner)
			return potential_scanner
		scanner = null

	for(var/obj/machinery/libraryscanner/foundya in range(viewrange, get_turf(src)))
		scanner = WEAKREF(foundya)
		return foundya

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_forbidden_lore(mob/user)
	can_spawn_lore = FALSE
	new /obj/item/melee/cultblade/dagger(get_turf(src))
	to_chat(user, span_warning("Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a sinister dagger sitting on the desk. You don't even remember where it came from..."))
	user.visible_message(span_warning("[user] stares at the blank screen for a few moments, [user.p_their()] expression frozen in fear. When [user.p_they()] finally awaken[user.p_s()] from it, [user.p_they()] look[user.p_s()] a lot older."), 2)

/obj/machinery/computer/libraryconsole/bookmanagement/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/barcodescanner))
		return ..()
	var/obj/item/barcodescanner/scanner = W
	scanner.computer = src
	to_chat(user, span_notice("[scanner]'s associated machine has been set to [src]."))
	audible_message(span_hear("[src] lets out a low, short blip."))

/obj/machinery/computer/libraryconsole/bookmanagement/emag_act(mob/user)
	if(density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED

/obj/machinery/computer/libraryconsole/bookmanagement/ui_act(action, params)
	//The parent call takes care of stuff like searching, don't forget about that yeah?
	. = ..()
	if(.)
		return
	switch(action)
		if("set_screen")
			var/window = params["screen_index"]
			screen_state = clamp(window, MIN_LIBRARY, MAX_LIBRARY)
			return TRUE
		if("lore_spawn")
			if(obj_flags & EMAGGED && can_spawn_lore)
				print_forbidden_lore()
			screen_state = MIN_LIBRARY
			return TRUE
		if("set-checkout-period")
			var/checkout_time = params["new_time"]
			checkout_time = text2num(checkout_time) || checkout_time
			checkoutperiod = max(checkout_time, 1)
			return TRUE
		if("set-book-name")
			buffer_book = copytext(html_encode(params["new_name"]), 1, 45)
			return TRUE
		if("set-mob-name")
			buffer_mob = copytext(html_encode(params["new_name"]), 1, MAX_NAME_LEN)
			return TRUE
		if("checkout")
			var/datum/borrowbook/loan = new /datum/borrowbook
			loan.loanedto = sanitize(buffer_book)
			loan.loanedto = sanitize(buffer_mob)
			loan.checkout = world.time
			loan.duedate = world.time + (checkoutperiod * 600)
			checkouts += loan
			return TRUE
		if("checkin")
			var/id = params["id"]
			var/datum/borrowbook/loan = checkouts[id]
			checkouts -= loan
			return TRUE
		if("delbook")
			var/id = params["id"]
			var/datum/book_info/data = inventory[id]
			inventory -= data
			return TRUE
		if("set-author-name")
			var/newauthor = copytext(html_encode(params["new_name"]), 1, MAX_NAME_LEN)
			var/obj/machinery/libraryscanner/scan = get_scanner()
			if(scan?.cache && newauthor)
				scan.cache.set_author(newauthor)
			return TRUE
		if("set-upload-category")
			var/newcategory = params["category"]
			if(!(newcategory in GLOB.book_categories)) //Nice try
				newcategory = GLOB.default_book_category
			upload_category = sanitize(newcategory)
			return TRUE
		if("upload")
			upload_from_scanner()
			return TRUE
		if("newspost")
			if(!GLOB.news_network)
				say("No news network found on station. Aborting.")
			var/channelexists = FALSE
			for(var/datum/newscaster/feed_channel/feed in GLOB.news_network.network_channels)
				if(feed.channel_name == BOOK_CLUB)
					channelexists = TRUE
					break
			if(!channelexists)
				GLOB.news_network.CreateFeedChannel(BOOK_CLUB, "Library", null)

			var/obj/machinery/libraryscanner/scan = get_scanner()
			if(!scan)
				say("No nearby scanner detected. Aborting.")
				return
			GLOB.news_network.SubmitArticle(scan.cache.content, "[scan.cache.title]", BOOK_CLUB, null)
			say("Upload complete. Your uploaded title is now available on station newscasters.")
			return TRUE
		if("print-book")
			if(!COOLDOWN_FINISHED(src, printer_cooldown))
				say("Printer currently unavailable, please wait a moment.")
				return
			COOLDOWN_START(src, printer_cooldown, PRINTER_COOLDOWN)
			var/id = params["book_id"]
			print_book(id)
			return TRUE
		if("print-bible")
			if(!COOLDOWN_FINISHED(src, printer_cooldown))
				say("Printer currently unavailable, please wait a moment.")
				return
			COOLDOWN_START(src, printer_cooldown, PRINTER_COOLDOWN)
			var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible(loc)
			if(GLOB.bible_icon_state && GLOB.bible_inhand_icon_state)
				B.icon_state = GLOB.bible_icon_state
				B.inhand_icon_state = GLOB.bible_inhand_icon_state
				B.name = GLOB.bible_name
				B.deity_name = GLOB.deity
			return TRUE
		if("print-poster")
			if(!COOLDOWN_FINISHED(src, printer_cooldown))
				say("Printer currently unavailable, please wait a moment.")
				return
			COOLDOWN_START(src, printer_cooldown, PRINTER_COOLDOWN)
			new /obj/item/poster/random_official(loc)
			return TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/proc/upload_from_scanner()
	var/obj/machinery/libraryscanner/scan = get_scanner()
	if(!scan)
		say("No nearby scanner detected.")
		return
	if(!scan.cache)
		say("No cached book found. Aborting upload.")
		return
	if(!COOLDOWN_FINISHED(src, upload_cooldown))
		say("Database cables refreshing. Please wait a moment.")
		return
	COOLDOWN_START(src, upload_cooldown, 1 SECONDS)
	if (!SSdbcore.Connect())
		say("Connection to Archive has been severed. Aborting.")
		return
	var/datum/book_info/book = scan.cache
	var/content = book.content
	var/msg = "[key_name(usr)] has uploaded the book titled [book.title], [length(content)] signs"
	var/datum/db_query/query_library_upload = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
		VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
	"}, list("title" = book.title, "author" = book.author, "content" = content, "category" = upload_category, "ckey" = usr.ckey, "round_id" = GLOB.round_id))
	if(!query_library_upload.Execute())
		qdel(query_library_upload)
		say("Database error encountered uploading to Archive")
		return
	log_game(msg)
	qdel(query_library_upload)
	say("Upload Complete. Uploaded title will be available for printing in a moment")

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_book(id)
	if (!SSdbcore.Connect())
		say("Connection to Archive has been severed. Aborting.")
		can_connect = FALSE
		return
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
			var/obj/item/book/printed_book = new(get_turf(src))
			printed_book.name = "Book: [title]"
			printed_book.book_data = new()
			var/datum/book_info/fill = printed_book.book_data
			fill.set_title(title, legacy = TRUE)
			fill.set_title(author, legacy = TRUE)
			fill.set_author(content, legacy = TRUE)
			printed_book.icon_state = "book[rand(1,8)]"
			visible_message(span_notice("[src]'s printer hums as it produces a completely bound book. How did it do that?"))
		break
	qdel(query_library_print)

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	desc = "It servers the purpose of scanning stuff."
	density = TRUE
	///Our scanned in book
	var/datum/book_info/cache

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
	else
		return ..()

/obj/machinery/libraryscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryScanner")
		ui.open()

/obj/machinery/libraryscanner/ui_data()
	var/list/data = list()
	var/list/cached_info = list()
	var/obj/item/book/scannable = locate(/obj/item/book) in contents
	data["has_book"] = !!scannable
	data["has_cache"] = !!cache
	if(cache)
		cached_info["title"] = cache.title
		cached_info["author"] = cache.author
	data["book"] = cached_info

	return data

/obj/machinery/libraryscanner/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("scan")
			var/obj/item/book/to_store = locate(/obj/item/book) in contents
			if(cache?.compare(to_store.book_data))
				say(span_robot("This book is already in my internal cache"))
				return
			cache = to_store.book_data.return_copy()
			return TRUE
		if("clear")
			cache = null
			return TRUE
		if("eject")
			var/obj/item/book/yeet = locate(/obj/item/book) in contents
			yeet.forceMove(drop_location())
			return TRUE

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
		to_chat(user, span_warning("The book binder is busy. Please wait for completion of previous operation."))
		return
	if(!user.transferItemToLoc(P, src))
		return
	user.visible_message(span_notice("[user] loads some paper into [src]."), span_notice("You load some paper into [src]."))
	audible_message(span_hear("[src] begins to hum as it warms up its printing drums."))
	busy = TRUE
	sleep(rand(200,400))
	busy = FALSE
	if(P)
		if(!machine_stat)
			visible_message(span_notice("[src] whirs as it prints and binds a new book."))
			var/obj/item/book/bound_book = new(src.loc)
			bound_book.book_data.content = P.info
			bound_book.name = "Print Job #" + "[rand(100, 999)]"
			bound_book.icon_state = "book[rand(1,7)]"
			qdel(P)
		else
			P.forceMove(drop_location())
