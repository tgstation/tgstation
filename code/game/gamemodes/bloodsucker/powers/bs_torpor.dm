



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/bloodsucker/torpidsleep
	name = "Torpid Sleep"
	desc = "Enter a corpselike sleep and heal terrible injuries...even in death! You will not rise again until your physical wounds are healed. This costs blood outside of a Coffin."
	invocation = ""
	school = "vampiric"
	amToggleable = TRUE
	//toggleLock = TRUE
	targetmessage_ON =  ""//"<span class='notice'>Your pulse starts again. You feel...almost human.</span>"
	targetmessage_OFF = ""//"<span class='notice'>You shrug off the disguise of frail human weakness. You are powerful once more.</span>"
	stat_allowed = DEAD
	charge_max = 100
	action_icon_state = "power_torpor"				// State for that image inside icon
	give_on_start = TRUE

// CAST CHECK //	// USE THIS WHEN CLICKING ON THE ICON //
/obj/effect/proc_holder/spell/bloodsucker/torpidsleep/cast_check(skipcharge = 0,mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	//if (NOT STANDING ON AN OPEN COFFIN?)
	//	return 0
	if (user.AmStaked()) // Located in bloodsucker_items
		to_chat(user, "<span class='danger'>With a stake in your heart, you cannot regenerate!</span>")
		return 0
	if(!..())// DEFAULT CHECKS
		return 0
	if (!user.HaveBloodsuckerBodyparts("rising from death"))//if (!user.getorganslot("heart"))
		return 0
	//if (src.active)
	//	to_chat(user, "<span class='warning'>You're already attempting to regenerate.</span>")
	//	return 0
	if(!user.stat) // Taken from Changeling, confirms that you WANT to do this even though you're alive currently.
		switch(alert("Do you wish to pass into Torpid Sleep?",,"Yes", "No"))
			if("No")
				return 0
	// DONE!
	return 1

// CANCEL CAST CHECK //	// USE THIS WHEN CLICKING ON AN ALREADY-ON ICON //
/obj/effect/proc_holder/spell/bloodsucker/torpidsleep/cancel_check(mob/living/user = usr)
	if (!..())// DEFAULT CHECKS
		return 0
	// Not if Damaged or Missing Limbs
	//var/mob/living/carbon/C = owner.current
	//var/list/missing = owner.current.get_missing_limbs()
	//if (C.get_damaged_bodyparts(TRUE, TRUE) || missing.len)
	//	to_chat(user, "<span class='warning'>You will rise again when all your corporeal wounds are healed.</span>")
	//	return 0

	// Cancel! You leave this automatically.
	to_chat(user, "<span class='warning'>You will rise again when all your corporeal wounds are healed.</span>")
	return 0



// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/torpidsleep/cast(list/targets, mob/living/user = usr)
	..() // DEFAULT

	var/insideCoffin = FALSE

	// Already Alive? "Kill" me.
	if(user.stat != DEAD)
		// Find Coffin Test
		insideCoffin = istype(user.loc, /obj/structure/closet/coffin)
		if (!insideCoffin)
			var/obj/structure/closet/coffin/floorCoffin = locate(/obj/structure/closet/coffin) in get_turf(user)
			if (floorCoffin)
				user.fall() // user.Resting(10)
				user.density = 0 // This is dumb, but here we are. fall() doesn't un-dense you, but you'll be fine when you get back up.
				//floorCoffin.open()
				floorCoffin.close(user)
				insideCoffin = istype(user.loc, /obj/structure/closet/coffin)

		// Apply Willing "Death"
		to_chat(user, "<span class='notice'>You give in to the call of an ancient sleep. The light of this world fades...</span>")
		user.emote("deathgasp")
		user.tod = worldtime2text()
		user.fakedeath("torpor") // user.status_flags |= FAKEDEATH //play dead
		user.update_stat()
		user.update_canmove()


	sleep(50) // 5 seconds...
	to_chat(user, "<span class='notice'>The lividity of your corpse drains away. Your parched veins pulse...</span>")
	user.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	sleep(50) // 5 second wait until healing starts.

	// Time to Heal!
	if (user.blood_volume > 0)
		to_chat(user, "<span class='warning'>Your vampiric blood sets itself to work repairing your body!</span>")
		user.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	// Values
	var/coffinnotice = 0	// Display Message: Not in Coffin!
	var/healingnotice = 0	// Display Message: Healing Stopped/Started
	var/healingcomplete = 0	// Did I complete my healing? Or was I brought out of death by outside means?
	var/tickerupdate = 20	// Every now and then, let the player know he's still playing the game.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = usr.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	while (!healingcomplete && bloodsuckerdatum)// Just keep going while we're a vampire.

		// Destroyed?
		if (!user)
			//to_chat(user, "<span class='userdanger'>You have been destroyed!</span>")
			break

		// Staking Cancels
		if (user.AmStaked())
			to_chat(user, "<span class='userdanger'>The stake in your heart abruptly ends your sleep! You will remain dead until it is removed.</span>")
			if (user.stat < DEAD)
				user.death(0) // Kill me if alive.
			healingcomplete = 0
			break

		// Update Message
		if (user.blood_volume > 0 || insideCoffin)
			tickerupdate --
			if (tickerupdate <= 0)
				tickerupdate = 30
				var/torpormessage = pick("Dreams of the abyss...","Blackness clouds your dreams...","Bats, and death...","Your black soul, exposed...","Eyes, watching, always watching...","Cruel hunger and despair...",\
				"Cobwebs...","What's that...!","Siren calls from the other side...","Soulless, hollow...","Thousands of miles of barren nothing...")
				to_chat(user, "<i>[torpormessage]</i>")

		// Healed Enough to SLEEP instead of DIE?
		if (user.stat == DEAD && user.can_be_revived())
			user.fakedeath("torpor") // user.status_flags |= FAKEDEATH //play dead
			user.revive(0)
			to_chat(user, "<span class='warning'>You crawl back from the brink of Final Death. You will remain torpid until your wounds recover.</span>")

		sleep (10) // Sleep 1.5 second...

		// Not Dead Anymore? Break WITHOUT healing complete.
		if (!(user.has_trait(TRAIT_FAKEDEATH) || user.stat == DEAD))
			break

		// Not able to heal anymore? Hard abort!
		if (!user.HaveBloodsuckerBodyparts())
			to_chat(user, "<span class='warning'>You are suddenly incapable of regenerating any further!</span>")
			//end_power(null, null, 0) // This ends the power, but without altering anything but the ICON and the ACTIVE status.
			return;

		// WARNING Not in Coffin!
		insideCoffin = istype(user.loc, /obj/structure/closet/coffin)
		if (insideCoffin && !coffinnotice)//notice //warning
			to_chat(user, "<span class='notice'>You are sleeping within a Coffin. You will heal at an accelerated rate, and this will cost you no blood.</span>")
			coffinnotice = 1
		else if (!insideCoffin && coffinnotice)
			to_chat(user, "<span class='warning'>You are no longer sleeping within a Coffin.</span>")
			coffinnotice = 0

		// WARNING: Stopped Healing
		if (user.blood_volume <= 0 && !healingnotice)
			healingnotice = 1
			to_chat(user, "<span class='warning'>You've run out of blood before your body was repaired. Your healing has slowed to a crawl.</span>")
			continue
		else if (user.blood_volume > 0 && healingnotice)
			to_chat(user, "<span class='notice'>Fresh blood enters your system. Your healing accelerates.</span>")
			user.playsound_local(null, 'sound/effects/singlebeat.ogg', 50, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
			healingnotice = 0

		// Heal: Basic
		if (bloodsuckerdatum.handle_healing_active(insideCoffin ? 5 : 3, insideCoffin ? 0 : 0.5, TRUE) != FALSE) // Did we heal or FAIL? Then continue to next tick until we're done healing.
			continue

		// Heal: Advanced
		if (bloodsuckerdatum.handle_healing_torpid() != FALSE) // Did we heal a limb or organ?
			continue

		// Wait til owner comes back...
		if (!bloodsuckerdatum.owner || !bloodsuckerdatum.owner.key)
			continue

		// Level Up?
		if ((world.time > bloodsuckerdatum.nextLevelTick) && insideCoffin)
			// Not MY Coffin...
			if (bloodsuckerdatum.coffin != user.loc)
				var/failmsg = "You are unable to thicken your blood and advance to the next Rank without sleeping in your claimed coffin."
				if (!bloodsuckerdatum.coffin)
					failmsg += " Claim a coffin by desecrating one with your blood (in a safe location)."
				to_chat(user, "<EM><span class='warning'>[failmsg]</span></EM>")
			else
				bloodsuckerdatum.LevelUp()
				continue // In case you took damage during the pause, let's do one more sweep.

		// No damage. Break!
		to_chat(user, "<span class='notice'>You rise again!</span>")
		user.tod = null

		// HEAL UP: Taken from fully_heal in living.dm
		user.setToxLoss(0, 0) //zero as second argument not automatically call updatehealth().
		user.setOxyLoss(0, 0)
		user.setCloneLoss(0, 0)
		user.setBrainLoss(0)
		user.setStaminaLoss(0, 0)
		user.SetUnconscious(0, FALSE)
		user.set_disgust(0)
		user.SetStun(0, FALSE)
		user.SetKnockdown(0, FALSE)
		user.SetSleeping(0, FALSE)
		user.radiation = 0
		user.set_blindness(0)
		user.set_blurriness(0)
		user.set_eye_damage(0)
		user.cure_nearsighted()
		user.heal_overall_damage(100000, 100000, 0, 0, 1) //heal brute and burn dmg on both organic and robotic limbs, and update health right away.
		user.ExtinguishMob()
		user.update_canmove()
		user.update_body()
		//user.revive(1) // A FULL heal. Takes care of all the little things that blood may have missed healing.

		break


	// DONE! Wipe fake death.
	cancel_spell(user)


// ABORT SPELL //	// USE THIS WHEN FAILING MID-SPELL. NOT THE SAME AS DISABLING BY CLICKING BUTTON //
/obj/effect/proc_holder/spell/bloodsucker/torpidsleep/cancel_spell(mob/living/user = usr, dispmessage="")
	user.cure_fakedeath("torpor") // user.status_flags &= ~(FAKEDEATH) // Remove it

	..() // Set Active FALSE



