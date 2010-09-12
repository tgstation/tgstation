/obj/landmark/New()

	..()
	src.tag = text("landmark*[]", src.name)
	src.invisibility = 101

	if (name == "shuttle")
		shuttle_z = src.z
		del(src)

	if (name == "airtunnel_stop")
		airtunnel_stop = src.x

	if (name == "airtunnel_start")
		airtunnel_start = src.x

	if (name == "airtunnel_bottom")
		airtunnel_bottom = src.y

	if (name == "monkey")
		monkeystart += src.loc
		del(src)
	if (name == "start")
		newplayer_start += src.loc
		del(src)

	if (name == "wizard")
		wizardstart += src.loc
		del(src)

	if (name == "JoinLate")
		latejoin += src.loc
		del(src)

	//prisoners
	if (name == "prisonwarp")
		prisonwarp += src.loc
		del(src)
	if (name == "mazewarp")
		mazewarp += src.loc
	if (name == "tdome1")
		tdome1	+= src.loc
	if (name == "tdome2")
		tdome2 += src.loc
	if (name == "tdomeadmin")
		tdomeadmin	+= src.loc
	if (name == "tdomeobserve")
		tdomeobserve += src.loc
	//not prisoners
	if (name == "prisonsecuritywarp")
		prisonsecuritywarp += src.loc
		del(src)

	if (name == "blobstart")
		blobstart += src.loc
		del(src)

	return 1

/obj/landmark/start/New()
	..()
	src.tag = "start*[src.name]"
	src.invisibility = 101

	return 1