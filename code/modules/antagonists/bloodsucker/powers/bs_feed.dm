




/*/obj/effect/proc_holder/spell/feed
	desc = "Drink the heartsblood of the living."
	school = "vampiric"
	charge_max = 0 // NOTE: Bloodsucker Powers do not use charges. Blood is the currency used.
	clothes_req = 0
	still_recharging_msg = "That gift is not ready yet."*/

/datum/action/bloodsucker/feed
	name = "Feed"
	desc = "Draw the heartsblood of the living.<br><b>Passive:</b> Feed silently and unnoticed by your victim.<br><b>Aggressive: </b>Subdue your target quickly."
	button_icon_state = "power_feed"

	bloodcost = 0
	cooldown = 30
	amToggle = TRUE
	//var/datum/cellular_emporium/cellular_emporium
	bloodsucker_can_buy = TRUE

/datum/action/bloodsucker/feed/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	if (!owner.pulling || !ismob(owner.pulling))
		to_chat(owner, "<span class='warning'>You must be grabbing a victim to feed from them.</span>")
		return FALSE
	// Not even living!
	if (!isliving(owner.pulling) || issilicon(owner.pulling))
		to_chat(owner, "<span class='warning'>You may only feed from living beings.</span>")
		return FALSE
	// No Blood / Incorrect Target Type
	//var/mob/living/carbon/target = owner.pulling
	//if (!iscarbon(owner.pulling) || target.blood_volume <= 0)
	var/mob/living/target = owner.pulling
	if (target.blood_volume <= 0)
		to_chat(owner, "<span class='warning'>Your victim has no blood to take.</span>")
		return FALSE
	if (ishuman(owner.pulling))
		var/mob/living/carbon/human/H = owner.pulling
		if(NOBLOOD in H.dna.species.species_traits)// || owner.get_blood_id() != target.get_blood_id())
			to_chat(owner, "<span class='warning'>Your victim's blood is not suitable for you to take.</span>")
			return FALSE
	// Wearing mask
	var/mob/living/L = owner
	if (L.is_mouth_covered())
		to_chat(owner, "<span class='warning'>You cannot feed with your mouth covered! Remove your mask.</span>")
		return FALSE
	// Not in correct state
	if (owner.grab_state < GRAB_PASSIVE)//GRAB_AGGRESSIVEs)
		to_chat(owner, "<span class='warning'>You aren't grabbing anyone!</span>")
		return FALSE
	// Subtle targets MUST be carbon!
	if (owner.grab_state < GRAB_AGGRESSIVE && !iscarbon(owner.pulling))//GRAB_AGGRESSIVEs)
		to_chat(owner, "<span class='warning'>Lesser beings require a tighter grip!</span>")
		return FALSE

	// DONE!
	return TRUE



//	NOTE: QUIET VS LOUD FEEDING!!!
/datum/action/bloodsucker/feed/ActivatePower()
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up Activate(), so Deactivate() can happen after.

	var/mob/living/target = owner.pulling
	var/mob/living/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Am I SECRET or LOUD? It stays this way the whole time! I must END IT to try it the other way.
	var/amSilent = owner.grab_state == GRAB_PASSIVE

	// Initial Wait
	if (amSilent)
		to_chat(user, "<span class='notice'>You lean quietly toward [target] and secretly draw out your fangs...</span>")
	else
		to_chat(user, "<span class='warning'>You pull [target] close to you and draw out your fangs...</span>")
	if (!do_mob(user, target, (amSilent ? 60 : 30),0,1,extra_checks=CALLBACK(src, .proc/ContinueActive, user, target)))//sleep(10)
		to_chat(user, "<span class='warning'>Your feeding was interrupted.</span>")
		//DeactivatePower(user,target)
		return

	// Put target to Sleep (Bloodsuckers are immune to their own bite's sleep effect)
	if (!amSilent)
		if((!target.mind || !target.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)) && target.stat <= UNCONSCIOUS)
			ApplyVictimEffects(target)	// Sleep, paralysis, immobile, unconscious, and mute
			// Wait, then Cancel if Invalid
			sleep(5)
			if (!ContinueActive(user,target)) // Cancel. They're gone.
				//DeactivatePower(user,target)
				return
		// Pull Target Close
		if (!target.density) // Pull target to you if they don't take up space.
			target.Move(user.loc)

	// Broadcast Message
	if (amSilent)
		var/deadmessage = target.stat == DEAD ? "" : "[target.p_they(TRUE)] looks dazed, and will not remember this."
		user.visible_message("<span class='notice'>[user] puts [target]'s wrist up to [user.p_their()] mouth.</span>", \
						 	 "<span class='notice'>You slip your fangs into [target]'s wrist. [deadmessage]</span>", \
						 	 vision_distance = 5, ignored_mob=target) // Only people who AREN'T the target will notice this action.
	else				// /atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob)
		user.visible_message("<span class='warning'>[user] closes [user.p_their()] mouth around [target]'s neck!</span>", \
						 "<span class='warning'>You sink your fangs into [target]'s neck.</span>")

	// Begin Feed Loop
	var/warning_target_inhuman = FALSE
	var/warning_target_dead = FALSE
	var/warning_full = FALSE
	var/warning_target_bloodvol = 99999
	var/amount_taken = 0
	var/was_alive = target.stat < DEAD && ishuman(target)
	// Activate Effects
	//target.add_trait(TRAIT_MUTE, "bloodsucker_victim")  // <----- Make mute a power you buy?

	// FEEEEEEEEED!!! //
	bloodsuckerdatum.poweron_feed = TRUE
	while (bloodsuckerdatum && target && active)
		user.mobility_flags &= ~MOBILITY_MOVE // user.canmove = 0 // Prevents spilling blood accidentally.

		// Abort? A bloody mistake.
		if (!do_mob(user, target, 20, 0, 0, extra_checks=CALLBACK(src, .proc/ContinueActive, user, target)))
			// May have disabled Feed during do_mob
			if (!active || !ContinueActive(user))
				break

			if (amSilent)
				to_chat(user, "<span class='warning'>Your feeding has been interrupted...but [target.p_they()] didn't seem to notice you.<span>")
			else
				to_chat(user, "<span class='warning'>Your feeding has been interrupted!</span>")
				user.visible_message("<span class='danger'>[user] is ripped from [target]'s throat. [target.p_their(TRUE)] blood sprays everywhere!</span>", \
						 			 "<span class='userdanger'>Your teeth are ripped from [target]'s throat. [target.p_their(TRUE)] blood sprays everywhere!</span>")

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

			// Killed Target?
			if (was_alive)
				CheckKilledTarget(user,target)

			return

		///////////////////////////////////////////////////////////
		// 		Handle Feeding! User & Victim Effects (per tick)
		bloodsuckerdatum.HandleFeeding(target, amSilent ? 0.2 : 1)
		amount_taken += amSilent ? 0.2 : 1
		if (!amSilent)
			ApplyVictimEffects(target)	// Sleep, paralysis, immobile, unconscious, and mute
		if (amount_taken > 5 && target.stat < DEAD && ishuman(target))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood) // GOOD // in bloodsucker_life.dm

		///////////////////////////////////////////////////////////
		// Not Human?
		if (!ishuman(target))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad) // BAD // in bloodsucker_life.dm
			if (!warning_target_inhuman)
				to_chat(user, "<span class='notice'>You recoil at the taste of a lesser lifeform.</span>")
				warning_target_inhuman = TRUE
		// Dead Blood?
		if (target.stat >= DEAD)
			if (ishuman(target))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_dead) // BAD // in bloodsucker_life.dm
			if (!warning_target_dead)
				to_chat(user, "<span class='notice'>Your victim is dead. [target.p_their(TRUE)] blood barely nourishes you.</span>")
				warning_target_dead = TRUE
		// Full?
		if (!warning_full && user.blood_volume >= bloodsuckerdatum.maxBloodVolume)
			to_chat(user, "<span class='notice'>You are full. Further blood will be wasted.</span>")
			warning_full = TRUE
		// Blood Remaining? (Carbons/Humans only)
		if (iscarbon(target) && !target.AmBloodsucker(1))
			if (target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='warning'>Your victim's blood volume is fatally low!</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='warning'>Your victim's blood volume is dangerously low.</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='notice'>Your victim's blood is at an unsafe level.</span>")
			warning_target_bloodvol = target.blood_volume // If we had a warning to give, it's been given by now.
		// Done?
		if (target.blood_volume <= 0)
			to_chat(user, "<span class='notice'>You have bled your victim dry.</span>")
			break

		// Blood Gulp Sound
		owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.

	// DONE!
	//DeactivatePower(user,target)
	if (amSilent)
		to_chat(user, "<span class='notice'>You slowly release [target]'s wrist." + (target.stat == 0 ? "[target.p_their(TRUE)] face lacks expression, like you've already been forgotten.</span>" : ""))
	else
		user.visible_message("<span class='warning'>[user] unclenches their teeth from [target]'s neck.</span>", \
							 "<span class='warning'>You retract your fangs and release [target] from your bite.</span>")
	// Killed Target?
	if (was_alive)
		CheckKilledTarget(user,target)


/datum/action/bloodsucker/feed/proc/CheckKilledTarget(mob/living/user, mob/living/target)
	// Bad Vampire. You shouldn't do that.
	if (target && target.stat >= DEAD && ishuman(target))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled) // BAD // in bloodsucker_life.dm

/datum/action/bloodsucker/feed/ContinueActive(mob/living/user, mob/living/target)
	return ..()  && user.pulling && user.pulling == target // Active, and still Antag
	// NOTE: We don't check for user.pulling etc. because do_mob does this.

/datum/action/bloodsucker/feed/proc/ApplyVictimEffects(mob/living/target, powerLevel=1)
	//if (level_current >= 2)
	target.Unconscious(50,0)
	//if (level_current >= 3)
	//	target.Sleeping(100,0)

	target.Paralyze(40 + 10 * powerLevel,1)
	// NOTE: THis is based on level of power!
	if (ishuman(target))
		target.adjustStaminaLoss(2.5, forced = TRUE)// Base Stamina Damage

/datum/action/bloodsucker/feed/DeactivatePower(mob/living/user = owner, mob/living/target)
	..() // activate = FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (bloodsuckerdatum)
		bloodsuckerdatum.poweron_feed = FALSE
	//target.remove_trait(TRAIT_MUTE, "bloodsucker_victim")  // <----- Make mute a power you buy?
	user.update_mobility()
