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

	for(var/datum/organ/external/E in src.organs)
		if(istype(E, /datum/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status and don't cause an explosion
			E.droplimb(1,1)

	flick("gibbed-h", animation)
	if(species)
		hgibs(loc, viruses, dna, species.flesh_color, species.blood_color)
	else
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
	if(stat == DEAD)	return
	if(healths)		healths.icon_state = "health5"
	stat = DEAD
	dizziness = 0
	jitteriness = 0

	//Handle brain slugs.
	var/datum/organ/external/head = get_organ("head")
	var/mob/living/simple_animal/borer/B
	if(head && istype(head))
		for(var/I in head.implants)
			if(istype(I,/mob/living/simple_animal/borer))
				B = I
	if(B)
		if(!B.ckey && ckey && B.controlling)
			B.ckey = ckey
			B.controlling = 0
		if(B.host_brain.ckey)
			ckey = B.host_brain.ckey
			B.host_brain.ckey = null
			B.host_brain.name = "host brain"
			B.host_brain.real_name = "host brain"

		verbs -= /mob/living/carbon/proc/release_control

	//Check for heist mode kill count.
	if(ticker.mode && ( istype( ticker.mode,/datum/game_mode/heist) ) )
		//Check for last assailant's mutantrace.
		/*if( LAssailant && ( istype( LAssailant,/mob/living/carbon/human ) ) )
			var/mob/living/carbon/human/V = LAssailant
			if (V.dna && (V.dna.mutantrace == "vox"))*/ //Not currently feasible due to terrible LAssailant tracking.
		//world << "Vox kills: [vox_kills]"
		vox_kills++ //Bad vox. Shouldn't be killing humans.
	if(ishuman(LAssailant))
		var/mob/living/carbon/human/H=LAssailant
		if(H.mind)
			H.mind.kills += "[name] ([ckey])"

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		//For ninjas exploding when they die.
		if( istype(wear_suit, /obj/item/clothing/suit/space/space_ninja) && wear_suit:s_initialized )
			src << browse(null, "window=spideros")//Just in case.
			var/location = loc
			explosion(location, 1, 2, 3, 4)

		update_canmove()
		if(client)	blind.layer = 0

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(SKELETON in src.mutations)	return

	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(SKELETON)
	status_flags |= DISFIGURED
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	if(M_HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(M_HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= M_NOCLONE
	return
