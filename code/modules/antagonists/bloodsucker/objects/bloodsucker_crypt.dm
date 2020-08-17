


//									IDEAS		--
//					An object that disguises your coffin while you're in it!
//
//					An object that lets your lair itself protect you from sunlight, like a coffin would (no healing tho)



// Hide a random object somewhere on the station:
//		var/turf/targetturf = get_random_station_turf()
//		var/turf/targetturf = get_safe_random_station_turf()




// 		CRYPT OBJECTS
//
//
// 	PODIUM		Stores your Relics
//
// 	ALTAR		Transmute items into sacred items.
//
//	PORTRAIT	Gaze into your past to: restore mood boost?
//
//	BOOKSHELF	Discover secrets about crew and locations. Learn languages. Learn marial arts.
//
//	BRAZER		Burn rare ingredients to gleen insights.
//
//	RUG			Ornate, and creaks when stepped upon by any humanoid other than yourself and your vassals.
//
//	X COFFIN		(Handled elsewhere)
//
//	X CANDELABRA	(Handled elsewhere)
//
//	THRONE		Your mental powers work at any range on anyone inside your crypt.
//
//	MIRROR		Find any person
//
//	BUST/STATUE	Create terror, but looks just like you (maybe just in Examine?)


//		RELICS
//
//	RITUAL DAGGER
//
// 	SKULL
//
//	VAMPIRIC SCROLL
//
//	SAINTS BONES
//
//	GRIMOIRE


// 		RARE INGREDIENTS
// Ore
// Books (Manuals)


// 										NOTE:  Look up AI and Sentient Disease to see how the game handles the selector logo that only one player is allowed to see. We could add hud for vamps to that?
//											   ALTERNATIVELY, use the Vamp Huds on relics to mark them, but only show to relevant vamps?


/obj/structure/bloodsucker
	var/mob/living/owner

/*
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a sadistic sort to sit on this jagged piece of furniture."

/obj/structure/bloodsucker/bloodaltar
	name = "bloody altar"
	desc = "It is marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."

/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."

/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. On second thought, the reds don't seem to be painted in oil..."

/obj/structure/bloodsucker/bloodbrazer
	name = "lit brazer"
	desc = "It burns slowly, but doesn't radiate any heat."

/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."
*/


/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'icons/Fulpicons/fulpobjects.dmi'
	icon_state = "vassalrack"
	buckle_lying = FALSE
	anchored = FALSE
	density = TRUE					// Start dense. Once fixed in place, go non-dense.
	can_buckle = TRUE
	var/useLock = FALSE				// So we can't just keep dragging ppl on here.
	var/mob/buckled
	var/convert_progress = 2		// Resets on each new character to be added to the chair. Some effects should lower it...
	var/disloyalty_confirm = FALSE	// Command & Antags need to CONFIRM they are willing to lose their role (and will only do it if the Vassal'ing succeeds)
	var/disloyalty_offered = FALSE	// Has the popup been issued? Don't spam them.
	var/convert_cost = 10

//obj/structure/kitchenspike/vassalrack/crowbar_act()
//	// Do Nothing (Cancel crowbar deconstruct)
//	return FALSE

/obj/structure/bloodsucker/vassalrack/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/*
			/obj/structure/closet/CtrlShiftClick(mob/living/user)
				if(!user.has_trait(TRAIT_SKITTISH))
					return ..()
				if(!user.canUseTopic(src) || !isturf(user.loc))
					return
				dive_into(user)
*/



//					adding a STRAP on top of an icon:   look at update_icon in closets.dm, and the use of overlays.dm cut_overlay() and add_overlay()




/obj/structure/bloodsucker/vassalrack/MouseDrop_T(atom/movable/O, mob/user)
	if (!O.Adjacent(src) || O == user || !isliving(O) || !isliving(user) || useLock || has_buckled_mobs() || user.incapacitated())
		return
	if (!anchored && user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		to_chat(user, "<span class='danger'>Until this rack is secured in place, it cannot serve its purpose.</span>")
		return

	// PULL TARGET: Remember if I was pullin this guy, so we can restore this
	var/waspulling = (O == owner.pulling)
	var/wasgrabstate = owner.grab_state
	// 		* MOVE! *
	O.forceMove(drop_location())
	// PULL TARGET: Restore?
	if (waspulling)
		owner.start_pulling(O, wasgrabstate, TRUE)
		// NOTE: in bs_lunge.dm, we use [target.grabbedby(owner)], which simulates doing a grab action. We don't want that though...we're cutting directly back to where we were in a grab.


	// Do Action!
	useLock = TRUE
	if(do_mob(user, O, 50))
		attach_victim(O,user)
	useLock = FALSE

/obj/structure/bloodsucker/vassalrack/AltClick(mob/user)
	if (!has_buckled_mobs() || !isliving(user) || useLock)
		return
	// Attempt Release (Owner vs Non Owner)
	var/mob/living/carbon/C = pick(buckled_mobs)
	if (C)
		if (user == owner)
			unbuckle_mob(C)
		else
			user_unbuckle_mob(C,user)

/obj/structure/bloodsucker/vassalrack/proc/attach_victim(mob/living/M, mob/living/user)
	// Standard Buckle Check
	if (!buckle_mob(M)) // force=TRUE))
		return
	// Attempt Buckle
	user.visible_message("<span class='notice'>[user] straps [M] into the rack, immobilizing them.</span>", \
			  		 "<span class='boldnotice'>You secure [M] tightly in place. They won't escape you now.</span>")

	playsound(src.loc, 'sound/effects/pop_expl.ogg', 25, 1)
	//M.forceMove(drop_location()) <--- CANT DO! This cancels the buckle_mob() we JUST did (even if we foced the move)
	M.setDir(2)
	density = TRUE
	var/matrix/m180 = matrix(M.transform)
	m180.Turn(180)//90)//180
	animate(M, transform = m180, time = 2)
	M.pixel_y = -2 //M.get_standard_pixel_y_offset(120)//180)

	update_icon()

	// Torture Stuff
	convert_progress = 2 			// Goes down unless you start over.
	disloyalty_confirm = FALSE		// New guy gets the chance to say NO if he's special.
	disloyalty_offered = FALSE		// Prevents spamming torture window.

/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/M, mob/user)
	// Attempt Unbuckle
	if (!user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		if (M == user)
			M.visible_message("<span class='danger'>[user] tries to release themself from the rack!</span>",\
							"<span class='danger'>You attempt to release yourself from the rack!</span>") //  For sound if not seen -->  "<span class='italics'>You hear a squishy wet noise.</span>")
		else
			M.visible_message("<span class='danger'>[user] tries to pull [M] rack!</span>",\
							"<span class='danger'>[user] attempts to release you from the rack!</span>") //  For sound if not seen -->  "<span class='italics'>You hear a squishy wet noise.</span>")
		if(!do_mob(user, M, 100))
			return
	// Did the time. Now try to do it.
	..()
	unbuckle_mob(M)

/obj/structure/bloodsucker/vassalrack/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if (!..())
		return
	var/matrix/m180 = matrix(buckled_mob.transform)
	m180.Turn(180)//-90)//180
	animate(buckled_mob, transform = m180, time = 2)
	buckled_mob.pixel_y = buckled_mob.get_standard_pixel_y_offset(180)
	src.visible_message(text("<span class='danger'>[buckled_mob][buckled_mob.stat==DEAD?"'s corpse":""] slides off of the rack.</span>"))
	density = FALSE
	buckled_mob.AdjustParalyzed(30)

	update_icon()

	useLock = FALSE // Failsafe

/obj/structure/bloodsucker/vassalrack/attackby(obj/item/W, mob/user, params)
	if (has_buckled_mobs()) // Attack w/weapon vs guy standing there? Don't do an attack.
		attack_hand(user)
		return FALSE
	return ..()

/obj/structure/bloodsucker/vassalrack/attack_hand(mob/user)
	//. = ..()	// Taken from sacrificial altar in divine.dm
	//if(.)
	//	return

	// Go away. Torturing.
	if (useLock)
		return

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// CHECK ONE: Am I claiming this? Is it in the right place?
	if (istype(bloodsuckerdatum) && !owner)
		if (!bloodsuckerdatum.lair)
			to_chat(user, "<span class='danger'>You don't have a lair. Claim a coffin to make that location your lair.</span>")
		if (bloodsuckerdatum.lair != get_area(src))
			to_chat(user, "<span class='danger'>You may only activate this structure in your lair: [bloodsuckerdatum.lair].</span>")
			return
		switch(alert(user,"Do you wish to afix this structure here?","Secure [src]","Yes", "No"))
			if("Yes")
				owner = user
				density = FALSE
				anchored = TRUE
				return

	// No One Home
	if (!has_buckled_mobs())
		return

	// CHECK TWO: Am I a non-bloodsucker?
	var/mob/living/carbon/C = pick(buckled_mobs)
	if (!istype(bloodsuckerdatum))
		// Try to release this guy
		user_unbuckle_mob(C, user)
		return

	// Bloodsucker Owner! Let the boy go.
	if (C.mind)
		var/datum/antagonist/vassal/vassaldatum = C.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
		if (istype(vassaldatum) && vassaldatum.master == bloodsuckerdatum || C.stat >= DEAD)
			unbuckle_mob(C)
			useLock = FALSE // Failsafe
			return

	// Just torture the boy
	torture_victim(user, C)


/obj/structure/bloodsucker/vassalrack/proc/torture_victim(mob/living/user, mob/living/target)

	// Check Bloodmob/living/M, force = FALSE, check_loc = TRUE
	if (user.blood_volume < convert_cost + 5)
		to_chat(user, "<span class='notice'>You don't have enough blood to initiate the Dark Communion with [target].</span>")
		return

	// Prep...
	useLock = TRUE


	// Step One:	Tick Down Conversion from 3 to 0
	// Step Two:	Break mindshielding/antag (on approve)
	// Step Three:	Blood Ritual

	// Conversion Process
	if (convert_progress > 0)
		to_chat(user, "<span class='notice'>You prepare to initiate [target] into your service.</span>")
		if (!do_torture(user,target))
			to_chat(user, "<span class='danger'><i>The ritual has been interrupted!</i></span>")
		else
			convert_progress -- // Ouch. Stop. Don't.
			// All done!
			if (convert_progress <= 0)
				// FAIL: Can't be Vassal
				if (!SSticker.mode.can_make_vassal(target, user, display_warning=FALSE)) // If I'm an unconvertable Antag ONLY
					to_chat(user, "<span class='danger'>[target] doesn't respond to your persuasion. It doesn't appear they can be converted to follow you. <i>\[ALT+click to release\]</span>")
					convert_progress ++ // Pop it back up some. Avoids wasting Blood on a lost cause.
				// SUCCESS: All done!
				else
					if (RequireDisloyalty(target))
						to_chat(user, "<span class='boldwarning'>[target] has external loyalties! [target.p_they(TRUE)] will require more <i>persuasion</i> to break [target.p_them()] to your will!</span>")
					else
						to_chat(user, "<span class='notice'>[target] looks ready for the <b>Dark Communion</b>.</span>")
			// Still Need More Persuasion...
			else
				to_chat(user, "<span class='notice'>[target] could use [convert_progress == 1?"a little":"some"] more <i>persuasion</i>.</span>")

		useLock = FALSE
		return

	// Check: Mindshield & Antag
	if (!disloyalty_confirm && RequireDisloyalty(target))
		if (!do_disloyalty(user,target))
			to_chat(user, "<span class='danger'><i>The ritual has been interrupted!</i></span>")
		else if (!disloyalty_confirm)
			to_chat(user, "<span class='danger'>[target] refuses to give into your persuasion. Perhaps a little more?</span>")
		else
			to_chat(user, "<span class='notice'>[target] looks ready for the <b>Dark Communion</b>.</span>")
		useLock = FALSE
		return

	// Check: Blood
	if (user.blood_volume < convert_cost)
		to_chat(user, "<span class='notice'>You don't have enough blood to initiate the Dark Communion with [target].</span>")
		useLock = FALSE
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	bloodsuckerdatum.AddBloodVolume(-convert_cost)
	target.add_mob_blood(user)
	user.visible_message("<span class='notice'>[user] marks a bloody smear on [target]'s forehead and puts a wrist up to [target.p_their()] mouth!</span>", \
				  	  "<span class='notice'>You paint a bloody marking across [target]'s forehead, place your wrist to [target.p_their()] mouth, and subject [target.p_them()] to the Dark Communion.</span>")
	if(!do_mob(user, src, 50))
		to_chat(user, "<span class='danger'><i>The ritual has been interrupted!</i></span>")
		useLock = FALSE
		return

	// Convert to Vassal!
	if (bloodsuckerdatum && bloodsuckerdatum.attempt_turn_vassal(target))
		remove_loyalties(target) // In case of Mindshield, or appropriate Antag (Traitor, Internal, etc)

		//if (!target.buckled)
		//	to_chat(user, "<span class='danger'><i>The ritual has been interrupted!</i></span>")
		//	useLock = FALSE
		//	return
		user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, 1) 	// Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
		target.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, 1) 	// Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
		target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) 		// Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
		target.Jitter(25)
		target.emote("laugh")
		//remove_victim(target) // Remove on CLICK ONLY!

	useLock = FALSE


/obj/structure/bloodsucker/vassalrack/proc/do_torture(mob/living/user, mob/living/target, mult=1)

	var/torture_time = 15 // Fifteen seconds if you aren't using anything. Shorter with weapons and such.
	var/torture_dmg_brute = 2
	var/torture_dmg_burn = 0

	// Get Bodypart
	var/target_string = ""
	var/obj/item/bodypart/BP = null
	if (iscarbon(target))
		var/mob/living/carbon/C = target
		BP = pick(C.bodyparts)
		if (BP)
			target_string += BP.name

	// Get Weapon
	var/obj/item/I = user.get_active_held_item()
	if (!istype(I))
		I = user.get_inactive_held_item()
	// Create Strings
	var/method_string =  I?.attack_verb?.len ? pick(I.attack_verb) : pick("harmed","tortured","wrenched","twisted","scoured","beaten","lashed","scathed")
	var/weapon_string = I ? I.name : pick("bare hands","hands","fingers","fists")

	// Weapon Bonus + SFX
	if (I)
		torture_time -= I.force / 4
		torture_dmg_brute += I.force / 4
		//torture_dmg_burn += I.
		if (I.sharpness == SHARP_EDGED)
			torture_time -= 1
		else if (I.sharpness == SHARP_POINTY)
			torture_time -= 2
		if (istype(I, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder = I
			welder.welding = TRUE
			torture_time -= 5
			torture_dmg_burn += 5

		I.play_tool_sound(target)
	torture_time = max(50, torture_time * 10) // Minimum 5 seconds.

	// Now run process.
	if (!do_mob(user, target, torture_time * mult))
		return FALSE

	// SUCCESS
	if (I)
		playsound(loc, I.hitsound, 30, 1, -1)
		I.play_tool_sound(target)

	target.visible_message("<span class='danger'>[user] has [method_string] [target]'s [target_string] with [user.p_their()] [weapon_string]!</span>", \
						   "<span class='userdanger'>[user] has [method_string] your [target_string] with [user.p_their()] [weapon_string]!</span>")
	if (!target.is_muzzled())
		target.emote("scream")
	target.Jitter(5)
	target.apply_damages(brute = torture_dmg_brute, burn = torture_dmg_burn, def_zone = (BP ? BP.body_zone : null)) // take_overall_damage(6,0)

	return TRUE






/obj/structure/bloodsucker/vassalrack/proc/do_disloyalty(mob/living/user, mob/living/target)

	// OFFER YES/NO NOW!
	spawn(10)
		if (useLock && target && target.client) // Are we still torturing? Did we cancel? Are they still here?
			to_chat(user, "<span class='notice'>[target] has been given the opportunity for servitude. You await their decision...</span>")
			var/alert_text = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]?"
			if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
				alert_text += "\n\nYou will no longer be loyal to the station!"
			if (SSticker.mode.AmValidAntag(target.mind))
				alert_text += "\n\nYou will not lose your current objectives, but they come second to the will of your new master!"
			switch(alert(target, alert_text,"THE HORRIBLE PAIN! WHEN WILL IT END?!","Yes, Master!", "NEVER!"))
				if("Yes, Master!")
					disloyalty_accept(target)
				else
					disloyalty_refuse(target)
	if (!do_torture(user,target, 2))
		return FALSE

	// NOTE: We only remove loyalties when we're CONVERTED!
	return TRUE

/obj/structure/bloodsucker/vassalrack/proc/RequireDisloyalty(mob/living/target)
	return SSticker.mode.AmValidAntag(target.mind) || HAS_TRAIT(target, TRAIT_MINDSHIELD)

/obj/structure/bloodsucker/vassalrack/proc/disloyalty_accept(mob/living/target)
	// FAILSAFE: Still on the rack?
	if (!(locate(target) in buckled_mobs))
		return

	// NOTE: You can say YES after torture. It'll apply to next time.

	disloyalty_confirm = TRUE

	if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(target, "<span class='boldnotice'>You give in to the will of your torturer. If they are successful, you will no longer be loyal to the station!</span>")


/obj/structure/bloodsucker/vassalrack/proc/disloyalty_refuse(mob/living/target)
	// FAILSAFE: Still on the rack?
	if (!(locate(target) in buckled_mobs))
		return
	// Failsafe: You already said YES.
	if (disloyalty_confirm)
		return
	to_chat(target, "<span class='notice'>You refuse to give in! You <i>will not</i> break!</span>")


/obj/structure/bloodsucker/vassalrack/proc/remove_loyalties(mob/living/target)

	// Find Mind Implant & Destroy
	if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
		for(var/obj/item/implant/I in target.implants)
			if(I.type == /obj/item/implant/mindshield)
				I.removed(target,silent=TRUE)















////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'icons/Fulpicons/fulpobjects.dmi'
	icon_state = "candelabrum"
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 3
	light_range = 0 // to 2
	density = FALSE
	anchored = TRUE
	var/lit = FALSE

///obj/structure/bloodsucker/candelabrum/is_hot() // candle.dm
	//return FALSE

/obj/structure/bloodsucker/candelabrum/update_icon()
	icon_state = "candelabrum[lit ? "_lit" : ""]"

/obj/structure/bloodsucker/candelabrum/attack_hand(mob/user)
	// Unlight (only a Vamp can light it)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (istype(bloodsuckerdatum))
		lit = !lit
		if (lit)
			set_light(2,3,"#66FFFF")
			to_chat(user, "You wave your hand over the candelabrum. It springs to life.")
		else
			set_light(0)
		update_icon()

/obj/structure/bloodsucker/candelabrum/AltClick(mob/user)
	// Bloodsuckers can turn their candles on from a distance. SPOOOOKY.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (istype(bloodsuckerdatum))
		attack_hand(user)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/crafting_recipe/bloodsucker/vassalrack
	name = "Persuasion Rack"
	//desc = "For converting crewmembers into loyal Vassals."
	result = /obj/structure/bloodsucker/vassalrack
	tools = list(/obj/item/weldingtool,
				 ///obj/item/screwdriver,
				 /obj/item/wrench
				 )
	reqs = list(/obj/item/stack/sheet/mineral/wood = 3,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/restraints/handcuffs/cable = 2,
				///obj/item/storage/belt = 1
				///obj/item/stack/sheet/animalhide = 1, // /obj/item/stack/sheet/leather = 1,
				///obj/item/stack/sheet/plasteel = 5
				)
	//parts = list(/obj/item/storage/belt = 1
	//			 )

	time = 150
	category = CAT_STRUCTURE
	always_availible = FALSE	// Disabled til learned


/datum/crafting_recipe/bloodsucker/candelabrum
	name = "Candelabrum"
	//desc = "For converting crewmembers into loyal Vassals."
	result = /obj/structure/bloodsucker/candelabrum
	tools = list(/obj/item/weldingtool,
				 /obj/item/wrench
				 )
	reqs = list(/obj/item/stack/sheet/metal = 3,
				/obj/item/stack/rods = 1,
				/obj/item/candle = 1
				)
	time = 100
	category = CAT_STRUCTURE
	always_availible = FALSE	// Disabled til learned




//   OTHER THINGS TO USE: HUMAN BLOOD. /obj/effect/decal/cleanable/blood
