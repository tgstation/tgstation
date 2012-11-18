/client/proc/edit_admin_permissions()
	set category = "Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"

	if(!holder)
		return
	holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!usr.client)
		return

	if(!usr.client.holder || !(usr.client.holder.sql_permissions & PERMISSIONS))
		usr << "\red You do not have permission to do this!"
		return

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT ckey, rank, level, flags FROM erro_admin ORDER BY rank, ckey")
	select_query.Execute()

	var/output = "<div align='center'><h1>Current admins</h1>"

	output += "<a href=\"byond://?src=\ref[src];editadminpermissions=add;editadminckey=none\">Add new admin</a>"

	output += "<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0'>"
	output += "<tr>"
	output += "<th width='125'><b>CKEY</b></th>"
	output += "<th width='125'><b>RANK</b></th>"
	output += "<th width='25'><b>LEVEL</b></th>"
	output += "<th width='75'><b>PERMISSIONS</b></th>"
	output += "<th width='150'><b>OPTIONS</b></th>"
	output += "</tr>"

	var/color1 = "#f4f4f4"
	var/color2 = "#e7e7e7"
	var/i = 1	//Used to determine the color of each row

	while(select_query.NextRow())
		i = !i
		var/adm_ckey = select_query.item[1]
		var/adm_rank = select_query.item[2]
		var/adm_level = select_query.item[3]
		var/adm_flags = text2num(select_query.item[4])
		output += "<tr bgcolor='[(i % 2) ? color1 : color2]'>"
		output += "<td align='center'><b>[adm_ckey]</b></td>"
		output += "<td align='center'><b>[adm_rank]</b></td>"
		output += "<td align='center'>[adm_level]</td>"
		var/list/permissionlist = bitfield2list(adm_flags, permissionwords_sql)
		output += "<td align='center'>"
		for(var/word in permissionlist)
			output += "[word]<BR>"
		output += "</td>"
		output += "<td align='center'><font size='2'>"

		//Options
		output += "<a href=\"byond://?src=\ref[src];editadminpermissions=permissions;editadminckey=[adm_ckey]\">PERMISSIONS</a><br>"
		output += "<a href=\"byond://?src=\ref[src];editadminpermissions=rank;editadminckey=[adm_ckey]\">RANK</a><br>"
		output += "<a href=\"byond://?src=\ref[src];editadminpermissions=remove;editadminckey=[adm_ckey]\">REMOVE</a>"

		output += "</font></td>"
		output += "</tr>"

	output += "</table></div>"

	usr << browse(output,"window=editadminpermissions;size=600x500")


/datum/admins/proc/log_admin_rank_modification(var/adm_ckey, var/new_rank)
	if(!usr.client)
		return

	if(!usr.client.holder || !(usr.client.holder.sql_permissions & PERMISSIONS))
		usr << "\red You do not have permission to do this!"
		return

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT id FROM erro_admin WHERE ckey = '[adm_ckey]'")
	select_query.Execute()

	var/new_admin = 1
	var/admin_id
	while(select_query.NextRow())
		new_admin = 0
		admin_id = text2num(select_query.item[1])

	if(new_admin)
		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `erro_admin` (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, '[adm_ckey]', '[new_rank]', -1, 0)")
		insert_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `test`.`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Added new admin [adm_ckey] to rank [new_rank]');")
		log_query.Execute()
		usr << "\blue New admin added."
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET rank = '[new_rank]' WHERE id = [admin_id]")
			insert_query.Execute()
			var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `test`.`erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Edited the rank of [adm_ckey] to [new_rank]');")
			log_query.Execute()
			usr << "\blue Admin rank changed."
