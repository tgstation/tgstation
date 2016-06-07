/mob/living/carbon/human/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, "gibbed-h")

/mob/living/carbon/human/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, "dust-h")

/mob/living/carbon/human/spawn_gibs()
	hgibs(loc, viruses, dna)

/mob/living/carbon/human/spawn_dust()
	new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
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

	dna.species.spec_death(gibbed, src)

	if(ticker && ticker.mode)
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	. = ..(gibbed)
	if(mind && mind.devilinfo)
		spawn(0)
			mind.devilinfo.beginResurrectionCheck(src)

/mob/living/carbon/human/proc/makeSkeleton()
	status_flags |= DISFIGURED
	set_species(/datum/species/skeleton)
	return 1

/mob/living/carbon/proc/ChangeToHusk()
	if(disabilities & HUSK)
		return
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
	blood_volume = 0
	return 1
