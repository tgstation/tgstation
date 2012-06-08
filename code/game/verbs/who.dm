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
			if(usr.client.holder  && (usr.client.holder.level != 0))
				usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""]"
			else if(!M.client.stealth && (M.client.holder.level != -3))
				usr << "\t[pick(nobles)] [M.client] is a [M.client.holder.rank]"

var/list/nobles = list("Baron","Bookkeeper","Captain of the Guard","Chief Medical Dwarf","Count","Dungeon Master","Duke","General","Mayor","Outpost Liaison","Sheriff","Champion")

/client/verb/active_players()
	set category = "OOC"
	set name = "Active Players"
	var/total = 0
	for(var/mob/living/M in world)
		if(!M.client) continue
		if(M.client.inactivity > 10 * 60 * 10) continue
		if(M.stat == 2) continue

		total++

	usr << "<b>Active Players: [total]</b>"