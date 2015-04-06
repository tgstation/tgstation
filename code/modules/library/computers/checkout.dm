/*
 * Library Computer
 */
/obj/machinery/computer/library/checkout
	name = "Check-In/Out Computer"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var/arcanecheckout = 0
	//var/screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
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

/obj/machinery/computer/library/checkout/attack_hand(var/mob/user as mob)
	if(..()) return
	interact(user)

/obj/machinery/computer/library/checkout/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat=""
	switch(screenstate)
		if(0)
			// Main Menu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:141: dat += "<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>"
			dat += {"<ol>
				<li><A href='?src=\ref[src];switchscreen=1'>View General Inventory</A></li>
				<li><A href='?src=\ref[src];switchscreen=2'>View Checked Out Inventory</A></li>
				<li><A href='?src=\ref[src];switchscreen=3'>Check out a Book</A></li>
				<li><A href='?src=\ref[src];switchscreen=4'>Connect to External Archive</A></li>
				<li><A href='?src=\ref[src];switchscreen=5'>Upload New Title to Archive</A></li>
				<li><A href='?src=\ref[src];switchscreen=6'>Print a Bible</A></li>
				<li><A href='?src=\ref[src];switchscreen=7'>Print a Manual</A></li>"}
			// END AUTOFIX
			if(src.emagged)
				dat += "<li><A href='?src=\ref[src];switchscreen=8'>Access the Forbidden Lore Vault</A></li>"
			dat += "</ol>"

			if(src.arcanecheckout)
				new /obj/item/weapon/tome(src.loc)
				user << "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a dusty old tome sitting on the desk. You don't really remember printing it.</span>"
				user.visible_message("[user] stares at the blank screen for a few moments, his expression frozen in fear. When he finally awakens from it, he looks a lot older.", 2)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<h3>Inventory</h3>"
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
			if(!dbcon_old.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				num_results = src.get_num_results()
				num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:196: dat += "<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>"
				dat += {"<ul>
					<li><A href='?src=\ref[src];id=-1'>(Order book by SS<sup>13</sup>BN)</A></li>
				</ul>"}
				var/pagelist = get_pagelist()

				dat += pagelist

				dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Category</td>
						<td>Controls</td>
					</tr>"}

				for(var/datum/cachedbook/CB in get_page(page_num))
					var/author = CB.author
					var/controls =  "<A href='?src=\ref[src];id=[CB.id]'>\[Order\]</A>"
					if(user.check_rights(R_ADMIN))
						controls +=  " <A style='color:red' href='?src=\ref[src];del=[CB.id]'>\[Delete\]</A>"
						author += " (<A style='color:red' href='?src=\ref[src];delbyckey=[ckey(CB.ckey)]'>[ckey(CB.ckey)])</A>)"
					dat += {"<tr>
						<td>[author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>
							[controls]
						</td>
					</tr>"}

				dat += "</table><br />[pagelist]"

			dat += "<br /><A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(5)
			dat += "<h3>Upload a New Title</h3>"
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

	var/datum/browser/B = new /datum/browser/clean(user, "library", "Book Inventory Management")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/checkout/emag(mob/user)
	if(!emagged)
		src.emagged = 1
		user << "\blue You override the library computer's printing restrictions."
		return 1
	return

/obj/machinery/computer/library/checkout/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		user << "[scanner]'s associated machine has been set to [src]."
		for (var/mob/V in hearers(src))
			V.show_message("[src] lets out a low, short blip.", 2)
	else
		return ..()

/obj/machinery/computer/library/checkout/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 0
		else
			page_num = Clamp(text2num(href_list["page"]), 0, num_pages)
	if(href_list["del"])
		if(!usr.check_rights(R_ADMIN))
			usr << "You aren't an admin, piss off."
			return
		var/datum/cachedbook/target = getBookByID(href_list["del"]) // Sanitized in getBookByID
		var/ans = alert(usr, "Are you sure you wish to delete \"[target.title]\", by [target.author]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/DBQuery/query = dbcon_old.NewQuery("DELETE FROM library WHERE id=[target.id]")
			var/response = query.Execute()
			if(!response)
				usr << query.ErrorMsg()
				return
			log_admin("LIBRARY: [usr.name]/[usr.key] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			message_admins("[key_name_admin(usr)] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			src.updateUsrDialog()
			return

	if(href_list["delbyckey"])
		if(!usr.check_rights(R_ADMIN))
			usr << "You aren't an admin, piss off."
			return
		var/tckey = ckey(href_list["delbyckey"])
		var/ans = alert(usr,"Are you sure you wish to delete all books by [tckey]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/DBQuery/query = dbcon_old.NewQuery("DELETE FROM library WHERE ckey='[sanitizeSQL(tckey)]'")
			var/response = query.Execute()
			if(!response)
				usr << query.ErrorMsg()
				return
			var/affected=query.RowsAffected()
			if(affected==0)
				usr << "<span class='danger'>Unable to find any matching rows.</span>"
				return
			log_admin("LIBRARY: [usr.name]/[usr.key] has deleted [affected] books written by [tckey]!")
			message_admins("[key_name_admin(usr)] has deleted [affected] books written by [tckey]!")
			src.updateUsrDialog()
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
						var/DBQuery/query = dbcon_old.NewQuery("INSERT INTO library (author, title, content, category, ckey) VALUES ('[sqlauthor]', '[sqltitle]', '[sqlcontent]', '[sqlcategory]', '[ckey(usr.key)]')")
						var/response = query.Execute()
						if(!response)
							usr << query.ErrorMsg()
						else
							world.log << response
							log_admin("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")
							message_admins("[key_name_admin(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")

	if(href_list["id"])
		if(href_list["id"]=="-1")
			href_list["id"] = input("Enter your order:") as num|null
			if(!href_list["id"])
				return

		if(!dbcon_old.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/datum/cachedbook/newbook = getBookByID(href_list["id"]) // Sanitized in getBookByID
		if((newbook.forbidden == 2 && !emagged) || newbook.forbidden == 1)
			alert("This book is forbidden and cannot be printed.")
			return

		if(bibledelay)
			for (var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			make_external_book(newbook)


	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Library Scanner
 */

/obj/machinery/computer/library/checkout/proc/make_external_book(var/datum/cachedbook/newbook)
	if(!newbook || !newbook.id)
		return
	var/obj/item/weapon/book/B = new newbook.path(src.loc)

	if (!newbook.programmatic)
		var/list/_http = world.Export("http://vg13.undo.it/index.php/book?id=[newbook.id]")
		if(!_http || !_http["CONTENT"])
			return
		var/http = file2text(_http["CONTENT"])
		if(!http)
			return
		B.name = "Book: [newbook.title]"
		B.title = newbook.title
		B.author = newbook.author
		B.dat = http
		B.icon_state = "book[rand(1,9)]"
	src.visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")

