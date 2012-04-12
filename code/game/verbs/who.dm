/mob/verb/who()
	set name = "Who"
	set category = "OOC"

	usr << "<b>Current Players:</b>"

	var/list/peeps = list()

	for (var/mob/M in world)
		if (!M.client)
			continue

		if (M.client.stealth && !usr.client.holder)
			peeps += "\t[M.client.fakekey]"
		else
			peeps += "\t[M.client][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""]"

	peeps = sortList(peeps)

	for (var/p in peeps)
		usr << p

	usr << "<b>Total Players: [length(peeps)]</b>"

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	usr << "<b>Current Admins:</b>"

	for (var/mob/M in world)
		if(M && M.client && M.client.holder)
			if(usr.client.holder)
				usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""]"
			else if(!M.client.stealth)
				usr << "\t[M.client]"
