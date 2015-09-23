/mob/living/carbon/human/gib_animation(animate)
	..(animate, "gibbed-h")

/mob/living/carbon/human/dust_animation(animate)
	..(animate, "dust-h")

/mob/living/carbon/human/dust(animation = 1)
	..()

/mob/living/carbon/human/spawn_gibs()
	if(dna)
		hgibs(loc, viruses, dna)
	else
		hgibs(loc, viruses, null)

/mob/living/carbon/human/spawn_dust()
	new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)	return
	if(is_vampire(src))
		var/datum/vampire/V = get_vampire()
		var/rekt = 0
		if(getFireLoss() > 200) //If they have 200 burn, they die as normal
			src << "<span class='userdanger'>Your life slips away as the burns on your body take their toll...</span>"
			rekt = 1 //Makes it ignore the proc below
		if(!rekt && !reagents.has_reagent("holywater") && V.use_blood(1, 1)) //Vampires are incapable of death if they have clean blood (but can still die if they have holy water in their body)
			adjustBruteLoss(-5)
			adjustFireLoss(-5)
			adjustToxLoss(-5)
			adjustOxyLoss(-5)
			adjustCloneLoss(-5)
			adjustStaminaLoss(-5)
			src << "<span class='warning'>The clean blood in your body protects you from death.</span>"
			return 0
	if(healths)		healths.icon_state = "health5"
	stat = DEAD
	dizziness = 0
	jitteriness = 0
	heart_attack = 0

	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		update_canmove()
		if(client) blind.layer = 0

	if(dna)
		dna.species.spec_death(gibbed,src)

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(!check_dna_integrity(src))	return
	status_flags |= DISFIGURED
	hardset_dna(src, null, null, null, null, /datum/species/skeleton)
	return 1

/mob/living/carbon/proc/ChangeToHusk()
	if(disabilities & HUSK)	return
	disabilities |= HUSK
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	return 1

/mob/living/carbon/human/ChangeToHusk()
	. = ..()
	if(.)
		update_hair()
		update_body()

/mob/living/carbon/proc/Drain()
	ChangeToHusk()
	disabilities |= NOCLONE
	return 1
