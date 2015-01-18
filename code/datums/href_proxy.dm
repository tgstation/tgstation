var/global/list/saved_href_proxies = list()   //they will stay forever so links in the chat will not runtime after someone turn stealthmode off

/datum/href_proxy
	var/name
	var/client/saved_client

/datum/href_proxy/New(client, new_name)
	saved_client = client
	if(new_name)
		name = new_name
	else
		name = "Administrator"
	saved_href_proxies.Add(src)

/datum/href_proxy/Topic(href, href_list)
	if(!saved_client)
		var/client/C = directory[href_list["priv_msg"]]
		C.adminhelp()
	else
		saved_client.cmd_admin_pm(href_list["priv_msg"])