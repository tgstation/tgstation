

/datum/action/bloodsucker/targeted/brawn
	name = "Brawn"//"Cellular Emporium"
	desc = "Snap restraints with ease, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	bloodcost = 8
	cooldown = 100
	target_range = 1
	power_activates_immediately = TRUE
	message_Trigger = ""//"Whom will you subvert to your will?"
	must_be_capacitated = TRUE
	can_be_immobilized = TRUE
	bloodsucker_can_buy = TRUE
	// Level Up
	var/upgrade_canLocker = FALSE
	var/upgrade_canDoor = FALSE

/datum/action/bloodsucker/targeted/brawn/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	. = TRUE
	// Break Out of Restraints! (And then cancel)
	if (CheckBreakRestraints())
		//PowerActivatedSuccessfully() // PAY COST! BEGIN COOLDOWN!DEACTIVATE!
		. = FALSE //return FALSE
	// Throw Off Attacker! (And then cancel)
	if (CheckEscapePuller())
		//PowerActivatedSuccessfully() // PAY COST! BEGIN COOLDOWN!DEACTIVATE!
		. = FALSE //return FALSE
	// Did we successfuly use power to BREAK CUFFS and/or ESCAPE PULLER?
	// Then PAY COST!
	if (. == FALSE)
		PowerActivatedSuccessfully() // PAY COST! BEGIN COOLDOWN!DEACTIVATE!

	// NOTE: We use . = FALSE so that we can break cuffs AND throw off our attacker in one use!
	//return TRUE


/datum/action/bloodsucker/targeted/brawn/CheckValidTarget(atom/A)
	return isliving(A) || istype(A, /obj/machinery/door) || istype(A, /obj/structure/closet)



/datum/action/bloodsucker/targeted/brawn/CheckCanTarget(atom/A, display_error)
	// DEFAULT CHECKS (Distance)
	if (!..()) // Disable range notice for Brawn.
		return FALSE
	// Must outside Closet to target anyone!
	if (!isturf(owner.loc))
		return FALSE
	// Check: Self
	if (A == owner)
		return FALSE
	// Target Type: Living
	if (isliving(A))
		return TRUE
	// Target Type: Door
	else if (upgrade_canDoor && istype(A, /obj/machinery/door))
		return TRUE
	// Target Type: Closet
	else if (upgrade_canLocker && istype(A, /obj/structure/closet))
		return TRUE

	return ..() // yes, FALSE! You failed if you got here! BAD TARGET


/datum/action/bloodsucker/targeted/brawn/FireTargetedPower(atom/A)
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up ClickWithPower(), so that we can unlock the power when it's done.

	var/mob/living/carbon/target = A
	var/mob/living/user = owner

	// Target Type: Mob
	if (isliving(target))
		var/mob/living/carbon/user_C = user
		var/hitStrength = user_C.dna.species.punchdamagehigh * 1.25 + 2

		// Knockdown!
		var/powerlevel = min(7, 1 + level_current)
		if (rand(10 + powerlevel) >= 5)
			target.visible_message("<span class='danger'>[user] has knocked [target] down!</span>", \
							  "<span class='userdanger'>[user] has knocked you down!</span>", null, COMBAT_MESSAGE_RANGE)

			target.Knockdown( min(5, rand(10, 10 * powerlevel)) )
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
		var/turf/T = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(T, powerlevel, TRUE, owner)  //new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)

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

	if (!iscarbon(owner)) // || !owner.restrained()
		return FALSE

	// (NOTE: Just like biodegrade.dm, we only remove one thing per use //

	// Destroy Cuffs
	var/mob/living/carbon/user_C = owner
	//message_admins("DEBUG3: attempt_cast() [name] / [user_C.handcuffed] ")
	if(user_C.handcuffed)
		var/obj/O = user_C.get_item_by_slot(SLOT_HANDCUFFED)
		if(istype(O))
			//user_C.visible_message("<span class='warning'>[user_C] attempts to remove [O]!</span>", \
			//					 "<span class='warning'>You snap [O] like it's nothing!</span>")
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

	// Destroy Leg Cuffs
	if(user_C.legcuffed)
		var/obj/O = user_C.get_item_by_slot(SLOT_LEGCUFFED)
		if(istype(O))
			//user_C.visible_message("<span class='warning'>[user_C] attempts to remove [O]!</span>", \
			//					 "<span class='warning'>You snap [O] like it's nothing!</span>")
			user_C.clear_cuffs(O,TRUE)
			playsound(get_turf(usr), 'sound/effects/grillehit.ogg', 80, 1, -1)
			return TRUE

	return FALSE

/datum/action/bloodsucker/targeted/brawn/proc/CheckEscapePuller()
	if (!owner.pulledby)// || owner.pulledby.grab_state <= GRAB_PASSIVE)
		return FALSE

	var/mob/M = owner.pulledby
	var/pull_power = M.grab_state
	playsound(get_turf(M), 'sound/effects/woodhit.ogg', 75, 1, -1)

	// Knock Down (if Living)
	if (isliving(M))
		var/mob/living/L = M
		L.Knockdown(pull_power * 10 + 20)

	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, M)
	var/turf/T = get_ranged_target_turf(M, send_dir, pull_power)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	M.throw_at(T, pull_power, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.


	// /proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	log_combat(owner, M, "used Brawn power")

	owner.visible_message("<span class='warning'>[owner] tears free of [M]'s grasp!</span>", \
			 			"<span class='warning'>You shrug off [M]'s grasp!</span>")
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE
