/client/verb/suggest()
	set category = "OOC"
	set name = "Report a Bug, Suggestions"
	var/suggbug = input("Write a code to be a Host, or write something about your bug or your suggestion", "Report", " ")
	suggbug = sanitizeSQL(suggbug)
	suggestDBInsert(usr.ckey, suggbug)

/proc/suggestDBInsert(ckey, sugg)
	var/datum/DBQuery/query_suggestions_insert = SSdbcore.NewQuery("INSERT INTO suggestion (ckey, sugg) VALUES ('[ckey]', '[sugg]')")
	query_suggestions_insert.Execute()

/client/verb/readsuggest()
	set category = "Debug"
	set name = ".readbuggs"
	set hidden = 1
	var/datum/DBQuery/query_suggestions_select = SSdbcore.NewQuery("SELECT id, ckey, sugg FROM suggestion")
	query_suggestions_select.Execute()
	var/dat
	if(!check_rights())
		to_chat(usr,"Fuck you, leatherman.")
		return
	dat += {"
		<!DOCTYPE html>
		<html>
		<table>
		<tr><td>id</td><td>ckey</td><td>sugg</td><td>X</td></tr>"}
	while(query_suggestions_select.NextRow())
		dat += "<tr><td>[query_suggestions_select.item[1]]</td>"
		dat += "<td>[query_suggestions_select.item[2]]</td>"
		dat += "<td>[query_suggestions_select.item[3]]</td>"
		dat += "<td><a href='?deleteDB=[query_suggestions_select.item[1]]'>D</a></td></tr>"
	dat += "</table>"
	usr << browse(sanitize_russian(dat), "window=suggread;size=600x400")


proc/suggestDBDelete(var/id)
	if(!usr.ckey == "Moonmandoom")
		to_chat(usr,"Fuck you, leatherman.")
		return
	var/datum/DBQuery/query_suggestions_delete = SSdbcore.NewQuery("DELETE FROM suggestion WHERE id = [text2num(id)]")
	query_suggestions_delete.Execute()
	usr << "succ"
