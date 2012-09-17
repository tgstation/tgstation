/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("sandbox")
				CanBuild()
			if("revolution")
				if((mind in ticker.mode.revolutionaries) || (src.mind in ticker.mode:head_revolutionaries))
					ticker.mode.update_rev_icons_added(src.mind)
			if("cult")
				if(mind in ticker.mode:cult)
					ticker.mode.update_cult_icons_added(src.mind)
			if("nuclear emergency")
				if(mind in ticker.mode:syndicates)
					ticker.mode.update_all_synd_icons()


	if(client.holder && client.holder.state != 1)
		client.holder.state = 1
		var/rank = client.holder.rank
		client.clear_admin_verbs()
		client.update_admins(rank)
	return .

//This stuff needs to be merged from cloning.dm but I'm not in the mood to be shouted at for breaking all the things :< ~Carn
	/* clones
	switch(ticker.mode.name)
		if("revolution")
			if(src.occupant.mind in ticker.mode:revolutionaries)
				ticker.mode:update_all_rev_icons() //So the icon actually appears
			if(src.occupant.mind in ticker.mode:head_revolutionaries)
				ticker.mode:update_all_rev_icons()
		if("nuclear emergency")
			if (src.occupant.mind in ticker.mode:syndicates)
				ticker.mode:update_all_synd_icons()
		if("cult")
			if (src.occupant.mind in ticker.mode:cult)
				ticker.mode:add_cultist(src.occupant.mind)
				ticker.mode:update_all_cult_icons() //So the icon actually appears
	*/

	/*	Plantpeople
	switch(ticker.mode.name)
		if ("revolution")
			if (podman.mind in ticker.mode:revolutionaries)
				ticker.mode:add_revolutionary(podman.mind)
				ticker.mode:update_all_rev_icons() //So the icon actually appears
			if (podman.mind in ticker.mode:head_revolutionaries)
				ticker.mode:update_all_rev_icons()
		if ("nuclear emergency")
			if (podman.mind in ticker.mode:syndicates)
				ticker.mode:update_all_synd_icons()
		if ("cult")
			if (podman.mind in ticker.mode:cult)
				ticker.mode:add_cultist(podman.mind)
				ticker.mode:update_all_cult_icons() //So the icon actually appears
		if ("changeling")
			if (podman.mind in ticker.mode:changelings)
				podman.make_changeling()
	*/