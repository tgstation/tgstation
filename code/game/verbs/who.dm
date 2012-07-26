proc/get_all_clients()
	var/list/client/clients = list()

	for (var/mob/M in player_list)

		clients += M.client

	return clients

proc/get_all_admin_clients()
	var/list/client/clients = list()

	for (var/mob/M in admin_list)

		clients += M.client

	return clients


/mob/verb/who()
	set name = "Who"
	set category = "OOC"

	usr << "<b>Current Players:</b>"

	var/list/peeps = list()

	for (var/client/C in client_list)
		if (C.stealth && !usr.client.holder)
			peeps += "\t[C.fakekey]"
		else
			peeps += "\t[C.key][C.stealth ? " <i>(as [C.fakekey])</i>" : ""]"

	peeps = sortList(peeps)

	for (var/p in peeps)
		usr << p

	usr << "<b>Total Players: [length(peeps)]</b>"

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	usr << "<b>Current Admins:</b>"

	for (var/mob/M in admin_list)
		if(M && M.client)
			if(usr.client)
				var/afk = 0
				if( M.client.inactivity > AFK_THRESHOLD ) //When I made this, the AFK_THRESHOLD was 3000ds = 300s = 5m, see setup.dm for the new one.
					afk = 1
				if(isobserver(M))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Observing [afk ? "(AFK)" : ""]"
				else if(istype(M,/mob/new_player))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Has not entered [afk ? "(AFK)" : ""]"
				else if(istype(M,/mob/living))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Playing [afk ? "(AFK)" : ""]"
			else if(!M.client.stealth)
				usr << "\t[M.client]  is a [M.client.holder.rank]"
