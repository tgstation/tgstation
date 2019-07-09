

/datum/action/bloodsucker/targeted/trespass
	name = "Trespass"
	desc = "Become mist and advance two tiles in one direction, ignoring all obstacles except for walls. Useful for skipping past doors and barricades."
	button_icon_state = "power_tres"

	bloodcost = 10
	cooldown = 60
	amToggle = FALSE
	//target_range = 2

	bloodsucker_can_buy = TRUE
	must_be_capacitated = FALSE
	can_be_immobilized = TRUE

	var/turf/target_turf		// We need to decide where we're going based on where we clicked. It's not actually the tile we clicked.

/datum/action/bloodsucker/targeted/trespass/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	if(owner.notransform || !get_turf(owner))
		return FALSE

	return TRUE


/datum/action/bloodsucker/targeted/trespass/CheckValidTarget(atom/A)
	// Can't target my tile
	if (A == get_turf(owner) || get_turf(A) == get_turf(owner))
		return FALSE

	return TRUE //  All we care about is destination. Anything you click is fine.


/datum/action/bloodsucker/targeted/trespass/CheckCanTarget(atom/A, display_error)
	// NOTE: Do NOT use ..()! We don't want to check distance or anything.

	// Get clicked tile
	var/final_turf = isturf(A) ? A : get_turf(A)

	// Are either tiles WALLS?
	var/turf/from_turf = get_turf(owner)
	var/this_dir // = get_dir(from_turf, target_turf)
	for (var/i=1 to 2)
		// Keep Prev Direction if we've reached final turf
		if (from_turf != final_turf)
			this_dir = get_dir(from_turf, final_turf) // Recalculate dir so we don't overshoot on a diagonal.
		from_turf = get_step(from_turf, this_dir)
		// ERROR! Wall!
		if (iswallturf(from_turf))
			if (display_error)
				var/wallwarning = (i == 1) ? "in the way" : "at your destination"
				to_chat(owner, "<span class='warning'>There is a solid wall [wallwarning].</span>")
			return FALSE
	// Done
	target_turf = from_turf

	return TRUE


/datum/action/bloodsucker/targeted/trespass/FireTargetedPower(atom/A)
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up ClickWithPower(), so that we can unlock the power when it's done.

	// Find target turf, at or below Atom
	var/mob/living/carbon/user = owner
	var/turf/my_turf = get_turf(owner)

	user.visible_message("<span class='warning'>[user]'s form dissipates into a cloud of mist!</span>", \
					 	 "<span class='notice'>You disspiate into formless mist.</span>")


	// Effect Origin
	playsound(get_turf(owner), 'sound/magic/summon_karp.ogg', 60, 1)
	var/datum/effect_system/steam_spread/puff = new /datum/effect_system/steam_spread/()
	puff.effect_type = /obj/effect/particle_effect/smoke/vampsmoke
	puff.set_up(3, 0, my_turf)
	puff.start()

	var/mist_delay = max(5, 20 - level_current * 2.5) // Level up and do this faster.

	// Freeze Me
	user.next_move = world.time + mist_delay
	user.Immobilize(mist_delay, ignore_canstun = TRUE)
	user.notransform = TRUE
	user.density = 0
	var/invis_was = user.invisibility
	user.invisibility = INVISIBILITY_MAXIMUM

	// LOSE CUFFS
	if(user.handcuffed)
		var/obj/O = user.handcuffed
		user.dropItemToGround(O)
	if(user.legcuffed)
		var/obj/O = user.legcuffed
		user.dropItemToGround(O)

	// Wait...
	sleep(mist_delay / 2)

	// Move & Freeze
	if (isturf(target_turf))
		do_teleport(owner, target_turf, no_effects=TRUE) // in teleport.dm?
	user.next_move = world.time + mist_delay / 2
	user.Immobilize(mist_delay / 2, ignore_canstun = TRUE)

	// Wait...
	sleep(mist_delay / 2)

	// Un-Hide & Freeze
	user.dir = get_dir(my_turf, target_turf)
	user.next_move = world.time + mist_delay / 2
	user.Immobilize(mist_delay / 2, ignore_canstun = TRUE)
	user.notransform = FALSE
	user.density = 1
	user.invisibility = invis_was

	// Effect Destination
	playsound(get_turf(owner), 'sound/magic/summon_karp.ogg', 60, 1)
	puff = new /datum/effect_system/steam_spread/()
	puff.effect_type = /obj/effect/particle_effect/smoke/vampsmoke
	puff.set_up(3, 0, target_turf)
	puff.start()
