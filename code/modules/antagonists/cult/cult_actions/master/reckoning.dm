/datum/action/innate/cult/master/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"

/datum/action/innate/cult/master/finalreck/Activate()
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult, check_subtypes = TRUE)
	if(!antag)
		return
	var/place = get_area(owner)
	var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
	if(place in summon_objective.summon_spots)//cant do final reckoning in the summon area to prevent abuse, you'll need to get everyone to stand on the circle!
		to_chat(owner, span_cult_large("The veil is too weak here! Move to an area where it is strong enough to support this magic."))
		return
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T in orange(1, owner))
			if(!T.is_blocked_turf(TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, span_warning("You need more space to summon your cult!"))
			return
		if(!do_after(owner, 3 SECONDS, target = owner))
			return
		for(var/datum/mind/B in antag.cult_team.members)
			if(!B.current || B.current.stat == DEAD)
				continue
			var/turf/mobloc = get_turf(B.current)
			switch(i)
				if(1)
					new /obj/effect/temp_visual/cult/sparks(mobloc, B.current.dir)
					playsound(mobloc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				if(2)
					new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, B.current.dir)
					playsound(mobloc, SFX_PORTAL_ENTER, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				if(3)
					new /obj/effect/temp_visual/dir_setting/cult/phase(mobloc, B.current.dir)
					playsound(mobloc, SFX_PORTAL_ENTER, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				if(4)
					playsound(mobloc, 'sound/effects/magic/exit_blood.ogg', 100, TRUE)
					if(B.current != owner)
						var/turf/final = pick(destinations)
						if(istype(B.current.loc, /obj/item/soulstone))
							var/obj/item/soulstone/S = B.current.loc
							S.release_shades(owner)
						B.current.setDir(SOUTH)
						new /obj/effect/temp_visual/cult/blood(final)
						addtimer(CALLBACK(antag, TYPE_PROC_REF(/datum/antagonist/cult, reckon), B.current, final), 1 SECONDS)
	antag.cult_team.reckoning_complete = TRUE
	Remove(owner)

/datum/action/innate/cult/master/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common, forced = "cult invocation")
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/effects/magic/clockwork/narsie_attack.ogg', 50, TRUE)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/effects/magic/clockwork/narsie_attack.ogg', 75, TRUE)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/effects/magic/clockwork/narsie_attack.ogg', 100, TRUE)
