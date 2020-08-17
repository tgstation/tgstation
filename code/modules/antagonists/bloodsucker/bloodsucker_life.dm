

// 		TO PLUG INTO LIFE:

// Cancel BLOOD life
// Cancel METABOLISM life   (or find a way to control what gets digested)
// Create COLDBLOODED trait (thermal homeostasis)

// 		EXAMINE
//
// Show as dead when...







/datum/antagonist/bloodsucker/proc/LifeTick() // Should probably run from life.dm, same as handle_changeling
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	var/notice_healing = FALSE
	while (owner && !AmFinalDeath()) // owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) == src

		// Deduct Blood
		if (owner.current.stat == CONSCIOUS && !poweron_feed && !HAS_TRAIT(owner.current, TRAIT_DEATHCOMA))
			AddBloodVolume(-0.1) // -.15 (before tick went from 10 to 30, but we also charge more for faking life now)

		// Heal
		if (HandleHealing(1))
			if (notice_healing == FALSE && owner.current.blood_volume > 0)
				to_chat(owner, "<span class='notice'>The power of your blood begins knitting your wounds...</span>")
				notice_healing = TRUE
		else if (notice_healing == TRUE)
			notice_healing = FALSE

		// Apply Low Blood Effects
		HandleStarving()

		// Death
		HandleDeath()

		// Standard Update
		update_hud()

		// Daytime Sleep in Coffin
		if (SSticker.mode.is_daylight() && !HAS_TRAIT_FROM(owner.current, TRAIT_DEATHCOMA, "bloodsucker"))
			if(istype(owner.current.loc, /obj/structure/closet/crate/coffin))
				Torpor_Begin()

		// Wait before next pass
		sleep(10)//sleep(30)

	// Free my Vassals! (if I haven't yet)
	FreeAllVassals()





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			BLOOD

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	owner.current.blood_volume = clamp(owner.current.blood_volume + value, 0, maxBloodVolume)
	update_hud()


/datum/antagonist/bloodsucker/proc/HandleFeeding(mob/living/carbon/target, mult=1)
	// mult: SILENT feed is 1/3 the amount

	var/blood_taken = min(feedAmount, target.blood_volume) * mult	// Starts at 15 (now 8 since we doubled the Feed time)
	target.blood_volume -= blood_taken

	// Simple Animals lose a LOT of blood, and take damage. This is to keep cats, cows, and so forth from giving you insane amounts of blood.
	if (!ishuman(target))
		target.blood_volume -= (blood_taken / max(target.mob_size, 0.1)) * 3.5 // max() to prevent divide-by-zero
		target.apply_damage_type(blood_taken / 3.5) // Don't do too much damage, or else they die and provide no blood nourishment.
		if (target.blood_volume <= 0)
			target.blood_volume = 0
			target.death(0)

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((owner.current.blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (owner.current.blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////

	// Reduce Value Quantity
	if (target.stat == DEAD)	// Penalty for Dead Blood
		blood_taken /= 3
	if (!ishuman(target))		// Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target))	// Penalty for Animals (they're junk food)


	// Apply to Volume
	AddBloodVolume(blood_taken)

	// Reagents (NOT Blood!)
	if(target.reagents && target.reagents.total_volume)
		//target.reagents.reaction(owner.current, INGEST, 1 / target.reagents.total_volume) // Run Reaction: what happens when what they have mixes with what I have?	DEAD CODE MUST REWORK
		target.reagents.trans_to(owner.current, 1)	// Run transfer of 1 unit of reagent from them to me.

	// Blood Gulp Sound
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.


/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedly from that which nourishes me.</span>\n"
	mood_change = 10
	timeout = 900
/datum/mood_event/drankblood_bad
	description = "<span class='boldwarning'>I drank the blood of a lesser creature. Disgusting.</span>\n"
	mood_change = -4
	timeout = 900
/datum/mood_event/drankblood_dead
	description = "<span class='boldwarning'>I drank dead blood. I am better than this.</span>\n"
	mood_change = -7
	timeout = 900
/datum/mood_event/drankblood_synth
	description = "<span class='boldwarning'>I drank synthetic blood. What is wrong with me?</span>\n"
	mood_change = -7
	timeout = 900
/datum/mood_event/drankkilled
	description = "<span class='boldwarning'>I drank from my victim until they died. I feel...less human.</span>\n"
	mood_change = -12
	timeout = 6000
/datum/mood_event/madevamp
	description = "<span class='boldwarning'>A soul has been cursed to undeath by my own hand.</span>\n"
	mood_change = -10
	timeout = 10000
/datum/mood_event/vampatefood
	description = "<span class='boldwarning'>Mortal nourishment no longer sustains me. I feel unwell.</span>\n"
	mood_change = -6
	timeout = 1000
/datum/mood_event/coffinsleep
	description = "<span class='nicegreen'>I slept in a coffin during the day. I feel whole again.</span>\n"
	mood_change = 8
	timeout = 1200
/datum/mood_event/daylight_1
	description = "<span class='boldwarning'>I slept poorly in a makeshift coffin during the day.</span>\n"
	mood_change = -3
	timeout = 1000
/datum/mood_event/daylight_2
	description = "<span class='boldwarning'>I have been scorched by the unforgiving rays of the sun.</span>\n"
	mood_change = -6
	timeout = 1200

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			HEALING

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//
/datum/antagonist/bloodsucker/proc/HandleHealing(mult = 1)

	// NOTE: Mult of 0 is just a TEST to see if we are injured and need to go into Torpor!
	//		 It is called from your coffin on close (by you only)

	if (poweron_masquerade == TRUE || owner.current.AmStaked())
		return FALSE

	owner.current.adjustStaminaLoss(-5 * (regenRate * 4) * mult, 0) // Humans lose stamina damage really quickly. Vamps should heal more.
	owner.current.adjustCloneLoss(-1 * (regenRate * 4) * mult, 0)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (regenRate * 4) * mult) //adjustBrainLoss(-1 * (regenRate * 4) * mult, 0)

	owner.current.setOxyLoss(0)
	owner.current.setToxLoss(0)

	// No Bleeding
	//if (ishuman(owner.current))
		//var/mob/living/carbon/human/H = owner.current		DEAD CODE MUST REWORK
		//H.bleed_rate = 0		DEAD CODE MUST REWORK

	// Damage Heal: Do I have damage to ANY bodypart?
	if (iscarbon(owner.current))
		var/mob/living/carbon/C = owner.current
		var/costMult = 1 // Coffin makes it cheaper

		// BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
		var/fireheal = 0
		var/amInCoffinWhileTorpor = istype(C.loc, /obj/structure/closet/crate/coffin) && (mult == 0 || HAS_TRAIT(C, TRAIT_DEATHCOMA)) // Check for mult 0 OR death coma. (mult 0 means we're testing from coffin)
		if(amInCoffinWhileTorpor)
			mult *= 5 // Increase multiplier if we're sleeping in a coffin.
			fireheal = min(C.getFireLoss_nonProsthetic(), regenRate) // NOTE: Burn damage ONLY heals in torpor.
			costMult = 0.25
			// Extinguish Fire
			C.ExtinguishMob()
		else
			// No Blood? Lower Mult
			if (owner.current.blood_volume <= 0)
				mult = 0.25
			// Crit from burn? Lower damage to maximum allowed.
			//if (C.getFireLoss() > owner.current.getMaxHealth())
			//	fireheal = regenRate / 2
		// BRUTE: Always Heal
		var/bruteheal = min(C.getBruteLoss_nonProsthetic(), regenRate)

		// Heal if Damaged
		if (bruteheal + fireheal > 0)
			// Just a check? Don't heal/spend, and return.
			if (mult == 0)
				return TRUE
			// We have damage. Let's heal (one time)
			C.adjustBruteLoss(-bruteheal * mult, forced=TRUE)// Heal BRUTE / BURN in random portions throughout the body.
			C.adjustFireLoss(-fireheal * mult, forced=TRUE)
			//C.heal_overall_damage(bruteheal * mult, fireheal * mult)				 // REMOVED: We need to FORCE this, because otherwise, vamps won't heal EVER. Swapped to above.

			// Pay Cost
			AddBloodVolume((bruteheal * -0.5 + fireheal * -1) / mult * costMult)	// Costs blood to heal

			// Healed! Done for this tick.
			return TRUE

		// Limbs? (And I have no other healing)
		if (amInCoffinWhileTorpor)

			// Heal Missing
			var/list/missing = owner.current.get_missing_limbs()
			if (missing.len)
				// Cycle through ALL limbs and regen them!
				for (var/targetLimbZone in missing)
					// 1) Find ONE Limb and regenerate it.
					//var/targetLimbZone = pick(missing)
					owner.current.regenerate_limb(targetLimbZone, 0)		// regenerate_limbs() <--- If you want to EXCLUDE certain parts, do it like this ----> regenerate_limbs(0, list("head"))
					// 2) Limb returns Damaged
					var/obj/item/bodypart/L = owner.current.get_bodypart( targetLimbZone )
					AddBloodVolume(20 * costMult)	// Costs blood to heal
					L.brute_dam = 60
					to_chat(owner.current, "<span class='notice'>Your flesh knits as it regrows [L]!</span>")
					playsound(owner.current, 'sound/magic/demon_consume.ogg', 50, 1)


				// DONE! After regenerating ANY number of limbs, we stop here.
				return TRUE

			/*else // REMOVED: For now, let's just leave prosthetics on. Maybe you WANT to be a robovamp.
				// Remove Prosthetic/False Limb
				for(var/obj/item/bodypart/BP in C.bodyparts)
					message_admins("T1: [BP] ")
					if (istype(BP) && BP.status == 2)
						message_admins("T2: [BP] ")
						BP.drop_limb()
						return TRUE
						// NOTE: Limbs have a "status", like their hosts "stat". 2 is dead (aka Prosthetic). 1 seems to be idle/alive.
			*/

			// Cure Final Disabilities
			CureDisabilities()

			// Remove Embedded!
			C.remove_all_embedded_objects()
			// Heal Organs (will respawn original eyes etc. but we replace right away, next)
			owner.current.regenerate_organs()
			// Eyes/Heart
			CheckVampOrgans() // Heart, Eyes

	return FALSE


/datum/antagonist/bloodsucker/proc/CureDisabilities()
	var/mob/living/carbon/C = owner.current

	C.cure_blind(list(EYE_DAMAGE))//()
	C.cure_nearsighted(EYE_DAMAGE)
	C.set_blindness(0) 	// Added 9/2/19
	C.set_blurriness(0) // Added 9/2/19
	C.update_tint() 	// Added 9/2/19
	C.update_sight() 	// Added 9/2/19

	for(var/O in C.internal_organs) //owner.current.adjust_eye_damage(-100)  // This was removed by TG
		var/obj/item/organ/organ = O
		organ.setOrganDamage(0)

	owner.current.cure_husk()


// I am hungry!
/datum/antagonist/bloodsucker/proc/HandleStarving()

	// High: 	Faster Healing
	// Med: 	Pale
	// Low: 	Twitch
	// V.Low:   Blur Vision
	// EMPTY:	Frenzy!

	// BLOOD_VOLUME_GOOD: [336]  Pale (handled in bloodsucker_integration.dm


	// BLOOD_VOLUME_BAD: [224]  Jitter
	if (owner.current.blood_volume < BLOOD_VOLUME_BAD && !prob(0.5))
		owner.current.Jitter(10)

	// BLOOD_VOLUME_SURVIVE: [122]  Blur Vision
	if (owner.current.blood_volume < BLOOD_VOLUME_BAD / 2)
		owner.current.blur_eyes(8 - 8 * (owner.current.blood_volume / BLOOD_VOLUME_BAD))

	// Nutrition
	owner.current.nutrition = min(owner.current.blood_volume, NUTRITION_LEVEL_FED) // <-- 350  //NUTRITION_LEVEL_FULL



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			DEATH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/antagonist/bloodsucker/proc/HandleDeath()

		// 	FINAL DEATH

	// Fire Damage? (above double health)
	if (owner.current.getFireLoss_nonProsthetic() >= owner.current.getMaxHealth() * 2)
		FinalDeath()
		return
	// Staked while "Temp Death" or Asleep
	if (owner.current.StakeCanKillMe() && owner.current.AmStaked())
		FinalDeath()
		return
	// Not "Alive"?
	if (!owner.current || !isliving(owner.current) || isbrain(owner.current) || !get_turf(owner.current))
		FinalDeath()
		return
	// Missing Brain or Heart?
	if (!owner.current.HaveBloodsuckerBodyparts())
		FinalDeath()
		return

				// Disable Powers: Masquerade	* NOTE * This should happen as a FLAW!
				//if (stat >= UNCONSCIOUS)
				//	for (var/datum/action/bloodsucker/masquerade/P in powers)
				//		P.Deactivate()

		//	TEMP DEATH
	var/total_brute = owner.current.getBruteLoss_nonProsthetic()
	var/total_burn = owner.current.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	// Died? Convert to Torpor (fake death)
	if (owner.current.stat >= DEAD)
		Torpor_Begin()
		to_chat(owner, "<span class='danger'>Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor.</span>")
		if (poweron_masquerade == TRUE)
			to_chat(owner, "<span class='warning'>Your wounds will not heal until you disable the <span class='boldnotice'>Masquerade</span> power.</span>")
	// End Torpor:
	else	// No damage, OR brute healed and NOT in coffin (since you cannot heal burn)
		if (total_damage <= 0 || total_brute <= 0 && !istype(owner.current.loc, /obj/structure/closet/crate/coffin))
			// Not Daytime, Not in Torpor
			if (!SSticker.mode.is_daylight() && HAS_TRAIT_FROM(owner.current, TRAIT_DEATHCOMA, "bloodsucker"))
				Torpor_End()
		// Fake Unconscious
		if (poweron_masquerade == TRUE && total_damage >= owner.current.getMaxHealth() - HEALTH_THRESHOLD_FULLCRIT)
			owner.current.Unconscious(20,1)

	//HEALTH_THRESHOLD_CRIT 0
	//HEALTH_THRESHOLD_FULLCRIT -30
	//HEALTH_THRESHOLD_DEAD -100

/datum/antagonist/bloodsucker/proc/Torpor_Begin(amInCoffin=FALSE)
	owner.current.stat = UNCONSCIOUS
	owner.current.fakedeath("bloodsucker") // Come after UNCONSCIOUS or else it fails
	//owner.current.update_stat()
	ADD_TRAIT(owner.current, TRAIT_NODEATH,"bloodsucker")	// Without this, you'll just keep dying while you recover.
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE,"bloodsucker")	// So you can heal in 0 G. otherwise you just...heal forever.
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE,"bloodsucker")	// So you can heal in 0 G. otherwise you just...heal forever.
	// Visuals
	owner.current.update_sight()
	owner.current.reload_fullscreen()
	// Disable ALL Powers
	for (var/datum/action/bloodsucker/power in powers)
		if (power.active && !power.can_use_in_torpor)
			power.DeactivatePower()


/datum/antagonist/bloodsucker/proc/Torpor_End()
	owner.current.stat = SOFT_CRIT
	owner.current.cure_fakedeath("bloodsucker") // Come after SOFT_CRIT or else it fails
	//owner.current.update_stat()
	REMOVE_TRAIT(owner.current, TRAIT_NODEATH, "bloodsucker")
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, "bloodsucker")	// So you can heal in 0 G. otherwise you just...heal forever.
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, "bloodsucker")	// So you can heal in 0 G. otherwise you just...heal forever.
	to_chat(owner, "<span class='warning'>You have recovered from Torpor.</span>")





/datum/antagonist/proc/AmFinalDeath()
	// Standard Antags can be dead OR final death
 	return owner && (owner.current && owner.current.stat >= DEAD || owner.AmFinalDeath())

/datum/antagonist/bloodsucker/AmFinalDeath()
 	return owner && owner.AmFinalDeath()
/datum/antagonist/changeling/AmFinalDeath()
 	return owner && owner.AmFinalDeath()

/datum/mind/proc/AmFinalDeath()
 	return !current || QDELETED(current) || !isliving(current) || isbrain(current) || !get_turf(current) // NOTE: "isliving()" is not the same as STAT == CONSCIOUS. This is to make sure you're not a BORG (aka silicon)

/datum/antagonist/bloodsucker/proc/FinalDeath()

	playsound(get_turf(owner.current), 'sound/effects/tendril_destroyed.ogg', 60, 1)
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	var/mob/living/carbon/C = owner.current
	C.remove_all_embedded_objects()

	// Make me UN-CLONEABLE
	owner.current.hellbound = TRUE // This was done during creation, but let's do it again one more time...to make SURE this guy stays dead.


	// Free my Vassals!
	FreeAllVassals()

	// Elders get Dusted
	if (vamplevel >= 4) // (vamptitle)
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
	playsound(owner.current.loc, 'sound/effects/tendril_destroyed.ogg', 40, 1)



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			HUMAN FOOD

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/proc/CheckBloodsuckerEatFood(var/food_nutrition)
	if (!isliving(src))
		return
	var/mob/living/L = src
	if (!L.AmBloodsucker())
		return
	// We're a vamp? Try to eat food...
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	bloodsuckerdatum.handle_eat_human_food(food_nutrition)


/datum/antagonist/bloodsucker/proc/handle_eat_human_food(var/food_nutrition) // Called from snacks.dm and drinks.dm
	set waitfor = FALSE

	if (!owner.current || !iscarbon(owner.current))
		return
	var/mob/living/carbon/C = owner.current

	// Remove Nutrition, Give Bad Food
	C.nutrition -= food_nutrition
	foodInGut += food_nutrition

	// Already ate some bad clams? Then we can back out, because we're already sick from it.
	if (foodInGut != food_nutrition)
		return
	// Haven't eaten, but I'm in a Human Disguise.
	else if (poweron_masquerade)
		to_chat(C, "<span class='notice'>Your stomach turns, but your \"human disguise\" keeps the food down...for now.</span>")


	// Keep looping until we purge. If we have activated our Human Disguise, we ignore the food. But it'll come up eventually...
	var/sickphase = 0
	while (foodInGut)

		sleep(50)

		C.adjust_disgust(10 * sickphase)

		// Wait an interval...
		sleep(50 + 50 * sickphase) // At intervals of 100, 150, and 200. (10 seconds, 15 seconds, and 20 seconds)

		// Died? Cancel
		if (C.stat == DEAD)
			return
		// Put up disguise? Then hold off the vomit.
		if (poweron_masquerade)
			if (sickphase > 0)
				to_chat(C, "<span class='notice'>Your stomach settles temporarily. You regain your composure...for now.</span>")
			sickphase = 0
			continue

		switch(sickphase)
			if (1)
				to_chat(C, "<span class='warning'>You feel unwell. You can taste ash on your tongue.</span>")
				C.Immobilize(10)
			if (2)
				to_chat(C, "<span class='warning'>Your stomach turns. Whatever you ate tastes of grave dirt and brimstone.</span>")
				//C.Dizzy(15)
				C.Immobilize(20)
			if (3)
				to_chat(C, "<span class='warning'>You purge the food of the living from your viscera! You've never felt worse.</span>")
				C.vomit(foodInGut * 4, foodInGut * 2, 0)  // (var/lost_nutrition = 10, var/blood = 0, var/stun = 1, var/distance = 0, var/message = 1, var/toxic = 0)
				C.blood_volume = max(0, C.blood_volume - foodInGut * 2)
				C.Stun(30)
				//C.Dizzy(50)
				foodInGut = 0

		sickphase ++







/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//	VAMPIRE LANGUAGE //

/datum/language/vampiric
	name = "Blah-Sucker"
	desc = "The native language of the Bloodsucker elders, learned intuitively by Fledglings as they pass from death into immortality."
	key = "b"
	space_chance = 40
	default_priority = 90

	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD // Hide the icon next to your text if someone doesn't know this language.
	syllables = list(
		"luk","cha","no","kra","pru","chi","busi","tam","pol","spu","och",		// Start: Vampiric
		"umf","ora","stu","si","ri","li","ka","red","ani","lup","ala","pro",
		"to","siz","nu","pra","ga","ump","ort","a","ya","yach","tu","lit",
		"wa","mabo","mati","anta","tat","tana","prol",
		"tsa","si","tra","te","ele","fa","inz",									// Start: Romanian
		"nza","est","sti","ra","pral","tsu","ago","esch","chi","kys","praz",	// Start: Custom
		"froz","etz","tzil",
		"t'","k'","t'","k'","th'","tz'"
		)

	icon_state = "bloodsucker"
	icon = 'icons/Fulpicons/fulpicons_small.dmi'

//datum/language
	//var/name = "an unknown language"  // Fluff name of language if any.
	//var/desc = "A language."          // Short description for 'Check Languages'.
	//var/speech_verb = "says"          // 'says', 'hisses', 'farts'.
	//var/ask_verb = "asks"             // Used when sentence ends in a ?
	//var/exclaim_verb = "exclaims"     // Used when sentence ends in a !
	//var/whisper_verb = "whispers"     // Optional. When not specified speech_verb + quietly/softly is used instead.
	//var/list/signlang_verb = list("signs", "gestures") // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	//var/key  							// If key is null, then the language isn't real or learnable.
	//var/flags                         // Various language flags.
	//var/list/syllables                // Used when scrambling text for a non-speaker.
	//var/sentence_chance = 5      // Likelihood of making a new sentence after each syllable.
	//var/space_chance = 55        // Likelihood of getting a space in the random scramble string
	//var/list/spans = list()
	//var/list/scramble_cache = list()
	//var/default_priority = 0          // the language that an atom knows with the highest "default_priority" is selected by default.

	// if you are seeing someone speak popcorn language, then something is wrong.
	//var/icon = 'icons/misc/language.dmi'
	//var/icon_state = "popcorn"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



