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

	// If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B)
		B.detach()

	for(var/datum/organ/external/E in src.organs)
		if(istype(E, /datum/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status and don't cause an explosion
			E.droplimb(1,1)

	flick("gibbed-h", animation)

	hgibs(loc, viruses, dna, species.flesh_color, species.blood_color)

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

	// If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B)
		B.detach()

	if (istype(src, /mob/living/carbon/human/manifested))
		flick("dust-hm", animation)
	else
		flick("dust-h", animation)
	new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)


/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)	return
	if(healths)		healths.icon_state = "health7"
	stat = DEAD
	dizziness = 0
	jitteriness = 0

	// If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B && B.controlling)
		src << "<span class='danger'>Your host has died.  You reluctantly release control.</span>"
		B.host_brain << "<span class='danger'>Just before your body passes, you feel a brief return of sensation.  You are now in control...  And dead.</span>"
		do_release_control(0)

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
