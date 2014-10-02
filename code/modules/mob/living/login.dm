/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)

	//hud updates
	if(ticker && ticker.mode && ticker.mode.name == "sandbox")
		CanBuild()

	if((mind in ticker.mode.revolutionaries) || (src.mind in ticker.mode.head_revolutionaries))
		ticker.mode.update_rev_icons_added(src.mind)

	if((mind in ticker.mode.A_bosses) || (mind in ticker.mode.A_gangsters))
		ticker.mode.update_gang_icons_added(src.mind,"A")
	if((mind in ticker.mode.B_bosses) || (mind in ticker.mode.B_gangsters))
		ticker.mode.update_gang_icons_added(src.mind,"B")

	if(mind in ticker.mode.cult)
		ticker.mode.update_cult_icons_added(src.mind)

	if(mind in ticker.mode.syndicates)
		ticker.mode.update_all_synd_icons()

	if(ventcrawler)
		src << "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>"
	update_interface()
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