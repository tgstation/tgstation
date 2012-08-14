/obj/effect/landmark/New()

	..()
	tag = text("landmark*[]", name)
	invisibility = 101

	if (name == "monkey")
		monkeystart += loc
		del(src)
	if (name == "start")
		newplayer_start += loc
		del(src)

	if (name == "wizard")
		wizardstart += loc
		del(src)

	if (name == "JoinLate")
		latejoin += loc
		del(src)

	//prisoners
	if (name == "prisonwarp")
		prisonwarp += loc
		del(src)

	if (name == "Holding Facility")
		holdingfacility += loc
	if (name == "tdome1")
		tdome1	+= loc
	if (name == "tdome2")
		tdome2 += loc
	if (name == "tdomeadmin")
		tdomeadmin	+= loc
	if (name == "tdomeobserve")
		tdomeobserve += loc
	//not prisoners
	if (name == "prisonsecuritywarp")
		prisonsecuritywarp += loc
		del(src)

	if (name == "blobstart")
		blobstart += loc
		del(src)

	if(name == "xeno_spawn")
		xeno_spawn += loc
		del(src)

	if(name == "emcloset")
		emclosets += loc
		del(src)

	return 1

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1