


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//obj/effect/proc_holder/spell/targeted/touch/feed
/obj/effect/proc_holder/spell/bloodsucker/feed
	name = "Feed"
	desc = "Draw the heartsblood of the living."
	amToggleable = TRUE
	action_icon_state = "power_feed"				// State for that image inside icon

	//charge_max = 10


// CAST CHECK //	// USE THIS WHEN CLICKING ON THE ICON //
/obj/effect/proc_holder/spell/bloodsucker/feed/cast_check(skipcharge = 0,mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(!..())// DEFAULT CHECKS
		return 0
	// No Target
	if (!user.pulling || !ismob(user.pulling))
		to_chat(user, "<span class='warning'>You must be grabbing a victim to feed from them.</span>")
		return 0
	// Not even living!
	if (!isliving(user.pulling) || issilicon(user.pulling))
		to_chat(user, "<span class='warning'>You may only feed from living beings.</span>")
		return 0
	// No Blood / Incorrect Target Type
	//var/mob/living/carbon/target = user.pulling
	//if (!iscarbon(user.pulling) || target.blood_volume <= 0)
	var/mob/living/target = user.pulling
	if (target.blood_volume <= 0)
		to_chat(user, "<span class='warning'>Your victim has no blood to take!</span>")
		return 0
	if (ishuman(user.pulling))
		var/mob/living/carbon/human/H = user.pulling
		if(NOBLOOD in H.dna.species.species_traits)// || user.get_blood_id() != target.get_blood_id())
			to_chat(user, "<span class='warning'>Your victim's blood is not suitable for you to take!</span>")
			return 0
	// Wearing mask
	if (user.is_mouth_covered())
		to_chat(user, "<span class='warning'>You cannot feed with your mouth covered! Remove your mask.</span>")
		return 0
	// Not in correct state
	if (user.grab_state < GRAB_AGGRESSIVE)//GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>You don't have a tight enough grip on your victim!</span>")
		return 0
	// DONE!
	return 1


// POST-CLICK TARGET //	// USE THIS TO SELECT TURF, PERSON, OR CONTAINER //  Called from Click()
/obj/effect/proc_holder/spell/bloodsucker/feed/choose_targets(mob/living/user = usr)
	var/list/targets = list()
	targets += user.pulling
	// CAST SPELL
	perform(targets, TRUE, user) // Runs: before_cast(), invocation() [say a line], playMagSound() [aka play the spell's sound], critfail(), cast() [seen BELOW], after_cast(), and updates the button icon.


// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/feed/cast(list/targets, mob/living/user = usr)
	//user = action.owner // WE DO THIS because during Frenzy, attempt_cast() cues choose_targets() which calls perform(), but perform() never sends the reference to user back to cast(). So let's just do this here.
	..() // DEFAULT

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	var/mob/living/target = targets[1] 	//var/mob/living/carbon/target = targets[1]

	// Initial Wait
	to_chat(user, "<span class='warning'>You pull [target] close to you and draw out your fangs...</span>")
	do_mob(user, target, 10)//sleep(10)
	if (!user.pulling || !target) // Cancel. They're gone.
		cancel_spell(user)
		return

	// Put target to Sleep (Bloodsuckers are immune to their own bit's sleep effect)
	if((!target.mind || !target.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)) && target.stat <= UNCONSCIOUS)
		target.Sleeping(100,0) 	  // SetSleeping() only changes sleep if the input is higher than the current value. AdjustSleeping() adds or subtracts //
		target.Unconscious(100,1)  // SetUnconscious() only changes sleep if the input is higher than the current value. AdjustUnconscious() adds or subtracts //
	if (!target.density) // Pull target to you if they don't take up space.
		target.Move(user.loc)
	sleep(5)

	if (!user.pulling || !target) // Cancel. They're gone.
		cancel_spell(user)
		return

	// Broadcast Message
	user.visible_message("<span class='warning'>[user] closes their mouth around [target]'s neck!</span>", \
						 "<span class='warning'>You sink your fangs into [target]'s neck.</span>")
	// Begin Feed Loop
	var/warning_target_inhuman = 0
	var/warning_target_dead = 0
	var/warning_full = 0
	var/warning_target_bloodvol = 99999
	//var/warning_bloodremain = 100
	bloodsuckerdatum.poweron_feed = TRUE
	while (bloodsuckerdatum && target && active)
		user.canmove = 0 // Prevents spilling blood accidentally.

		// Abort? A bloody mistake.
		if (!do_mob(user, target, 20, 0, 0, extra_checks=CALLBACK(src, .proc/continue_valid, user))) // We check "active" becuase you may have turned off your power during this do_mob.  // user / target / time / uninterruptable / show progress bar / extra checks
			// Note: For future do_mob, everything in CALLBACK after the proc is its input. just keep adding things after the comma.

			// May have disabled Feed during do_mob
			if (!active || !continue_valid(user))
				break

			to_chat(user, "<span class='warning'>Your feeding has been interrupted!</span>")
			user.visible_message("<span class='danger'>[user] is ripped from [target]'s throat. Blood sprays everywhere!</span>", \
					 			 "<span class='userdanger'>Your teeth are ripped from [target]'s throat, creating a bloody mess!</span>")
			// Deal Damage to Target (should have been more careful!)
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.bleed(30)
			playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				H.bleed_rate += 20
			target.add_splatter_floor(get_turf(target))
			user.add_mob_blood(target)
			target.add_mob_blood(target)
			target.take_overall_damage(10,0)
			target.emote("scream")

			// Lost Target & End
			cancel_spell(user)
			return
		///////////////////////////////////////////////////////////
		// 		Handle Feeding! User & Victim Effects (per tick)
		bloodsuckerdatum.handle_feed_blood(target)
		///////////////////////////////////////////////////////////
		// Done?
		if (target.blood_volume <= 0)
			to_chat(user, "<span class='notice'>You have bled your victim dry.</span>")
			break
		// Not Human?
		if (!warning_target_inhuman && !ishuman(target))
			to_chat(user, "<span class='notice'>You recoil at the taste of a lesser lifeform.</span>")
			warning_target_inhuman = 1
		// Dead Blood?
		if (!warning_target_dead && target.stat == DEAD)
			to_chat(user, "<span class='notice'>Your victim is dead. Its blood barely nourishes you.</span>")
			warning_target_dead = 1
		// Full?
		if (!warning_full && user.blood_volume >= bloodsuckerdatum.maxBloodVolume)
			to_chat(user, "<span class='notice'>You are full. Any further blood you take will be wasted.</span>")
			warning_full = 1
		// Blood Remaining? (Carbons/Humans only)
		if (iscarbon(target) && !target.AmBloodsucker(1))
			if (target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='warning'>Your victim's blood volume is fatally low!</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='warning'>Your victim's blood volume is dangerously low.</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='notice'>Your victim's blood is at an unsafe level.</span>")
			warning_target_bloodvol = target.blood_volume // If we had a warning to give, it's been given by now.


		// END WHILE
	//sleep(20) // If we ended via normal means, end here.
	cancel_spell(user)
	user.visible_message("<span class='warning'>[user] unclenches their teeth from [target]'s neck.</span>", \
						 "<span class='warning'>You retract your fangs and release [target] from your bite.</span>")


// ABORT SPELL //	// USE THIS WHEN FAILING MID-SPELL. NOT THE SAME AS DISABLING BY CLICKING BUTTON //
/obj/effect/proc_holder/spell/bloodsucker/feed/cancel_spell(mob/living/user = usr, dispmessage="")
	var/mob/living/L = user
	L.update_canmove()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (bloodsuckerdatum)
		bloodsuckerdatum.poweron_feed = FALSE

	..() // Set Active FALSE


// CONTINUE CHECK //	// USE THIS WITH do_mob()
/obj/effect/proc_holder/spell/bloodsucker/feed/continue_valid(mob/living/user = usr)
	//to_chat(user, "<span class='warning'>DEBUG: continue_valid() [user] / [active] / [user.mind]</span>")
	// Are we Active? Have a Mind? Still Bloodsucker? Continue!
	return active && user.mind && user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)





