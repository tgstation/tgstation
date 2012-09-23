/mob/living/carbon/human/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("gibbed-h", animation)
	hgibs(loc, viruses, dna)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)

/mob/living/carbon/human/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)


/mob/living/carbon/human/death(gibbed)
	if(halloss > 0 && !gibbed)
		halloss = 0
		return
	if(stat == DEAD)	return
	if(healths)		healths.icon_state = "health5"
	stat = DEAD
	dizziness = 0
	jitteriness = 0

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		//For ninjas exploding when they die./N
		if( istype(wear_suit, /obj/item/clothing/suit/space/space_ninja) && wear_suit:s_initialized )
			src << browse(null, "window=spideros")//Just in case.
			var/location = loc
			explosion(location, 1, 2, 3, 4)

		update_canmove()
		if(client)	blind.layer = 0

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	sql_report_death(src)
	ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= NOCLONE
	return