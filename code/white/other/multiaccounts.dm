/client/proc/checkAccount()
	set name = "Check multiaccounts"
	set category = "Admin"

	var/target = input(usr, "Напечатайте ckey, который нужно проверить.", "Ckey") as text|null
	if(!target) //Cancel теперь работает
		return
	showAccounts(src, target)

/proc/showAccounts(var/mob/user, var/targetkey)
	var/output = "<center><table border='1'> <caption>Совпадение по computerID</caption><tr> <th width='100px' >ckey</th><th width='100px'>firstseen</th><th width='100px'>lastseen</th><th width='100px'>ip</th><th width='100px'>computerid </th></tr>"
	var/datum/DBQuery/query_multiaccount_check = SSdbcore.NewQuery("SELECT ckey,firstseen,lastseen,ip,computerid FROM [format_table_name("player")] WHERE computerid IN (SELECT DISTINCT computerid FROM [format_table_name("player")] WHERE ckey LIKE '[targetkey]')")
	query_multiaccount_check.Execute()
	while(query_multiaccount_check.NextRow())
		output+="<tr><td>[query_multiaccount_check.item[1]]</td>"
		output+="<td>[query_multiaccount_check.item[2]]</td>"
		output+="<td>[query_multiaccount_check.item[3]]</td>"
		output+="<td>[query_multiaccount_check.item[4]]</td>"
		output+="<td>[query_multiaccount_check.item[5]]</td></tr>"

	output+="</table>"

	output += "<center><table border='1'> <caption>Совпадение по IP</caption><tr> <th width='100px' >ckey</th><th width='100px'>firstseen</th><th width='100px'>lastseen</th><th width='100px'>ip</th><th width='100px'>computerid </th></tr>"

	query_multiaccount_check = SSdbcore.NewQuery("SELECT ckey,firstseen,lastseen,ip,computerid FROM [format_table_name("player")] WHERE ip IN (SELECT DISTINCT ip FROM [format_table_name("player")] WHERE computerid IN (SELECT DISTINCT computerid FROM [format_table_name("player")] WHERE ckey LIKE '[targetkey]'))")
	query_multiaccount_check.Execute()
	while(query_multiaccount_check.NextRow())
		output+="<tr><td>[query_multiaccount_check.item[1]]</td>"
		output+="<td>[query_multiaccount_check.item[2]]</td>"
		output+="<td>[query_multiaccount_check.item[3]]</td>"
		output+="<td>[query_multiaccount_check.item[4]]</td>"
		output+="<td>[query_multiaccount_check.item[5]]</td></tr>"

	output+="</table></center>"

	user << browse(output, "window=accaunts;size=600x400")

/client/proc/checkAllAccounts()
	set name = "Check multiaccounts (All)"
	set category = "Admin"

	var/datum/DBQuery/query_multiaccount_check
	var/t1 = ""
	var/output = "<B>Совпадение по IP</B><BR><BR>"

	for (var/client/C in GLOB.clients)
		t1 =""
		query_multiaccount_check = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ip IN (SELECT DISTINCT ip FROM [format_table_name("player")] WHERE computerid IN (SELECT DISTINCT computerid FROM [format_table_name("player")] WHERE ckey LIKE '[C.ckey]'))")
		query_multiaccount_check.Execute()
		var/c = 0

		while(query_multiaccount_check.NextRow())
			c++
			t1 +="[c]: - [query_multiaccount_check.item[1]]<BR>"
		if (c > 1)
			output+= "Ckey: [C.ckey] <A href='?_src_=holder;showmultiacc=[C.ckey]'>Show</A><BR>" + t1

	output+= "<BR><BR><B>Совпадение по computerID</B><BR><BR>"

	for (var/client/C in GLOB.clients)
		t1 =""
		query_multiaccount_check = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE computerid IN (SELECT DISTINCT computerid FROM [format_table_name("player")] WHERE ckey LIKE '[C.ckey]')")
		query_multiaccount_check.Execute()
		var/c = 0
		while(query_multiaccount_check.NextRow())
			c++
			t1 +="[c]: [query_multiaccount_check.item[1]]<BR>"
		if (c > 1)
			output+= "Ckey: [C.ckey] <A href='?_src_=holder;showmultiacc=[C.ckey]'>Show</A><BR>" + t1

	usr << browse(output, "window=accauntsall;size=400x800")
