/obj/effect/landmark/New()

	..()
	tag = text("landmark*[]", name)
	invisibility = 101

	switch(name)			//some of these are probably obsolete
		if("shuttle")
			shuttle_z = z
			del(src)

		if("airtunnel_stop")
			airtunnel_stop = x

		if("airtunnel_start")
			airtunnel_start = x

		if("airtunnel_bottom")
			airtunnel_bottom = y

		if("monkey")
			monkeystart += loc
			del(src)
		if("start")
			newplayer_start += loc
			del(src)

		if("wizard")
			wizardstart += loc
			del(src)

		if("JoinLate")
			latejoin += loc
			del(src)

		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			del(src)
	//	if("mazewarp")
	//		mazewarp += loc
		if("Holding Facility")
			holdingfacility += loc
		if("tdome1")
			tdome1	+= loc
		if("tdome2")
			tdome2 += loc
		if("tdomeadmin")
			tdomeadmin	+= loc
		if("tdomeobserve")
			tdomeobserve += loc
		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			del(src)

		if("blobstart")
			blobstart += loc
			del(src)

		if("xeno_spawn")
			xeno_spawn += loc
			del(src)

	return 1

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1