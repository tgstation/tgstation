
/mob/living // NOTE: This adds my own contribution to the /mob/living datum.
	var/frenzied = FALSE 		// I am no longer in control of my actions.
	var/castDuringFrenzy = FALSE// Can I cast spells during frenzy? Turned TRUE just before casting so you pass the test.
/mob/living/proc/IsFrenzied()
	return frenzied
/mob/living/proc/SetFrenzied(amFrenzied = 1)
	frenzied = amFrenzied
/mob/living/proc/SetCastDuringFrenzy(canCast = 1)
	castDuringFrenzy = canCast

// 			How Frenzy Works
//
// First, we need to know what Frenzy State we're in.
// At 0, we're fine.
// At 1, we've been warned that we need to be careful (blood_volume below BLOODSUCKER_STARVE_VOLUME)
// At 2, we're about to Frenzy (just waiting on the warning to finish)
// At 3+, we're in Frenzy (set to BLOODSUCKER_FRENZY_TIME) and we let the computer take over.
//
// When in Frenzy 1 or 2+, you can only come out of it if:
// 	-Your blood reaches BLOODSUCKER_STARVE_VOLUME + 20 (that is, 20 over the value that got you here)
// 	-You die.
//
// The effects of Frenzy are:
// 	-Loss of control
//	-Higher damage dealt
//	-Immune to stun and to stamina damage



datum/antagonist/bloodsucker/proc/handle_hunger_and_frenzy()
		// Tick down Frenzy (Until we get back to Cautious State of 2)
	if (frenzy_state > 2)
		frenzy_state --

	// Low Blood: Enter Frenzy Stage 1
	if (owner.current.blood_volume <= BLOODSUCKER_STARVE_VOLUME)
		if(frenzy_state <= 0)
			to_chat(owner, "<span class='danger'>A gnawing hunger overcomes you. You are at risk of Frenzy if you don't find nourishment soon!</span>")
			frenzy_state = 1
			frenzy_buffer = 5 // You have a moment before Frenzy gets you. Better hurry.

	// Blood Sustained: Leave Frenzy
	else if (owner.current.blood_volume >= BLOODSUCKER_STARVE_VOLUME + 20 && frenzy_state > 0 && frenzy_state < BLOODSUCKER_FRENZY_TIME) // Only leave Frenzy if you've passed back into a safe Blood Volume, NOT just for crossing over by one point.
		switch(frenzy_state)
			if (1)
				to_chat(owner, "<span class='notice'>Your terrible hunger passes. You are no longer at risk of Frenzy.</span>")
			else
				to_chat(owner, "<span class='notice'>The fugue of furious hunger subsides as your stomach fills. You are no longer in Frenzy!</span>")
		frenzy_state = 0
		owner.current.jitteriness = 0

	// Done with Frenzy?	 (failsafe in case of error in Frenzy loop)
	if (frenzy_state <= 2)
		end_frenzy() // NOTE: This fails if we're not actually frenzied, so no worries.

	// Slowly Tick Down Frenzy Buffer (so you don't fly right back into it)
	if (frenzy_buffer > 0)
		frenzy_buffer --
		return


	//////////////////////////////////////
	//		ACTUAL FRENZY WARNING!		//

	// Frenzy Effects: Stage 1
	if (frenzy_state == 1 && !poweron_feed)
			// Look for Blood
		//Bloody Splats on Turf
		for(var/obj/effect/decal/cleanable/target in view(5, get_turf(owner.current)))//range(5, get_turf(user)))
			if(target.can_bloodcrawl_in())
				// TODO Make sure you can SEE the blood!
				to_chat(owner, "<span class='warning'>Your eyes fixate on the gore at your feet. You feel yourself losing control to the monster within you...</span>")
				start_frenzy()
				return
		//Bleeding Characters (but not while feeding)
		for (var/mob/living/carbon/human/H in view(5, get_turf(owner.current)))//range(5, get_turf(user))
			if (H.bleed_rate > 0)
				to_chat(owner, "<span class='warning'>Your eyes fixate on [H]'s bloody wounds. You feel yourself losing control to the monster within you...</span>")
				start_frenzy(H)
				return




datum/antagonist/bloodsucker/proc/start_frenzy(mob/living/target)
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	frenzy_state = 2//BLOODSUCKER_FRENZY_TIME  // This will tick down in bloodsucker_procs
	owner.current.Jitter(20)

	sleep(40)
	to_chat(owner, "<span class='warning'>Your inner monster churns. Control of your body begins to slip away...</span>")
	owner.current.Jitter(250)

	// AHHHHHH!!!!
	sleep(20)
	playsound(owner.current.loc,'sound/Fulpsounds/frenzyscream.ogg', 100, 1)	// This sound has about two seconds of lead-up.

	sleep(20)
	to_chat(owner, "<span class='userdanger'>You enter a savage, bloodthirsty Frenzy! Your actions are no longer your own!</span>")
	owner.current.jitteriness = 0

	// Effects
	//user.blur_eyes(3) // Can't SEE!
	owner.current.SetFrenzied(TRUE)
	frenzy_state = BLOODSUCKER_FRENZY_TIME
	owner.current.spin(14, 1) // Spin around like a loon.
	owner.current.drop_all_held_items() // Goodbye to items
	owner.current.overlay_fullscreen("blurry", /obj/screen/fullscreen/frenzy) // Big red FRENZY overlay!
	owner.current.update_canmove() // Updates if you can move or not. Frenzy has been added.
	//overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry) <---Copied from blur_eyes in mob.dm.  We can add an overlay to screen_full.dmi and have it affected by hud/fullscreen.dm

	// Disable Controls
	// affect user.mind

	// Disable Human Disguise
	//if (poweron_humandisguise)
	//	for (var/obj/effect/proc_holder/spell/bloodsucker/humandisguise/disguisepower in powers)
	//		disguisepower.SetActive(FALSE)

	// Additional Healing Loop
	spawn()
		while(src && frenzy_state > 2 && owner && owner.current && owner.current.stat < DEAD)
			sleep(10)
			if (owner.current)
				owner.current.adjustStaminaLoss(-20, 0)
				owner.current.AdjustStun(-20, 0)
				owner.current.AdjustUnconscious(-20, 0)


	// To Look Up:    /mob/living/carbon/proc/update_tint()   This affects the color of the world. Maybe a tint overlay?

	// Set Frenzy Process Vars
	//var/currentDir
	var/inactivity_period=0				// Attack and do stuff to things.
	var/seek_period=0					// Find someone to kill.
	var/list/myPath = list()			// How we are getting to our target.
	var/startIntent = owner.current.a_intent// What kind of attack intent did I USED TO be in?
	var/pathfind_lock = FALSE			// Am I currently in a loop to try and go somewhere?
	var/turf/T							// Turf I am targeting for scan for DOORS, and OBSTACLES
	var/mob/living/carbon/C = owner.current	// Carbon ref
	var/list/environment_target_typecache = list( 	// Brazenly stolen from hostile.dm.
		/obj/machinery/door/window,					// This is the list of things a vamp will target for destruction.
		/obj/structure/window,
		/obj/structure/closet,
		/obj/structure/table,
		/obj/structure/grille,
		/obj/structure/girder,
		/obj/structure/rack,
		/obj/structure/barricade)
	environment_target_typecache = typecacheof(environment_target_typecache)// Also taken from Initizlize in hostile.dm

	while(src && frenzy_state > 2 && owner && owner.current && owner.current.stat < DEAD)

		// Rest a moment
		sleep(world.tick_lag * 5)
		// Safety: Don't Continue if NOT Vamp anymore
		if(!owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
			break
		// Can I act?
		if (IsDeadOrIncap() || poweron_feed)
			walk(owner.current,0) // Cancel Walking
			continue
		// Tick Down + Sleep
		inactivity_period -= 1
		seek_period -= 1

		// MOVE
		if (!pathfind_lock) // We're going in. Lock up pathfind.
			spawn() // This lets us continue the Frenzy loop while handling this section of code every 5 units of time (as per the sleep, below).
				pathfind_lock = TRUE
				// MOVE: PATHFIND
				if (myPath.len > 0)
					//message_admins("[owner.current] DEBUG PATH: A1) Pathfind: [myPath.len] .")
					for(var/i = 0; i < 6; ++i)//for(var/i = 0; i < maxStepsTick; ++i)
						if(!IsDeadOrIncap(FALSE))
							if(myPath.len >= 1)
								walk_to(owner.current, myPath[1],1,2) // NOTE: this runs in the background! to cancel it, you need to use walk(owner.current,0), or give them a new path.
								myPath -= myPath[1]
								//message_admins("[owner.current] DEBUG PATH: A2) Pathfind: [myPath.len] .")
							else
								myPath = frenzy_pursue_target(target) // Start a new path, for later.
								break
				// MOVE: STRAIGHT AT TARGET / WANDER
				else
					if (target)
						walk_to(owner.current, target,1,2) //Trying to just pursue my target.
						//message_admins("[owner.current] DEBUG PATH: B) Target Go To: [target] .")
					else if (prob(50)) // Only SOMETIMES change your random direction.
						var/d = pick(GLOB.cardinals)
						walk(owner.current, d, 2)
						//message_admins("[owner.current] DEBUG PATH: C) Random Wander: [d] .")
						//walk_rand(owner.current,0.95)
				pathfind_lock = FALSE

		// Jittery / Hallucinate / Eye Blur
		//owner.current.blur_eyes(2) // Can't SEE!
		owner.current.overlay_fullscreen("blurry", /obj/screen/fullscreen/frenzy) // Big red FRENZY overlay!
		C.silent = 20
		//if(prob(0.5))
		//	owner.current.emote("twitch")

		// Already Acted? Feeding? Skip.
		if (inactivity_period > 0)
			continue

		// 						Frequent Actions 						//

		// START FEED
		if (owner.current.pulling)
			// DEAL BITING DAMAGE TO TARGET!
			owner.current.grab_state = max(owner.current.grab_state,GRAB_AGGRESSIVE)
			for (var/obj/effect/proc_holder/spell/bloodsucker/feed/feedpower in powers)
				//to_chat(owner, "<span class='warning'>DEBUG: Frenzy about to attempt Feed:  [feedpower] by [owner.current] </span>")
				owner.current.SetCastDuringFrenzy(TRUE)
				if (!feedpower.active && feedpower.attempt_cast(owner.current))
					inactivity_period = 5
					owner.current.SetCastDuringFrenzy(FALSE) // Disable Casting
					break
				owner.current.SetCastDuringFrenzy(FALSE) // Disable Casting...again. GOD this is dirty.

		// LOSE TARGET
		if (target)
			// Dead guy without blood, OR am
			if (target.blood_volume <= 0 && owner.current.stat)
				target = null

		// FIND TARGET
		if (!target || seek_period <= 0)
			var/mob/living/newtarget = locate(/mob/living) in oview(20, owner.current)// MAX_RANGE_FIND is 32 and MIN_RANGE_FIND is 16   for(var/mob/living/carbon in view(5, get_turf(owner.current))
			// Disqualify New Target if...
			if (newtarget == owner.current || issilicon(newtarget) && !iscyborg(newtarget) || istype(newtarget, /mob/living/simple_animal/bot)) // Can't be self. Can't be a non-robot Silicon, or Beepsky.
				newtarget = null
			else if (newtarget && newtarget.stat == DEAD && (!iscarbon(newtarget) || newtarget.blood_volume <= 0))	// Can't be dead AND un-suckable
				newtarget = null
			// Only replace target if I find a new one
			if (newtarget)
				target = newtarget
			//if (target == owner.current)
			//	target = null
			if (target)
				seek_period = 5 // Check again for a new target in 5 cycles.

			//message_admins("[owner.current] DEBUG TARGET: [target] after finding [newtarget].")

		// PURSUE
		if (myPath.len < 4)
			myPath = frenzy_pursue_target(target)
			if (myPath.len <= 0 || rand(2)) // If no path, OR randomly forget...
				//target = null
				inactivity_period = 5
				seek_period = 5

		// ATTACK
		if(target)
			if (owner.current.Adjacent(target))
				inactivity_period = 4
				owner.current.a_intent = pick(INTENT_DISARM, INTENT_HARM, INTENT_HARM, INTENT_HARM)
				if (!owner.current.restrained() && prob(50))
					target.attack_hand(owner.current)
				else
					target.attack_vamp_bite(owner.current)
				owner.current.start_pulling(target)
				continue

		// DOORS / DESTROY 								//for(var/dir in GLOB.cardinal) // var/turf/T = get_step(targets_from, dir)  // Borrowed from DestroySurroundings() in hostile.dm
		if (!target || !owner.current.Adjacent(target)) // No target, OR not next to target?
			T = (myPath.len > 1) ? get_turf(myPath[2]) : (rand(50) ? get_step_towards(owner.current, target) : get_step_to(owner.current, target)) // Pick between _towards and _to for varying results.   // get_step(user, user.dir) // Find space I am pathing to, OR facing if no path.
			if (T)
				// Walls
				//if(iswallturf(T) || ismineralturf(T))
				//	if(T.Adjacent(user))
				//		message_admins("[user] DEBUG DESTROY: Breaking wall in way: [T] / [iswallturf(T)] / [ismineralturf(T)].")
				//		T.attack_hulk(user, 15) // source, damage
				// Obstacles
				for(var/obj/O in T)
					if(O.Adjacent(owner.current) && O.density) //is_type_in_typecache(O, environment_target_typecache))
						//message_admins("[T] DEBUG DESTROY: Breaking stuff in way: [O].")
						O.attack_generic(owner.current, 15) // source, damage
						break;
				// Doors
				for(var/obj/machinery/door/D in T.contents) // (taken from interactive.dm)
					//message_admins("[T] DEBUG DOOR: Found a door here: [D].")
					//if (istype(D,/obj/machinery/door/airlock))
					if (D.Adjacent(owner.current))
						if (!D.open(0))
							//message_admins("[T] DEBUG DOOR: Couldn't Open Door...trying again: [D].")
							D.open(2) // open(2) is like a crowbar or jaws of life.
								//message_admins("[T] DEBUG DOOR: STILL couldn't open door.: [D].")
				// LOCKERS (?)

		// DEFENSE
		if (!target && owner.current.pulledby)
			target = owner.current.pulledby
			if(owner.current.Adjacent(owner.current.pulledby))
				inactivity_period = 5
				owner.current.a_intent = INTENT_DISARM
				owner.current.pulledby.attack_hand(owner.current)
		// BUCKLED
		if(owner.current.buckled)
			inactivity_period = 10
			owner.current.resist()

	// FRENZY OVER!
	//message_admins("[T] DEBUG: FRENZY OVER! Stat: [owner.current.stat], BS: [frenzy_state].")

	owner.current.a_intent = startIntent			// Return to start intent
	walk(owner.current,0)			// Stop moving (I was probably pathfinding)
	end_frenzy()


// Called from handle_hunger_and_frenzy() in case Frenzy Loop has an error and we get stuck.
datum/antagonist/bloodsucker/proc/end_frenzy()
	if (!owner.current.IsFrenzied())
		return
	owner.current.SetFrenzied(FALSE)

	owner.current.clear_fullscreen("blurry") 	// Restore sight from blurry visuals.
	frenzy_buffer = BLOODSUCKER_FRENZY_OUT_TIME	// Timer til we check for frenzy again
	owner.current.stop_pulling()
	if (frenzy_state > 1 && owner.current.stat == CONSCIOUS)
		to_chat(owner, "<span class='notice'>You can feel your lust for carnage ebb as your Frenzy subsides. You are the master of your own flesh...for now.</span>")
		owner.current.Jitter(50)
		frenzy_state = 1
		if (!poweron_feed)
			owner.current.spin(10, 1) // Spin around like a loon.
	var/mob/living/carbon/C = owner.current
	C.silent = 1
	walk(owner.current,0)			// Stop moving (I was probably pathfinding)
	owner.current.update_canmove() 	// Updates if you can move or not. Frenzy has been removed.
	owner.current.update_action_buttons_icon() // CHECK THIS : Updates icons?



datum/antagonist/bloodsucker/proc/frenzy_pursue_target(mob/living/carbon/target)  // Copied over from interactive.dm/walk2derpless()
	//set background = 1

	var/turf/targetfloor
	// No Target? Random floor
	if(!target)
		// SOMETIMES find a random floor. Otherwise, just cancel out. We'll just wander.
		if (rand(10))
			targetfloor = locate(/turf) in oview(MIN_RANGE_FIND, owner.current)
		else
			return list() // Return empty.
	// Have Target? Pick one
	else
		targetfloor = get_turf(target)

	// Return an appropriate floor
	return get_path_to(owner.current, targetfloor, /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1)//, id=Path_ID)  // Even though we could get what our current ID is, it doesn't matter. Frenzy isnt that smart.







/mob/living/proc/attack_vamp_bite(mob/living/carbon/attacker)
	//if (prob(10))
	if(attacker.is_muzzled() || (attacker.wear_mask && attacker.wear_mask.flags_cover & MASKCOVERSMOUTH))
		visible_message("<span class='danger'>[attacker] feverishly gnashes their teeth at [src], but their mouth is restrained!</span>", \
						"<span class='userdanger'>[attacker] feverishly gnashes their teeth at [src], but their mouth is restrained!</span>", null, COMBAT_MESSAGE_RANGE)
		return 0


	attacker.do_attack_animation(src, ATTACK_EFFECT_BITE)
	add_logs(attacker, src, "frenzy attacked")

	var/damage = rand(attacker.dna.species.punchdamagelow, attacker.dna.species.punchdamagehigh) + 3
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone())

	// MISS?
	if(!damage || !affecting)
		playsound(src.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		//visible_message("<span class='danger'>[attacker] has attempted to bite [src]!</span>",\
		//"<span class='userdanger'>[attacker] has attempted to bite [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		return 0

	// HIT!
	var/armor_block = run_armor_check(affecting, "melee")
	playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	apply_damage(damage, BRUTE, affecting, armor_block)
	visible_message("<span class='danger'>[attacker] bites [src] with terrifying fangs!</span>", \
					"<span class='userdanger'>[attacker] bites [src] with terrifying fangs!</span>", null, COMBAT_MESSAGE_RANGE)


	return 1







// Overlay for Frenzy: Bloody Screen
/obj/screen/fullscreen/frenzy
	icon_state = "brutedamageoverlay4"
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE



// Shamelessly Stolen from Interative.dm
datum/antagonist/bloodsucker/proc/IsDeadOrIncap(checkHealth = 1)
	if(checkHealth && owner.current.health <= 0)
		return 1
	if(owner.current.restrained())
		return 1
	if(owner.current.IsUnconscious())
		return 1
	if(owner.current.IsStun())
		return 1
	if(owner.current.stat)
		return 1
	if(owner.current.lying > 0)
		return 1
	return 0

