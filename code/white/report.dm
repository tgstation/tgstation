client/verb/suggest(client/C)
	set category = "OOC"
	set name = "Report a Bug, Suggestion"
	var/suggbug = input("Report about something to Joctopus!", "Write a code to be a Host, or write something about your bug", suggbug)
	C.suggestDBInsert(C.ckey, suggbug)

/proc/suggestDBInsert(ckey, sugg)
	var/datum/DBQuery/query_suggestions_insert = SSdbcore.NewQuery("INSERT INTO suggestion (ckey, sugg) VALUES ('[ckey]', '[sugg]')")
	query_suggestions_insert.Execute()

/client/verb/readsuggest(client/C)
	set category = "Debug"
	set name = "Read Bugs, Suggestions"
	var/datum/DBQuery/query_suggestions_select = SSdbcore.NewQuery("SELECT id, ckey, sugg FROM suggestion")
	query_suggestions_select.Execute()
	var/dat
	if(!C.holder)
		C << "Fuck you, leatherman."
		return
	else
		continue
	dat += {"
		<!DOCTYPE html>
		<html>
		<table>
		<tr><td>id</td><td>ckey</td><td>sugg</td></tr>"}
	while(query_suggestions_select.NextRow())
		dat += "<tr><td>[query_suggestions_select.item[1]]</td>"
		dat += "<td>[query_suggestions_select.item[2]]</td>"
		dat += "<td>[query_suggestions_select.item[3]]</td></tr>"
	dat += "</table>"

/client/verb/suggestDBDelete(client/C)
	set category = "Debug"
	set name = "Delete Suggest"
	if(!C.holder)
		C << "Fuck you, leatherman."
		return
	else
		continue
	var/todelete = input("sugg id", "sugg id", todelete)
	var/datum/DBQuery/query_suggestions_delete = SSdbcore.NewQuery("DELETE FROM suggestion WHERE id = [todelete]")
	query_suggestions_delete.Execute()
	C << "succ"