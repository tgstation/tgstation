/obj/machinery/computer/library
	name = "visitor computer"
	anchored = 1
	density = 1
	var/screenstate = 0
	var/page_num = 0
	var/num_pages = 0
	var/num_results = 0
	var/datum/library_query/query = new()

/obj/machinery/computer/library/proc/get_page(var/page_num)
	var/sql = "SELECT * FROM library"
	if(query)
		sql += query.toSQL()
	// Pagination
	sql += "LIMIT [LIBRARY_BOOKS_PER_PAGE] OFFSET [page_num * LIBRARY_BOOKS_PER_PAGE]"

	var/DBQuery/_query = dbcon_old.NewQuery(sql)
	_query.Execute()

	var/list/results = list()
	while(_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(_query.item)
		results += CB
	return results

/obj/machinery/computer/library/proc/get_num_results()
	var/sql = "SELECT COUNT(*) FROM library"
	if(query)
		sql += query.toSQL()

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
		pagelist += "<a href='?src=\ref[src];page=[i]'>[i+1]</a>"
		if(i != start)
			pagelist += " "
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getBookByID(var/id as text)
	library_catalog.getBookByID(id)

/obj/machinery/computer/library/cultify()
	new /obj/structure/cult/tome(loc)
	..()