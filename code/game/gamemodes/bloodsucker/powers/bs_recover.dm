/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/effect/proc_holder/spell/bloodsucker/recover
	name = "Preternatural Recovery"
	desc = "With uncanny grace, recover from stun or fall. If grappled, you'll throw your attacker to the ground."
	bloodcost = 10
	charge_max = 20
	amToggleable = FALSE
	stat_allowed = CONSCIOUS
	action_icon_state = "power_recover"				// State for that image inside icon
	//amTargetted = TRUE
	//targetmessage_ON =  "<span class='notice'>You open your wrist. Choose what, or whom, will receive your blood.</span>"
	//targetmessage_OFF = "<span class='notice'>The wound on your wrist heals instantly.</span>"

	// NOTE: STAY ON UNTIL DISABLED?? Don't disable like ExpelBlood



	// CAST CHECK //	// USE THIS WHEN CLICKING ON THE ICON //
/obj/effect/proc_holder/spell/bloodsucker/recover/cast_check(skipcharge = 0,mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(!..())// DEFAULT CHECKS
		return 0
	// No Target
	if (user.getStaminaLoss() <= 0 && !user.IsStun() && !user.IsKnockdown() && !user.pulledby)
		to_chat(user, "<span class='warning'>You must currently be grabbed or stunned.</span>")
		return 0
	return 1


// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/recover/cast(list/targets, mob/living/user = usr) 		// NOTE: Called from perform() in /proc_holder/spell
	..() // DEFAULT

	// Spend Blood
	pay_blood_cost()

	// Throw away grappler.
	if (user.pulledby && iscarbon(user.pulledby))
		var/mob/living/carbon/C = user.pulledby
		playsound(get_turf(C), 'sound/effects/woodhit.ogg', 75, 1, -1)
		C.Knockdown(60)
		var/send_dir = get_dir(user, C)
		new /datum/forced_movement(C, get_ranged_target_turf(C, send_dir, 2), 0.5, FALSE)
		user.visible_message("<span class='danger'>[user] has knocked [C] down!</span>", \
		 			 		 "<span class='danger'>You shake off [C]'s hold over you!</span>", null, COMBAT_MESSAGE_RANGE)
		user.pulledby = null
	else
		to_chat(user, "<span class='notice'>You leap to your feet, fully recovered!</span>")

	// Restore Stats
	user.setStaminaLoss(0, 0)
	user.SetStun(0, 0)
	user.SetKnockdown(0, 0)
	user.stuttering = 0

	//user.SetUnconscious(0, 0)
	user.update_canmove()

	//owner.current.spin(7, 1)
	//cast_effect(user)


	return


// CAST EFFECT //	// General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
///obj/effect/proc_holder/spell/bloodsucker/recover/cast_effect(mob/living/user = usr)
//	return
