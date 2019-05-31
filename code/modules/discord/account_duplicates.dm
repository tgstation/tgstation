// Verb to see if a discord ID is being used by two users at once
/client/proc/show_discord_duplicates()
	set name = "Show Duplicate Discord Links"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.discord_duplicates() 


/datum/admins/proc/discord_duplicates()
	if(!usr.client.holder)
		return
	var/dat = "<html><head><title>Discord Duplicates</title></head>"
	dat += "<body><p><i>Discord IDs with more than one ckey linked are shown below</i></i><table border=1 cellspacing=5><B><tr><th>Discord ID</th><th>CKEYs</th><th>Unlink</th></B>"
	// If anyone reads this, I spent a whole 30 minutes writing just this fucking query. It is the messiest SQL statement I have ever written
	var/datum/DBQuery/get_discord_ids = SSdbcore.NewQuery("SELECT a.* FROM [format_table_name("discord")] a JOIN (SELECT discord_id, ckey, COUNT(*) FROM [format_table_name("discord")] GROUP BY discord_id HAVING count(*) > 1 ) b ON a.discord_id = b.discord_id ORDER BY a.discord_id")
	if(get_discord_ids.Execute())
		while(get_discord_ids.NextRow())
			var/ckey = get_discord_ids.item[1]
			var/id = get_discord_ids.item[2]
			dat += "<tr><td><b>" + id + "</b></td>"
			dat += "<td>" + ckey + "</td>"
			dat += "<td><a href='?_src_=holder;[HrefToken()];force_discord_unlink=[ckey]'>Unlink</td></tr>"
	qdel(get_discord_ids)
	dat += "</table></body></html>"

	usr << browse(dat, "window=duplicates;size=500x480")
