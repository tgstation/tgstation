
/datum/antagonist/bloodsucker/proc/AmFinalDeath()
 	return !owner.current || !isliving(owner.current) || isbrain(owner.current)

/datum/antagonist/bloodsucker/proc/FinalDeath()

	playsound(get_turf(owner.current), 'sound/effects/tendril_destroyed.ogg', 60, 1)
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	var/mob/living/carbon/C = owner.current
	C.remove_all_embedded_objects()

	// Free my Vassals!
	FreeAllVassals()

	// Elders get Dusted
	if (vamptitle)
		owner.current.visible_message("<span class='warning'>[owner.current]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains.</span>", \
			 "<span class='userdanger'>Your soul escapes your withering body as the abyss welcomes you to your Final Death.</span>", \
			 "<span class='italics'>You hear a dry, crackling sound.</span>")
		owner.current.dust()
	// Fledglings get Gibbed
	else
		owner.current.visible_message("<span class='warning'>[owner.current]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat.</span>", \
			 "<span class='userdanger'>Your soul escapes your withering body as the abyss welcomes you to your Final Death.</span>", \
			 "<span class='italics'>You hear a wet, bursting sound.</span>")
		owner.current.gib()

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			RAISE BLOODSUCKERS AND VASSALS

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



datum/antagonist/bloodsucker/proc/attempt_turn_bloodsucker(mob/living/carbon/target)
	set waitfor = FALSE // We don't want ExpelBlood to wait.

	// DEBUG WAIT (so we can swap back n forth)
	//message_admins("DEBUG: Attempting to Turn Bloodsucker! SLEEPING 5 SEC, SWAP BODIES NOW")
	//sleep(50) // ************************************************************************************************************************

	// 		Requirements:
	// -Dead!
	// -Had a Mind (once the process starts, call back to the mind)
	// -Drained
	// -NOT a Bloodsucker already

	// Vamp-specific: just skip.
	if (target.stat != DEAD)
		//if (target.stat > 0) // Only give warning if target isn't walking and talking.
		//	to_chat(owner, "<span class='danger'>[target] cannot be raised as a Bloodsucker so long as they remain alive.</span>")
		return 0
	if (!target.mind)
		to_chat(owner, "<span class='danger'>[target] is not self-aware enough to be raised as a Bloodsucker!</span>")
		return 0
	if (target.amTurning || target.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		//to_chat(owner, "<span class='userdanger'>DEBUG: TurnBloodsucker fail [target.mind]/ [target.stat] / [target.status_flags & FAKEDEATH] </span>")
		return 0
	// Can be Bloodsucker? Player is active?
	if (!target.can_turn_bloodsucker(owner))	// Invalid, or Final Death (no Head/Heart)
		// NOTE: Warning given in the above proc
		//message_admins("DEBUG: Turn Fail 3")
		return 0
	// Not Dead? Not dying of NO blood?
	//if (target.blood_volume > 0)
	//	to_chat(owner, "<span class='danger'>[target] resists the power of your blood. Drain them of their mortal blood first.</span>")
	//	//message_admins("DEBUG: Turn Fail 4")
	//	return 0

	// Check Blood Content of Stomach
	//if (target.blood_volume > 0)
	//	to_chat(owner, "<span class='warning'>[target] requires more of your blood to rise again.</span>")
	//	//message_admins("DEBUG: Turn Fail 5")
	//	return 0

	// DEBUG WAIT (so we can swap back n forth)
	//sleep(50) // ************************************************************************************************************************

	// ARE YOU SURE?
	//if (alert(user, "Do you wish to raise [target] from death as a Bloodsucker?", "", "Yes", "No") == "No")
	//	return 0
	//var/newVampName
	//while (!newVampName)
	//	// Prompt and confirm new Name
	//	var/defaultname = user.mind.bloodsuckerinfo.ReturnFirstName(target.gender)
	//	newVampName = stripped_input(user, message="What do you want to name",default = defaultname, max_length=MAX_CHARTER_LEN)  // Located in text.dm
	//	newVampName = reject_bad_name(newVampName)	// Located in text.dm

	// DEBUG WAIT (so we can swap back n forth)
	//sleep(50) // ************************************************************************************************************************
	if (!owner.current)
		return 0

	// Success! Let's make them a Bloodsucker now (WHAT THE F*&$ HAVE WE LET THEM DO?!)
	to_chat(owner, "<span class='userdanger'>[target]'s corpse accepts your willing blood. They will turn soon.</span>")
	message_admins("[owner] is attempting to raise [target] as a Bloodsucker.")
	log_admin("[owner] is attempting to raise [target] as a Bloodsucker.")

	// Start Turning Process
	target.turning_bloodsucker(owner)
	return 1





	// 		Types of Player Input:

	// alert(user, "Do you want to customize your declaration?", "Customize?", "Yes", "No")
	//
	// var/new_name = stripped_input(user, message="What do you want to name \
		[station_name()]? Keep in mind particularly terrible names may be \
		rejected by your employers, while names using the standard format, \
		will automatically be accepted.", max_length=MAX_CHARTER_LEN)
	//
	// var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)
	//
	// input("Which colour do you want to use?","Pipe painter") in modes
	//
	// var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the spirit of [user.real_name]'s blade?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)


/mob/living/carbon/proc/can_turn_bloodsucker(datum/mind/creator)
	if (!HaveBloodsuckerBodyparts())
		if (creator)
			to_chat(creator, "<span class='danger'>[src] is missing vital bodyparts to make regneration possible.</span>")
		return 0
	// Staked?
	if (AmStaked())
		if (creator)
			to_chat(creator, "<span class='danger'>The stake in [src]'s chest is preventing their return from death.</span>")
		return 0
	// Not Dead, No Mind, or GENERAL CHECK (not human, already vamp, etc.)
	if (stat != DEAD || !mind || !SSticker.mode.can_make_bloodsucker(mind,creator)) //  || !client)  <--- REMOVED. If you are ghosted, you have no client.
		if (creator)
			to_chat(creator, "<span class='danger'>[src] cannot be raised as a Bloodsucker!</span>")
		//message_admins("DEBUG: Cannot turn [src] into bloodsucker: [client] / [stat] / [mind] / [ckey] / [SSticker.mode.can_make_bloodsucker(mind)] / [AmStaked()]  ||| [mind.key]")
		return 0
	// Ghost occupied a new
	var/mob/G = mind.get_ghost()
	if (!ckey && !G)
		if (creator)
			to_chat(creator, "<span class='danger'>[src] has passed on.</span>")
		return 0
	//if (mind.current != src)
	//	to_chat(creator, "<span class='danger'>[src] has passed on.</span>")
	//	return 0
	// NOTE: If there is any problem figuring out ghosts and ckey reservation, look up both cloning.dm files (one for the machine, one for the process)
	// ALSO: Use mind.get_ghost() to find their floating spooky ghost if needed.

	return 1


/mob/living/carbon
	var/amTurning = FALSE		// Am I turning into a Bloodsucker?

/mob/living/carbon/proc/turning_bloodsucker(datum/mind/vampfather)
	set waitfor = FALSE // We don't want ExpelBlood to wait.

	amTurning = TRUE

	for(var/turnphase in 0 to 1) // NOTE: can write for(var/mob in CONTAINER to sort thru all contents)   //var/turnphase = 0 //while(turnphase < 2)
		// Bring Ghost Back //
		ckey = mind.key
		switch(turnphase)
			if (0)
				to_chat(src, "<span class='danger'>Something inside you is changing. Warmth seeps into your dead bones.</span>")
			if (1)
				playsound(src, 'sound/magic/Demon_consume.ogg', 30, 1)
				to_chat(src, "<span class='danger'>Your skin stretches taut across the reinvigorated fibers of your decaying muscles.</span>")

		//message_admins("DEBUG: [name] Becoming Bloodsucker... SLEEPING 1 SEC, Final should be 15)")
		sleep(150)
		turnphase ++
		// Checks: Not dead anymore? Can't make Bloodsucker? EXIT.
		if (!can_turn_bloodsucker())//stat != DEAD || !mind || !ckey || !SSticker.mode.can_make_bloodsucker(mind, 1))
			to_chat(src, "<span class='danger'>Your soul recoils and you return to death once more.</span>")
			to_chat(vampfather.current, "<span class='userdanger'>Your attempt to bring [src] into unlife as a Bloodsucker has been thwarted. You lament your stillborn childe.</span>")
			amTurning = FALSE
			return

	// Attempt Full Revive
	setToxLoss(0, 0) //zero as second argument not automatically call updatehealth().
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setBrainLoss(0)
	setStaminaLoss(0, 0)
	SetUnconscious(0, 0)
	SetStun(0, 0)
	SetKnockdown(0, 0)
	SetSleeping(0, 0)
	heal_overall_damage(max(0, getBruteLoss() - 50), max(0, getFireLoss() - 50), 0, 0, 1) //heal brute and burn dmg on both organic and robotic limbs, and update health right away.
	ckey = mind.key
	if (can_be_revived())
		revive(0)

	blood_volume = min(blood_volume, 50)

	//revive(0)

	// Put Ghost in Body											// TO DO! If this GHOST is not in another body, put them back in their bloodsucker! ** IN FACT, dont rest them if they have a new body**
	//var/mob/currentMob = owner.current
	//	if(!currentMob)
	//		currentMob = owner.get_ghost()
	//		if(!currentMob)
	// NOTE: When turning Ghost (voluntarily or by death), your ghost has the SAME MIND as your body.

	// Remove Vassal...
	mind.remove_antag_datum(ANTAG_DATUM_VASSAL) //mind.remove_all_antag_datums()

	// Ready!
	SSticker.mode.make_bloodsucker(mind, 1)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// It's Happening!
	var/datum/antagonist/bloodsucker/vampfatherdatum = vampfather.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (vampfatherdatum)
		vampfatherdatum.vampsMade ++ // Give credit for the Embrace.
	if (vampfather.current)
		to_chat(vampfather, "<span class='userdanger'>You feel a [vampfather.current.gender == MALE ? "fatherly" : "motherly"] twinge in your dead heart. [src] has risen as your Bloodsucker child!</span>")

	// Convert all BLOOD in stomach to blood_volume.
	for (var/datum/reagent/blood/vampblood/blood in src.reagents.reagent_list)
		//message_admins("DEBUG: Found vampblood [blood.id], Volume [blood.volume]")
		bloodsuckerdatum.set_blood_volume(blood.volume)
		blood.volume = 0
	for (var/datum/reagent/blood/blood in src.reagents)
		//message_admins("DEBUG: Found normal blood [blood.id], Volume [blood.volume]")
		bloodsuckerdatum.set_blood_volume(blood.volume)
		blood.volume = 0

	// Mind not Present? Place into Torpor (wait for them to come back)
	if (!client || stat == DEAD)
		var/obj/effect/proc_holder/spell/bloodsucker/power_torpor = locate(/obj/effect/proc_holder/spell/bloodsucker/torpidsleep) in bloodsuckerdatum.powers
		if (power_torpor)
			power_torpor.perform(null, TRUE, src)


	amTurning = FALSE
