/mob/dead/observer/Login()
	..()
	if(client.holder && client.holder.state != 2)
		client.holder.state = 2
		var/rank = client.holder.rank
		client.clear_admin_verbs()
		client.update_admins(rank)