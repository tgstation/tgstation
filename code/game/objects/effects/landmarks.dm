/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	unacidable = 1
	w_type=NOT_RECYCLABLE

/obj/effect/landmark/New()
	. = ..()
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
		if("AssetJoinLate")
			assistant_latejoin += loc
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

		if("endgame_exit")
			endgame_safespawns += loc
			del(src)
		if("bluespacerift")
			endgame_exits += loc
			del(src)

	landmarks_list += src
	return 1

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1
