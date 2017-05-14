/mob/living/carbon/human/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, "gibbed-h")

/mob/living/carbon/human/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, "dust-h")

/mob/living/carbon/human/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/human(loc, viruses, dna)
	else
		new /obj/effect/gibspawner/humanbodypartless(loc, viruses, dna)

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	dizziness = 0
	jitteriness = 0

	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
	if(is_devil(src))
		INVOKE_ASYNC(is_devil(src), /datum/antagonist/devil.proc/beginResurrectionCheck, src)

/mob/living/carbon/human/proc/makeSkeleton()
	status_flags |= DISFIGURED
	set_species(/datum/species/skeleton)
	return 1


/mob/living/carbon/proc/Drain()
	become_husk()
	disabilities |= NOCLONE
	blood_volume = 0
	return 1
