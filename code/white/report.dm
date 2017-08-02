/client/verb/suggest()
	set category = "OOC"
	set name = "Report a Bug, Suggestion"
	var/suggbug = input("Report about something to Joctopus!", "Write a code to be a Host, or write something about your bug", "Error!")
	suggbug = sanitizeSQL(suggbug)
	suggestDBInsert(usr.ckey, suggbug)

/proc/suggestDBInsert(ckey, sugg)
	var/datum/DBQuery/query_suggestions_insert = SSdbcore.NewQuery("INSERT INTO suggestion (ckey, sugg) VALUES ('[ckey]', '[sugg]')")
	query_suggestions_insert.Execute()

/client/verb/readsuggest()
	set category = "Debug"
	set name = "Read Bugs, Suggestions"
	var/datum/DBQuery/query_suggestions_select = SSdbcore.NewQuery("SELECT id, ckey, sugg FROM suggestion")
	query_suggestions_select.Execute()
	var/dat
	if(!check_rights())
		usr << "Fuck you, leatherman."
		return
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
	usr << browse(sanitize_russian(dat), "window=suggread;size=600x400")

/client/verb/suggestDBDelete()
	set category = "Debug"
	set name = "Delete Suggest"
	if(!check_rights())
		usr << "Fuck you, leatherman."
		return
	var/todelete = input("sugg id", "sugg id", "Error!")
	var/datum/DBQuery/query_suggestions_delete = SSdbcore.NewQuery("DELETE FROM suggestion WHERE id = [todelete]")
	query_suggestions_delete.Execute()
	usr << "succ"