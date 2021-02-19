/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Patient is unreasonably afraid of something."
	scan_desc = "phobia"
	gain_text = "<span class='warning'>You start finding default values very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of default values.</span>"
	var/phobia_type
	/// Cooldown for proximity checks so we don't spam a range 7 view every two seconds.
	COOLDOWN_DECLARE(check_cooldown)
	/// Cooldown for freakouts to prevent permastunning.
	COOLDOWN_DECLARE(scare_cooldown)

	var/regex/trigger_regex
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs
	var/list/trigger_objs //also checked in mob equipment
	var/list/trigger_turfs
	var/list/trigger_species

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type

	if(!phobia_type)
		phobia_type = pick(SStraumas.phobia_types)

	gain_text = "<span class='warning'>You start finding [phobia_type] very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of [phobia_type].</span>"
	scan_desc += " of [phobia_type]"
	trigger_regex = SStraumas.phobia_regexes[phobia_type]
	trigger_mobs = SStraumas.phobia_mobs[phobia_type]
	trigger_objs = SStraumas.phobia_objs[phobia_type]
	trigger_turfs = SStraumas.phobia_turfs[phobia_type]
	trigger_species = SStraumas.phobia_species[phobia_type]
	..()

/datum/brain_trauma/mild/phobia/on_life(delta_time, times_fired)
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(owner.is_blind())
		return

	if(!COOLDOWN_FINISHED(src, check_cooldown) || !COOLDOWN_FINISHED(src, scare_cooldown))
		return

	COOLDOWN_START(src, check_cooldown, 5 SECONDS)
	var/list/seen_atoms = view(7, owner)
	if(LAZYLEN(trigger_objs))
		for(var/obj/O in seen_atoms)
			if(is_type_in_typecache(O, trigger_objs))
				freak_out(O)
				return
		for(var/mob/living/carbon/human/HU in seen_atoms) //check equipment for trigger items
			for(var/X in HU.get_all_slots() | HU.held_items)
				var/obj/I = X
				if(!QDELETED(I) && is_type_in_typecache(I, trigger_objs))
					freak_out(I)
					return

	if(LAZYLEN(trigger_turfs))
		for(var/turf/T in seen_atoms)
			if(is_type_in_typecache(T, trigger_turfs))
				freak_out(T)
				return

	seen_atoms -= owner //make sure they aren't afraid of themselves.
	if(LAZYLEN(trigger_mobs) || LAZYLEN(trigger_species))
		for(var/mob/M in seen_atoms)
			if(is_type_in_typecache(M, trigger_mobs))
				freak_out(M)
				return

			else if(ishuman(M)) //check their species
				var/mob/living/carbon/human/H = M
				if(LAZYLEN(trigger_species) && H.dna && H.dna.species && is_type_in_typecache(H.dna.species, trigger_species))
					freak_out(H)
					return

/datum/brain_trauma/mild/phobia/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || !COOLDOWN_FINISHED(src, scare_cooldown)) //words can't trigger you if you can't hear them *taps head*
		return
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(!owner.has_language(hearing_args[HEARING_LANGUAGE])) //can't be triggered if you don't know the language
		return
	if(trigger_regex.Find(hearing_args[HEARING_RAW_MESSAGE]) != 0)
		addtimer(CALLBACK(src, .proc/freak_out, null, trigger_regex.group[2]), 10) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = trigger_regex.Replace(hearing_args[HEARING_RAW_MESSAGE], "<span class='phobia'>$2</span>$3")

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(trigger_regex.Find(speech_args[SPEECH_MESSAGE]) != 0)
		to_chat(owner, "<span class='warning'>You can't bring yourself to say the word \"<span class='phobia'>[trigger_regex.group[2]]</span>\"!</span>")
		speech_args[SPEECH_MESSAGE] = ""

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word)
	COOLDOWN_START(src, scare_cooldown, 12 SECONDS)
	if(owner.stat == DEAD)
		return
	var/message = pick("spooks you to the bone", "shakes you up", "terrifies you", "sends you into a panic", "sends chills down your spine")
	if(reason)
		to_chat(owner, "<span class='userdanger'>Seeing [reason] [message]!</span>")
	else if(trigger_word)
		to_chat(owner, "<span class='userdanger'>Hearing \"[trigger_word]\" [message]!</span>")
	else
		to_chat(owner, "<span class='userdanger'>Something [message]!</span>")
	var/reaction = rand(1,4)
	switch(reaction)
		if(1)
			to_chat(owner, "<span class='warning'>You are paralyzed with fear!</span>")
			owner.Stun(70)
			owner.Jitter(8)
		if(2)
			owner.emote("scream")
			owner.Jitter(5)
			owner.say("AAAAH!!", forced = "phobia")
			if(reason)
				owner.pointed(reason)
		if(3)
			to_chat(owner, "<span class='warning'>You shut your eyes in terror!</span>")
			owner.Jitter(5)
			owner.blind_eyes(10)
		if(4)
			owner.dizziness += 10
			owner.add_confusion(10)
			owner.Jitter(10)
			owner.stuttering += 10

// Defined phobia types for badminry, not included in the RNG trauma pool to avoid diluting.

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "spiders"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/space
	phobia_type = "space"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/security
	phobia_type = "security"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "clowns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "greytide"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "lizards"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "skeletons"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "snakes"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "robots"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "doctors"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "authority"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "the supernatural"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "aliens"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "strangers"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "birds"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "falling"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "anime"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "conspiracies"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/insects
	phobia_type = "insects"
	random_gain = FALSE
