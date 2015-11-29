/mob/living/carbon/human/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	//If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B)
		B.detach()

	for(var/datum/organ/external/E in src.organs)
		if(istype(E, /datum/organ/external/chest) || istype(E, /datum/organ/external/groin)) //Really bad stuff happens when either get removed
			continue
		//Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			//Override the current limb status and don't cause an explosion
			E.droplimb(1, 1)

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-h", sleeptime = 15)
	hgibs(loc, viruses, dna, species.flesh_color, species.blood_color)
	qdel(src)

/mob/living/carbon/human/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	//If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B)
		B.detach()

	if(istype(src, /mob/living/carbon/human/manifested))
		anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-hm", sleeptime = 15)
	else
		anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 15)

	new /obj/effect/decal/remains/human(loc)
	qdel(src)

/mob/living/carbon/human/Destroy()
	if(mind && species && (species.name == "Manifested") && (mind in ticker.mode.cult))//manifested ghosts are removed from the cult once their bodies are destroyed
		ticker.mode.update_cult_icons_removed(mind)
		ticker.mode.cult -= mind
	..()

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	if(healths)		healths.icon_state = "health7"
	stat = DEAD
	dizziness = 0
	jitteriness = 0

	//If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B && B.controlling)
		to_chat(src, "<span class='danger'>Your host has died.  You reluctantly release control.</span>")
		to_chat(B.host_brain, "<span class='danger'>Just before your body passes, you feel a brief return of sensation.  You are now in control...  And dead.</span>")
		do_release_control(0)

	//Check for heist mode kill count.
	if(ticker.mode && ( istype( ticker.mode,/datum/game_mode/heist) ) )
		//Check for last assailant's mutantrace.
		/*if( LAssailant && ( istype( LAssailant,/mob/living/carbon/human ) ) )
			var/mob/living/carbon/human/V = LAssailant
			if (V.dna && (V.dna.mutantrace == "vox"))*/ //Not currently feasible due to terrible LAssailant tracking.
//		to_chat(world, "Vox kills: [vox_kills]")
		vox_kills++ //Bad vox. Shouldn't be killing humans.
	if(ishuman(LAssailant))
		var/mob/living/carbon/human/H=LAssailant
		if(H.mind)
			H.mind.kills += "[name] ([ckey])"

	if(!gibbed)
		emote("deathgasp") //Let the world KNOW WE ARE DEAD

		update_canmove()
		if(client)	blind.layer = 0

	tod = worldtime2text() //Weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
		if(!suiciding) //Cowards don't count
			score["deadcrew"]++ //Someone died at this point, and that's terrible
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win() //Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(SKELETON in src.mutations)
		return

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
	if(M_HUSK in mutations)
		return
	if(f_style)
		f_style = "Shaved" //We only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(M_HUSK)
	status_flags |= DISFIGURED	//Makes them unknown without fucking up other stuff like admintools
	update_body(0)
	update_mutantrace()
	vessel.remove_reagent("blood",vessel.get_reagent_amount("blood"))
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= M_NOCLONE
	return
