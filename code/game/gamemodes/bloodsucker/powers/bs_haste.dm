/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/effect/proc_holder/spell/bloodsucker/haste
	name = "Immortal Haste"
	desc = "Select a person or location to sprint there in the blink of an eye. Your target may be knocked to the floor."// While active, your running speed will also increase."
	bloodcost = 5
	//bloodcost_constant = 1
	charge_max = 50
	amToggleable = TRUE
	amTargetted = TRUE
	action_icon_state = "power_speed"				// State for that image inside icon
	targetmessage_ON =  "<span class='notice'>Your speed is supernaturally accelerated. Choose where you'd like to sprint.</span>"
	//var/haste_amount	// Remember how much we boosted haste.
	//var/prev_movement
	// NOTE: STAY ON UNTIL DISABLED?? Don't disable like ExpelBlood
 	// Affect species:  S.speedmod = -1

	// MUST BE STANDING to use (no floating, not sideways, not grabbed)

/obj/effect/proc_holder/spell/bloodsucker/haste/can_target(atom/A)//mob/living/target)
	if (!..())
		return 0

	var/atom/target = A
	//var/datum/antagonist/bloodsucker/bloodsuckerdatum = usr.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// REMEMBER: We return 1 if we want to go on to the "Cast" portion. That means targetting turf should NOT continue.

	// Target Self
	if(target == usr)
		return 0
	// Target Type: Mob
	if (ismob(target))
		return 1
	// Target Type: Turf
	if (isturf(target))
		return 1

	return 0


// ATTEMPT ENTIRE CASTING OF SPELL //
/obj/effect/proc_holder/spell/bloodsucker/haste/attempt_cast(mob/living/user = usr) // This is done so that Frenzy can try to Feed (usr is EMPTY if called automatically)
	if (!..())  // DEFAULT
		return
	// We attempted to cast and succeeded! Player is now armed and ready to click.

	// No further abilities if not human.
	if (!ishuman(user))
		return

	// Set Haste Amount
	//haste_amount = 1
	//var/mob/living/carbon/human/H = user
	//H.dna.species.speedmod -= haste_amount



// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/haste/cast(list/targets, mob/living/user = usr)
	..() // DEFAULT

	var/atom/target = targets[1]
	//var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Spend Blood
	pay_blood_cost()

	// Clear Variables
	user.pulling = null


	// I am now "Flying"
	//prev_movement = movement_type
	//movement_type = FLYING

	cast_effect()
	user.canmove = FALSE 	// Temp movement freeze (so you can't cancel your dash)

	walk_to(user, target, 0, 0.05, 20) // NOTE: this runs in the background! to cancel it, you need to use walk(owner.current,0), or give them a new path.
	var/safety = 0
	while(get_turf(user) != target && get_turf(user) != get_turf(target) && safety < 20 && !(isliving(target) && target.Adjacent(user)))
		sleep(1)
		safety += 1
		// Knockback on people we pass!
		var/mob/living/newtarget = locate(/mob/living) in oview(1, user)
		if (newtarget && newtarget != target && !newtarget.IsKnockdown())
			playsound(get_turf(newtarget), "sound/weapons/punch[rand(1,4)].ogg", 20, 1, -1)
			if (rand(0,2) == 0)
				newtarget.Knockdown(10)

	//Knockdown Target!
	if (isliving(target) && target.Adjacent(user))
		var/mob/living/M = target
		//user.pulling = M
		//user.grab_state = max(owner.current.grab_state,GRAB_AGGRESSIVE)
		playsound(get_turf(M), "sound/weapons/punch[rand(1,4)].ogg", 25, 1, -1)
		// Knockback!
		M.visible_message("<span class='danger'>[user] has knocked [M] down!</span>", \
						  "<span class='userdanger'>[user] has knocked [M] down!</span>", null, COMBAT_MESSAGE_RANGE)
		M.Knockdown(rand(10,20))

	//while (
	user.update_canmove()

	//movement_type = prev_movement

	// Done
	cancel_spell(user)





// END SPELL //	// WHEN A SPELL COMES TO AN END, NO MATTER HOW IT HAPPENED.
/obj/effect/proc_holder/spell/bloodsucker/haste/end_active_spell(mob/living/user = usr, dispmessage="")
	..()

	// Restore Speed
	//var/mob/living/carbon/human/H = user
	//H.dna.species.speedmod += haste_amount
	//haste_amount = 0 // Reset just in case.


/obj/effect/proc_holder/spell/bloodsucker/haste/cast_effect(mob/living/user = usr)
	playsound(get_turf(user), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
