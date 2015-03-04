/obj/machinery/computer/library/public
	name = "visitor computer"

/obj/machinery/computer/library/public/attack_hand(var/mob/user as mob)
	if(..()) return
	interact(user)

/obj/machinery/computer/library/public/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat = ""
	switch(screenstate)
		if(0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:40: dat += "<h2>Search Settings</h2><br />"
			dat += {"<h2>Search Settings</h2><br />
				<A href='?src=\ref[src];settitle=1'>Filter by Title: [query.title]</A><br />
				<A href='?src=\ref[src];setcategory=1'>Filter by Category: [query.category]</A><br />
				<A href='?src=\ref[src];setauthor=1'>Filter by Author: [query.author]</A><br />
				<A href='?src=\ref[src];search=1'>\[Start Search\]</A><br />"}
			// END AUTOFIX
		if(1)
			establish_old_db_connection()
			if(!dbcon_old.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><br />"
			else if(num_results == 0)
				dat += "<em>No results found.</em>"
			else
				var/pagelist = get_pagelist()

				dat += pagelist
				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\library\lib_machines.dm:52: dat += "<table>"
				dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Category</td>
						<td>SS<sup>13</sup>BN</td>
					</tr>"}
				// END AUTOFIX
				for(var/datum/cachedbook/CB in get_page(page_num))
					dat += {"<tr>
						<td>[CB.author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>[CB.id]</td>
					</tr>"}

				dat += "</table><br />[pagelist]"
			dat += "<A href='?src=\ref[src];back=1'>\[Go Back\]</A><br />"
	var/datum/browser/B = new /datum/browser/clean(user, "library", "Library Visitor")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/public/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in (list("Any") + library_section_names)
		if(newcategory)
			query.category = sanitize(newcategory)
		else if(newcategory == "Any")
			query.category = null
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			query.author = sanitize(newauthor)
		else
			query.author = null

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 0
		else
			page_num = Clamp(text2num(href_list["page"]), 0, num_pages)

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
		page_num = 0

		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

