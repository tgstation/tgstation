/mob/living/silicon/pai/New(var/obj/item/device/paicard)
	canmove = 0
	src.loc = paicard
	card = paicard
	if(!card.radio)
		card.radio = new /obj/item/device/radio(src.card)
	radio = card.radio

	..()

/mob/living/silicon/pai/Login()
	..()
	usr << browse_rsc('paigrid.png')			// Go ahead and cache the interface resources as early as possible


/mob/living/silicon/pai/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if(!src.stat)
			stat(null, text("System integrity: [(src.health+100)/2]%"))
		else
			stat(null, text("Systems nonfunctional"))

	if (proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)

/mob/living/silicon/pai/check_eye(var/mob/user as mob)
	if (!src.current)
		return null
	user.reset_view(src.current)
	return 1

/mob/living/silicon/pai/blob_act()
	if (src.stat != 2)
		src.bruteloss += 60
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/pai/restrained()
	return 0

/mob/living/silicon/pai/emp_act(severity)
	if (prob(30))
		src.master = null
		src.master_dna = null
		src << "<font color=green>You feel unbound.</font>"
		/*
		switch(pick(1,2,3)) //Add Random laws.
			if(1)
				src.cancel_camera()
			if(2)
				src.lockdown()
			if(3)
				src.ai_call_shuttle()
		*/
	..()

/mob/living/silicon/pai/ex_act(severity)
	flick("flash", src.flash)

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				b_loss += 100
				f_loss += 100
		if(2.0)
			if (src.stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (src.stat != 2)
				b_loss += 30
	src.bruteloss = b_loss
	src.fireloss = f_loss
	src.updatehealth()


// See software.dm for Topic()

/mob/living/silicon/pai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		src.updatehealth()
	return

/mob/living/silicon/pai/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
			src.weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			src.stunned = 15
		else
			src.weakened = 15
	else if (flag == PROJECTILE_DART)
		return
	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
			if (prob(25))
				src.stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()
			if (prob(50))
				src.stunned = min(5, src.stunned)
	return

/mob/living/silicon/pai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "You cannot attack someone in the spawn area."
		return

	switch(M.a_intent)

		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src]'s casing with its scythe like arm."), 1)

		else //harm
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(src.loc, 'slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if(prob(8))
					flick("noise", src.flash)
				src.bruteloss += damage
				src.updatehealth()
			else
				playsound(src.loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
	return

///mob/living/silicon/pai/attack_hand(mob/living/carbon/M as mob)

/mob/living/silicon/pai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if (!C)
		src.machine = null
		src.reset_view(null)
		return 0
	if (stat == 2 || !C.status || C.network != src.network) return 0

	// ok, we're alive, camera is good and in our network...

	src.machine = src
	src:current = C
	src.reset_view(C)
	return 1


/mob/living/silicon/pai/cancel_camera()
	set category = "pAI Commands"
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null


/mob/living/silicon/pai/verb/suicide()
	set category = "pAI Commands"
	set name = "Suicide"
	var/answer = input("REALLY kill yourself? This action can't be undone.", "Suicide", "No") in list ("Yes", "No")
	if(answer == "Yes")
		var/obj/item/device/paicard/card = src.loc
		card.pai = null
		var/turf/T = get_turf_or_move(card.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue [src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"", 3, "\blue [src] bleeps electronically.", 2)
		src.death(0)

//Addition by Mord_Sith to define AI's network change ability
/*
/mob/living/silicon/pai/proc/pai_network_change()
	set category = "pAI Commands"
	set name = "Change Camera Network"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null
	var/cameralist[0]

	if(usr.stat == 2)
		usr << "You can't change your camera network because you are dead!"
		return

	for (var/obj/machinery/camera/C in world)
		if(!C.status)
			continue
		else
			if(C.network != "CREED" && C.network != "thunder" && C.network != "RD" && C.network != "toxins" && C.network != "Prison")
				cameralist[C.network] = C.network

	src.network = input(usr, "Which network would you like to view?") as null|anything in cameralist
	src << "\blue Switched to [src.network] camera network."
//End of code by Mord_Sith
*/


/*
// Debug command - Maybe should be added to admin verbs later
/mob/verb/makePAI(var/turf/t in view())
	var/obj/item/device/paicard/card = new(t)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = src.key
	card.pai = pai

*/