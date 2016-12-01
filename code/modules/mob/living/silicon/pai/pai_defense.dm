
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return 0

/mob/living/silicon/pai/emp_act(severity)
	take_holo_damage(severity * 25)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			cardform(force = 1)
			fullstun(30)
		if(3)
			cardform(force = 1)
			fullstun(5)

/mob/living/silicon/pai/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] pets [src]!</span>")
		playsound(loc, 'sound/weapons/tap.ogg', 50, 1, 1
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='warning'>[M] [M.attacktext] [src]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		take_holo_damage(damage)

/mob/living/silicon/pai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	switch(M.a_intent)
		if ("help")
			M.visible_message("<span class='notice'>[M] caresses [src]'s casing with its scythe like arm.</span>")
		else
			M.do_attack_animation(src)
			var/damage = rand(10, 20)
			playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			M.visible_message("<span class='warning'>[M] has slashed at [src]!</span>")
			take_holo_damage(damage)


/*
/mob/living/silicon/pai/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (loc == card) //card has been hit
		if (W.force)
			user.visible_message("<span class='warning'>[user.name] slams [W] into [src]'s card, damaging it severely!</span>")
			src.adjustBruteLoss(20)
			src.adjustFireLoss(20)
		else
			user.visible_message("<span class='info'>[user.name] taps [W] against [src]'s screen.</span>")
		..()
		return
	if (cooldown >= cooldowncap)
		return

	user.do_attack_animation(src)

	if(!W.force)
		visible_message("<span class='info'>[user.name] strikes [src] harmlessly with [W], passing clean through its holographic projection.</span>")
	else
		if (emittersFailing)
			visible_message("<span class='warning'>[user.name] strikes [src] with [W], its image stuttering and flickering wildly!! </span>")
		else
			visible_message("<span class='warning'>[user.name] strikes [src] with [W], eliciting a dire ripple throughout its holographic projection!</span>")
		cooldown = cooldown + 1
		if (prob(66))
			if(stat != 2)
				flicker_fade(rand(50, 80))
		spawn(5)
			cooldown = cooldown - 1
	return 1
/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user)
	if(stat == 2) return
	switch(user.a_intent)
		if("help")
			visible_message("<span class='notice'>[user.name] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field.</span>")
	if (user.a_intent != "help")
		visible_message("<span class='danger'>[user.name] thwaps [src] on the head.</span>")
		if (user.name == master)
			visible_message("<span class='info'>Responding to its master's touch, [src] disengages its holographic emitter, rapidly losing coherence..</span>")
			spawn(10)
				close_up()
		else
			if(prob(35))
				flicker_fade(50)
		return 1
	return

/mob/living/silicon/pai/hitby(AM as mob|obj)
	visible_message("<span class='info'>[AM] flies clean through [src]'s holographic field, causing it to stutter and warp wildly!")
	//ugh fuk u byond types
	if (istype(AM, /obj/item))
		var/obj/item/AMI = AM
		if (prob(min(85, AMI.throwforce*5)))
			flicker_fade()
	else
		if (prob(55))
			flicker_fade()
	return 1

/mob/living/silicon/pai/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class='info'>[Proj] tears cleanly through [src]'s holographic field, distorting its image horribly!!")
	if (Proj.damage >= 25)
		flicker_fade(0)
		adjustBruteLoss(rand(5, 25))
	else
		if (prob(85))
			flicker_fade(20)
	return 1

/mob/living/silicon/pai/proc/flicker_fade(var/dur = 40)
	updatehealth()
	if (emittersFailing)
		src << "<span class='boldwarning'>Your failing containment field surges at the new intrusion, searing your circuitry even more!</span>"
		src.adjustFireLoss(5)
		return
	src << "<span class='boldwarning'>The holographic containment field surrounding you is failing! Your emitters whine in protest, burning out slightly.</span>"
	src.adjustFireLoss(rand(5,15))
	last_special = world.time + rand(100,500)
	src.emittersFailing = 1
	if (health < 5)
		src << "<span class='boldwarning'>HARDWARE ERROR: EMITTERS OFFLINE</span>"
	spawn(dur)
		visible_message("<span class='danger'>[src]'s holographic field flickers out of existence!</span>")
		src.emittersFailing = 0
		close_up(1)

/mob/living/silicon/pai/Bump(AM as mob|obj) //can open doors on touch but doesn't affect anything else
	if (istype(AM, /obj/machinery/door))
		..()
	else
		return

/mob/living/silicon/pai/Bumped(AM as mob|obj) //cannot be bumped or bump other objects
	return

/mob/living/silicon/pai/Crossed(AM as mob|obj) //cannot intercept projectiles
	return

/mob/living/silicon/pai/start_pulling(var/atom/movable/AM) //cannot pull objects
	return

/mob/living/silicon/pai/show_inv(mob/user) //prevents stripping
	return

/mob/living/silicon/pai/stripPanelUnequip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your containment field stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"
	return

/mob/living/silicon/pai/stripPanelEquip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your containment field stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"
	return

//disable ignition, no need for it. however, this will card the pAI instantly.
/mob/living/silicon/pai/IgniteMob(var/mob/living/silicon/pai/P)
	src << "<span class='danger'>The intense heat from the nearby fire causes your holographic field to fail instantly, damaging your internal hardware!</span>"
	flicker_fade(0)
	return

// See software.dm for Topic()

/mob/living/silicon/pai/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return

/mob/living/silicon/pai/proc/switchCamera(var/obj/machinery/camera/C)
	if(!C)
		src.unset_machine()
		src.reset_perspective(null)
		return 0
	if(stat == DEAD || !C.status || !(src.network in C.network))
		return 0

	set_machine(src)
	current = C
	reset_perspective(C)
	return 1

/mob/living/silicon/pai/proc/unpair(var/silent = 0)
	if(!paired)
		return
	if(paired.paired != src)
		return
	machine = paired
	src.unset_machine()
	paired.paired = null
	paired.update_icon()
	if(!silent)
		src << "<span class='warning'><b>\[ERROR\]</b> Network timeout. Remote control connection to [paired.name] severed.</span>"
	paired = null
	return

/mob/living/silicon/pai/proc/pair(var/obj/machinery/P)
	if(!pairing)
		return
	if(!P)
		return
	if(P.stat & (BROKEN|NOPOWER))
		src << "<span class='warning'><b>\[ERROR\]</b> Remote device not responding to remote control handshake. Cannot establish connection.</span>"
		return
	if(!P.paiAllowed)
		src << "<span class='warning'><b>\[ERROR\]</b> Remote device does not accept remote control connections.</span>"
		return
	if(P.paired && (P.paired != src))
		P.paired.unpair(0)
	P.paired = src
	paired = P
	paired.update_icon()
	pairing = 0
	src << "<span class='info'>Handshake complete. Remote control connection established.</span>"
	return

/mob/living/silicon/pai/canUseTopic(atom/movable/M)
	return 1

// Debug command - Maybe should be added to admin verbs later
/*/mob/verb/makePAI(var/turf/t in view())
	var/obj/item/device/paicard/card = new(t)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = src.key
	card.setPersonality(pai)*/

//PAI MOVEMENT/HOLOGRAPHIC FORM
/mob/living/silicon/pai/verb/fold_out()
	set category = "pAI Commands"
	set name = "Assume Holographic Form"

	if(stat || sleeping || paralysis || weakened)
		return

	if (wiped)
		src << "\red Your holographic control processes were the first to be deleted! You can't move!"
		return

	if (!canholo)
		src << "\red Your master has not enabled your external holographic emitters! Ask nicely!"
		return

	if(src.loc != card)
		src << "\red You are already in your holographic form!"
		return

	if(world.time <= last_special)
		src << "\red You must wait before altering your holographic emitters again!"
		return

	last_special = world.time + 200

	canmove = 1
	density = 1

	//I'm not sure how much of this is necessary, but I would rather avoid issues.
	if(istype(card.loc,/mob))
		var/mob/holder = card.loc
		holder.unEquip(card)
	else if(istype(card.loc,/obj/item/device/pda))
		var/obj/item/device/pda/holder = card.loc
		holder.pai = null

	src.client.perspective = EYE_PERSPECTIVE
	src.client.eye = src
	var/turf/T = get_turf(card.loc)
	card.loc = T
	src.loc = T
	src.forceMove(T)

	card.forceMove(src)
	card.screen_loc = null

	src.SetLuminosity(2)
	weather_immunities = list() //remove ash immunity in holoform

	icon_state = "[chassis]"
	if(istype(T)) T.visible_message("With a faint hum, <b>[src]</b> levitates briefly on the spot before adopting its holographic form in a flash of green light.")

/mob/living/silicon/pai/proc/close_up(var/force = 0)

	if (health < 5 && !force)
		src << "<span class='warning'><b>Your holographic emitters are too damaged to function!</b></span>"
		return

	last_special = world.time + 200
	resting = 0
	if(src.loc == card)
		return

	var/turf/T = get_turf(src)
	if(istype(T)) T.visible_message("<b>[src]</b>'s holographic field distorts and collapses, leaving the central card-unit core behind.")

	if (src.client) //god damnit this is going to be irritating to handle for dc'd pais that stay in holoform
		src.stop_pulling()
		src.client.perspective = EYE_PERSPECTIVE
		src.client.eye = card

	//This seems redundant but not including the forced loc setting messes the behavior up.
	card.loc = T
	card.forceMove(T)
	src.loc = card
	src.forceMove(card)
	canmove = 0
	density = 0
	weather_immunities = list("ash")
	src.SetLuminosity(0)
	icon_state = "[chassis]"

/mob/living/silicon/pai/verb/fold_up()
	set category = "pAI Commands"
	set name = "Return to Card Form"

	if(stat || sleeping || paralysis || weakened)
		return

	if(src.loc == card)
		src << "\red You are already in your card form!"
		return

	if(world.time <= last_special)
		src << "\red You must wait before returning to your card form!"
		return

	if (emitter_OD)
		var/datum/pai/software/beacon_overcharge/S = new /datum/pai/software/beacon_overcharge
		S.take_overload_damage(src)

	close_up()

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "pAI Commands"
	set name = "Choose Holographic Projection"

	if (src.loc == card)
		src << "\red You must be in your holographic form to choose your projection shape!"
		return

	var/choice
	var/finalized = "No"
	while(finalized == "No" && src.client)

		choice = input(usr,"What would you like to use for your holographic mobility icon? This decision can only be made once.") as null|anything in possible_chassis
		if(!choice) return

		icon_state = possible_chassis[choice]
		finalized = alert("Look at your sprite. Is this what you wish to use?",,"No","Yes")

	chassis = possible_chassis[choice]
	if (choice)
		verbs -= /mob/living/silicon/pai/proc/choose_chassis

/mob/living/silicon/pai/proc/rest_protocol()
	set name = "Activate R.E.S.T Protocol"
	set category = "pAI Commands"

	if(src && istype(src.loc,/obj/item/device/paicard))
		resting = 0
		src << "\blue You spool down the clock on your internal processor for a moment. Ahhh. T h a t ' s  t h e  s t u f f."
	else
		resting = !resting
		icon_state = resting ? "[chassis]_rest" : "[chassis]"
		src << "\blue You are now [resting ? "resting" : "getting up"]"

	canmove = !resting

*/