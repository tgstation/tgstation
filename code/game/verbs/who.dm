proc/get_all_clients()
	var/list/client/clients = list()

	for (var/mob/M in player_list)

		clients += M.client

	return clients

proc/get_all_admin_clients()
	var/list/client/clients = list()

	for (var/client/C in admin_list)

		clients += C

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

	for (var/client/C in admin_list)
		if(C && C.holder)
			if(usr.client && usr.client.holder)
				var/afk = 0
				if(C.inactivity > AFK_THRESHOLD ) //When I made this, the AFK_THRESHOLD was 3000ds = 300s = 5m, see setup.dm for the new one.
					afk = 1
				if(isobserver(C.mob))
					usr << "[C] is a [C.holder.rank][C.stealth ? " <i>(as [C.fakekey])</i>" : ""] - Observing [afk ? "(AFK)" : ""]"
				else if(istype(C.mob,/mob/new_player))
					usr << "[C] is a [C.holder.rank][C.stealth ? " <i>(as [C.fakekey])</i>" : ""] - Has not entered [afk ? "(AFK)" : ""]"
				else if(istype(C.mob,/mob/living))
					usr << "[C] is a [C.holder.rank][C.stealth ? " <i>(as [C.fakekey])</i>" : ""] - Playing [afk ? "(AFK)" : ""]"
			else if(!C.stealth)
				usr << "\t[C]  is a [C.holder.rank]"
