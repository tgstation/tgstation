

/datum/action/bloodsucker/targeted/brawn
	name = "Brawn"//"Cellular Emporium"
	desc = "Snap restraints with ease, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	bloodcost = 8
	cooldown = 100
	target_range = 1
	power_activates_immediately = TRUE
	message_Trigger = ""//"Whom will you subvert to your will?"
	bloodsucker_can_buy = TRUE
	// Level Up
	var/upgrade_canLocker = FALSE
	var/upgrade_canDoor = FALSE

/datum/action/bloodsucker/targeted/brawn/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	// Break Out of Restraints! (And then cancel)
	if (CheckBreakRestraints())
		PowerActivatedSuccessfully() // PAY COST! BEGIN COOLDOWN!DEACTIVATE!
		return FALSE
	// Throw Off Attacker! (And then cancel)
	if (CheckEscapePuller())
		PowerActivatedSuccessfully() // PAY COST! BEGIN COOLDOWN!DEACTIVATE!
		return FALSE
	return TRUE


/datum/action/bloodsucker/targeted/brawn/CheckValidTarget(atom/A)
	return isliving(A) || istype(A, /obj/machinery/door) || istype(A, /obj/structure/closet)



/datum/action/bloodsucker/targeted/brawn/CheckCanTarget(mob/living/target,display_error)
	// Check: Self
	if (target == owner)
		return FALSE
	// Target Type: Living
	if (isliving(target))
		return TRUE
	// Target Type: Door
	else if (upgrade_canDoor && istype(target, /obj/machinery/door))
		return TRUE
		// Target Type: Closet
	else if (upgrade_canLocker && istype(target, /obj/structure/closet))
		return TRUE

	return FALSE // yes, FALSE! You failed if you got here! BAD TARGET


/datum/action/bloodsucker/targeted/brawn/FireTargetedPower(atom/A)
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up ClickWithPower(), so that we can unlock the power when it's done.

	var/mob/living/carbon/target = A
	var/mob/living/user = owner

	// Target Type: Mob
	if (isliving(target))
		var/mob/living/carbon/user_C = user
		var/hitStrength = user_C.dna.species.punchdamagehigh * 1.25 + 2

		// Knockback!
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		var/powerlevel = 1 + bloodsuckerdatum.vamplevel
		if (rand(10 + powerlevel) >= 5)
			target.visible_message("<span class='danger'>[user] has knocked [target] down!</span>", \
							  "<span class='userdanger'>[user] has knocked you down!</span>", null, COMBAT_MESSAGE_RANGE)

			target.Knockdown(rand(10, 10 * powerlevel))
			// Chance of KO
			if (rand(5 + powerlevel) >= 5  && target.stat <= UNCONSCIOUS)
				target.Unconscious(40)

		// Attack!
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		target.apply_damage(hitStrength, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(owner, target)
		//new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)
		var/turf/T = get_ranged_target_turf(target, send_dir, (hitStrength / 4))
		owner.newtonian_move(send_dir)
		target.throw_at(T, (hitStrength / 4), 1, owner)

	// Target Type: Door
	else if (upgrade_canDoor && istype(target, /obj/machinery/door))
		playsound(get_turf(usr), 'sound/machines/airlock_alien_prying.ogg', 40, 1, -1)
		if (do_mob(usr,target,25))
			var/obj/machinery/door/D = target
			if (D.Adjacent(user))
				to_chat(user, "<span class='notice'>You prepare to tear open [D].</span>")
				user.Stun(10)
				user.do_attack_animation(D, ATTACK_EFFECT_SMASH)
				playsound(get_turf(D), 'sound/effects/bang.ogg', 30, 1, -1)
				D.open(2) // open(2) is like a crowbar or jaws of life.

	// Target Type: Closet
	else if (upgrade_canLocker && istype(target, /obj/structure/closet))
		playsound(get_turf(usr), 'sound/machines/airlock_alien_prying.ogg', 40, 1, -1)
		if (do_mob(usr,target,25))
			var/obj/structure/closet/C = target
			to_chat(user, "<span class='notice'>You prepare to tear open the [C].</span>")
			user.Stun(10)
			user.do_attack_animation(C, ATTACK_EFFECT_SMASH)
			playsound(get_turf(C), 'sound/effects/bang.ogg', 30, 1, -1)
			C.bust_open()


/datum/action/bloodsucker/targeted/brawn/proc/CheckBreakRestraints()

	if (!owner.restrained() || !iscarbon(owner))
		return FALSE

	// (NOTE: Just like biodegrade.dm, we only remove one thing per use //

	// Destroy Cuffs
	var/mob/living/carbon/user_C = owner
	//message_admins("DEBUG3: attempt_cast() [name] / [user_C.handcuffed] ")
	if(user_C.handcuffed)
		var/obj/O = user_C.get_item_by_slot(SLOT_HANDCUFFED)
		if(istype(O))
			user_C.visible_message("<span class='warning'>[user_C] attempts to remove [O]!</span>", \
								 "<span class='warning'>You snap [O] like it's nothing!</span>")
			user_C.clear_cuffs(O,TRUE)
			playsound(get_turf(usr), 'sound/effects/grillehit.ogg', 80, 1, -1)
			return TRUE

	// Destroy Straightjacket
	if (ishuman(owner))
		var/mob/living/carbon/human/user_H = owner
		if(user_H.wear_suit && user_H.wear_suit.breakouttime)
			var/obj/item/clothing/suit/S = user_H.get_item_by_slot(SLOT_WEAR_SUIT)
			if(istype(S))
				user_C.visible_message("<span class='warning'>[user_C] attempts to remove [S]!</span>", \
						 			"<span class='warning'>You rip through [S] like it's nothing!</span>")
				user_C.clear_cuffs(S,TRUE)
				playsound(get_turf(usr), 'sound/effects/grillehit.ogg', 80, 1, -1)
				return TRUE
	return FALSE

/datum/action/bloodsucker/targeted/brawn/proc/CheckEscapePuller()
	if (!owner.pulledby || owner.pulledby.grab_state <= GRAB_PASSIVE)
		return FALSE
	playsound(get_turf(owner.pulledby), 'sound/effects/woodhit.ogg', 75, 1, -1)
	if (iscarbon(owner.pulledby))
		var/mob/living/carbon/C = owner.pulledby
		C.Knockdown(60)
	var/send_dir = get_dir(owner, owner.pulledby)
	new /datum/forced_movement(owner.pulledby, get_ranged_target_turf(owner.pulledby, send_dir, 2), 1, FALSE)
	owner.visible_message("<span class='warning'>[owner] tears free of [owner.pulledby]'s grasp!</span>", \
			 			"<span class='warning'>You shrug off [owner.pulledby]'s grasp!</span>")
	owner.pulledby = null
	return TRUE
