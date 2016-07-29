/obj/machinery/computer/library
	name = "visitor computer"
	anchored = 1
	density = 1
	var/screenstate = 0
	var/page_num = 0
	var/num_pages = 0
	var/num_results = 0
	var/datum/library_query/query = new()

	icon = 'icons/obj/library.dmi'
	icon_state = "computer"

/obj/machinery/computer/library/proc/interact_check(var/mob/user)
	if(stat & (BROKEN | NOPOWER))
		return TRUE

	if ((get_dist(src, user) > 1))
		if (!issilicon(user)&&!isobserver(user))
			user.unset_machine()
			user << browse(null, "window=library")
			return TRUE

	user.set_machine(src)
	return FALSE

/obj/machinery/computer/library/proc/get_page(var/page_num)
	var/searchquery = ""
	if(query)
		var/where = 0
		if(query.title && query.title != "")
//			to_chat(world, "\red query title ([query.title])")
			searchquery += " WHERE title LIKE '%[query.title]%'"
			where = 1
		if(query.author && query.author != "")
//			to_chat(world, "\red query author ([query.author])")
			searchquery += " [!where ? "WHERE" : "AND"] author LIKE '%[query.author]%'"
			where = 1
		if(query.category && query.category != "")
//			to_chat(world, "\red query category ([query.category])")
			searchquery += " [!where ? "WHERE" : "AND"] category LIKE '%[query.category]%'"
			if(query.category == "Fiction")
				searchquery += " AND category NOT LIKE '%Non-Fiction%'"
			where = 1
	var/sql = "SELECT id, author, title, category, ckey FROM library [searchquery] LIMIT [page_num * LIBRARY_BOOKS_PER_PAGE], [LIBRARY_BOOKS_PER_PAGE]"

	//if(query)
		//sql += " [query.toSQL()]"
	// Pagination
//	to_chat(world, sql)
	var/DBQuery/_query = dbcon_old.NewQuery(sql)
	_query.Execute()
	if(_query.ErrorMsg())
		world.log << _query.ErrorMsg()

	var/list/results = list()
	while(_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =_query.item[1],
			"author"  =_query.item[2],
			"title"   =_query.item[3],
			"category"=_query.item[4],
			"ckey"    =_query.item[5]
		))
		results += CB
	return results

/obj/machinery/computer/library/proc/get_num_results()
	var/sql = "SELECT COUNT(*) FROM library"
	//if(query)
		//sql += query.toSQL()

	var/DBQuery/_query = dbcon_old.NewQuery(sql)
	_query.Execute()
	while(_query.NextRow())
		return text2num(_query.item[1])
	return 0

/obj/machinery/computer/library/proc/get_pagelist()
	var/pagelist = "<div class='pages'>"
	var/start = max(0,page_num-3)
	var/end = min(num_pages, page_num+3)
	for(var/i = start,i <= end,i++)
		var/dat = "<a href='?src=\ref[src];page=[i]'>[i]</a>"
		if(i == page_num)
			dat = "<font size=3><b>[dat]</b></font>"
		if(i != end)
			dat += " "
		pagelist += dat
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getBookByID(var/id as text)
	return library_catalog.getBookByID(id)

/obj/machinery/computer/library/cultify()
	new /obj/structure/cult/tome(loc)
	..()
