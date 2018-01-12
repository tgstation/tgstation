/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/effect/proc_holder/spell/bloodsucker/brawn
	name = "Terrible Brawn"
	desc = "Target a door or locker to wrench it open, or target a person to throw them violently away. Can also destroy your bonds."
	bloodcost = 15
	charge_max = 80
	amToggleable = TRUE
	amTargetted = TRUE
	action_icon_state = "power_strength"				// State for that image inside icon
	targetmessage_ON =  "<span class='notice'>Your muscles surge with unholy strength.</span>"
	//targetmessage_OFF = "<span class='notice'>The wound on your wrist heals instantly.</span>"

	// NOTE: STAY ON UNTIL DISABLED?? Don't disable like ExpelBlood

	// Break Handcuffs:  biodegrade.dm (changeling)
	// Throw Someone: (spacelube)
	// Open Door: (frenzy has a pry action)

	// ON TRY BUT NO BLOOD:	Error message, Disable power!

/obj/effect/proc_holder/spell/bloodsucker/brawn/can_target(atom/A)//mob/living/target)
	if (!..())
		return 0

	var/atom/target = A
	//var/datum/antagonist/bloodsucker/bloodsuckerdatum = usr.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Out of Range
	if (!(target in range(1, get_turf(usr))))
		return 0

	// Self
	if (target == usr)
		return 0

	// Target Type: Living
	if (isliving(target))
		return 1
	// Target Type: Door
	else if (istype(target, /obj/machinery/door))
		playsound(get_turf(usr), 'sound/machines/airlock_alien_prying.ogg', 40, 1, -1)
		if (do_mob(usr,target,25))
			return 1
		// Target Type: Closet
	else if (istype(target, /obj/structure/closet))
		playsound(get_turf(usr), 'sound/machines/airlock_alien_prying.ogg', 40, 1, -1)
		if (do_mob(usr,target,25))
			return 1

	return 0
	// REMEMBER: We return 1 if we want to go on to the "Cast" portion. That means targetting turf should NOT continue.


// ATTEMPT ENTIRE CASTING OF SPELL //
/obj/effect/proc_holder/spell/bloodsucker/brawn/attempt_cast(mob/living/user = usr) // This is done so that Frenzy can try to Feed (usr is EMPTY if called automatically)
	//message_admins("DEBUG1: attempt_cast() [name] ")
	if (!..())  // DEFAULT
		return
	// We attempted to cast and succeeded! Player is now armed and ready to click.

	//message_admins("DEBUG1: attempt_cast() [name] ")

	// Attempt to break out of bonds!
	if (user.restrained() && iscarbon(user))
		 // (NOTE: Just like biodegrade.dm, we only remove one thing per use //
		//message_admins("DEBUG2: attempt_cast() [name] ")

		// Destroy Cuffs
		var/mob/living/carbon/user_C = user
		//message_admins("DEBUG3: attempt_cast() [name] / [user_C.handcuffed] ")
		if(user_C.handcuffed)
			var/obj/O = user_C.get_item_by_slot(slot_handcuffed)
			//message_admins("DEBUG3b: attempt_cast() [name] / [O] ")
			if(istype(O))
				user_C.visible_message("<span class='warning'>[user_C] attempts to remove [O]!</span>", \
									 "<span class='warning'>You snap [O] like it's nothing!</span>")
				user_C.clear_cuffs(O,TRUE)
				// Spend Blood
				pay_blood_cost()
				// That's all we get! Disable.
				cancel_spell()
				return

		// Destroy Straightjacket
		if (ishuman(user))
			var/mob/living/carbon/human/user_H = user
			//message_admins("DEBUG4: attempt_cast() [name] / [user_H.wear_suit] / ")
			if(user_H.wear_suit && user_H.wear_suit.breakouttime)
				var/obj/item/clothing/suit/S = user_H.get_item_by_slot(slot_wear_suit)
				message_admins("DEBUG4b: attempt_cast() [name] / [user_H.wear_suit.breakouttime] / [S]")
				if(istype(S))
					user_C.visible_message("<span class='warning'>[user_C] attempts to remove [S]!</span>", \
							 			"<span class='warning'>You rip through [S] like it's nothing!</span>")
					user_C.clear_cuffs(S,TRUE)
					// Spend Blood
					pay_blood_cost()
					// That's all we get! Disable.
					cancel_spell()
					return

// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/brawn/cast(list/targets, mob/living/user = usr)
	..() // DEFAULT

	var/atom/target = targets[1]
	//var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Spend Blood
	pay_blood_cost()

	// Target Type: Mob
	if (isliving(target))
		var/mob/living/M = target
		var/mob/living/carbon/user_C = user
		var/hitStrength = user_C.dna.species.punchdamagehigh * 1.25 + 2

		// Knockback!
		M.visible_message("<span class='danger'>[user] has knocked [M] down!</span>", \
						  "<span class='userdanger'>[user] has knocked [M] down!</span>", null, COMBAT_MESSAGE_RANGE)
		M.Knockdown(60)
		if (M.stat <= UNCONSCIOUS)
			M.Unconscious(40)

		// Attack!
		playsound(get_turf(M), 'sound/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(M, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = M.get_bodypart(ran_zone(M.zone_selected))
		M.apply_damage(hitStrength, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(user, M)
		new /datum/forced_movement(M, get_ranged_target_turf(M, send_dir, (hitStrength / 4)), 1, FALSE)

	// Target Type: Door
	else if (istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		if (D.Adjacent(user))
			to_chat(user, "<span class='notice'>You prepare to tear open the [D].</span>")
			user.Stun(10)
			user.do_attack_animation(D, ATTACK_EFFECT_SMASH)
			playsound(get_turf(D), 'sound/effects/bang.ogg', 30, 1, -1)
			D.open(2) // open(2) is like a crowbar or jaws of life.

				// Target Type: Closet
	else if (istype(target, /obj/structure/closet))
		var/obj/structure/closet/C = target
		to_chat(user, "<span class='notice'>You prepare to tear open the [C].</span>")
		user.Stun(10)
		user.do_attack_animation(C, ATTACK_EFFECT_SMASH)
		playsound(get_turf(C), 'sound/effects/bang.ogg', 30, 1, -1)
		C.bust_open()


	// Done
	cancel_spell(user)
