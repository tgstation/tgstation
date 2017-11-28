///mob/living/simple_animal/mouse
//	blood_volume = 200

/*
/mob/proc/can_turn_vassal(datum/mind/creator)
	if (!ishuman(src) || !creator)
		//to_chat(creator, "<span class='danger'>[src].</span>")
		return 0
	if (!mind || !mind.key)
		to_chat(creator, "<span class='danger'>[src] isn't self-aware enough to be made into a Vassal!</span>")
		return 0
	if (stat > UNCONSCIOUS)
		return 0
	return 1

/mob/living/carbon/human/can_turn_vassal(datum/mind/creator)
	if (!..())
		return 0
	// Already My Vassal
	if (mind.enslaved_to == creator)
		return 0
	// Check Overdose
	// if (GET REGAGENT[type].overdosed)
	// Check Loyalty Implant OR Enslaved Already
	if (isloyal() || mind.enslaved_to || mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		to_chat(creator, "<span class='danger'>[src] resists the power of your blood to dominate their mind!</span>")
		return 0
	return 1

// Make Me into Vassal
/mob/proc/attempt_make_vassal(datum/mind/creator)
	return 0
/mob/living/carbon/human/attempt_make_vassal(datum/mind/creator)
	if (!can_turn_vassal(creator))
		return 0

	// Make Vassal
	greet_vassal(creator)
	mind.enslave_mind_to_creator(creator.current)

	// Give to Vamp
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = creator.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	bloodsuckerdatum.vassals |= mind
	SSticker.mode.vassals |= mind

	return 1

// No Longer Vassal
/mob/living/carbon/human/proc/end_vassal()
	// Find my owner and remove me.
	for (var/datum/mind/bloodsucker in SSticker.mode.bloodsuckers)
		// Remove me from Master's list
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if(bloodsuckerdatum && (mind in bloodsuckerdatum.vassals))
			bloodsuckerdatum.vassals -= mind
		// Un-Enslave me
		if (mind.enslaved_to == bloodsucker)
			mind.enslaved_to = null
	SSticker.mode.vassals -= mind



/mob/living/carbon/human/proc/greet_vassal(datum/mind/creator)
	to_chat(src, "<span class='userdanger'>You are now the mortal servant of [creator], a bloodsucking vampire!</span>")
	to_chat(src, "<span class='boldannounce'>The power of [creator.current.p_their()] immortal blood compells you to obey [creator.current.p_them()] in all things, even offering your own life to prolong theirs.<br>\
					You are not required to obey any other Bloodsucker, as only [creator] is your master. The laws of Nanotransen do not apply to you now; only your vampiric master's word must be obeyed.<span>")

	playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	mind.store_memory("You became the mortal servant of [creator], a bloodsucking vampire!")
*/