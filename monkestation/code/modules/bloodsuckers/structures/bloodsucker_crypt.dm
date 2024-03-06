/obj/structure/bloodsucker
	///Who owns this structure?
	var/mob/living/owner
	/*
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/ghost_desc
	var/vamp_desc
	var/vassal_desc
	var/hunter_desc

/obj/structure/bloodsucker/examine(mob/user)
	. = ..()
	if(!user.mind && ghost_desc != "")
		. += span_cult(ghost_desc)
	if(IS_BLOODSUCKER(user) && vamp_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential.")
			return
		. += span_cult(vamp_desc)
	if(IS_VASSAL(user) && vassal_desc != "")
		. += span_cult(vassal_desc)
	if(IS_MONSTERHUNTER(user) && hunter_desc != "")
		. += span_cult(hunter_desc)

/// This handles bolting down the structure.
/obj/structure/bloodsucker/proc/bolt(mob/user)
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Bloodsucker Tip: Examine [src] to understand how it functions!"))
	owner = user

/// This handles unbolting of the structure.
/obj/structure/bloodsucker/proc/unbolt(mob/user)
	to_chat(user, span_danger("You have unsecured [src]."))
	owner = null

/obj/structure/bloodsucker/attackby(obj/item/item, mob/living/user, params)
	/// If a Bloodsucker tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_BLOODSUCKER(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Bloodsucker Tip: Examine Bloodsucker structures to understand how they function!"))
		return
	return ..()

/obj/structure/bloodsucker/attack_hand(mob/user, list/modifiers)
//	. = ..() // Don't call parent, else they will handle unbuckling.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Claiming the Rack instead of using it?
	if(istype(bloodsuckerdatum) && !owner)
		if(!bloodsuckerdatum.bloodsucker_lair_area)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(bloodsuckerdatum.bloodsucker_lair_area != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [bloodsuckerdatum.bloodsucker_lair_area]."))
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, span_notice("Do you wish to secure [src] here?"))
		var/static/list/secure_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"))
		var/secure_response = show_radial_menu(user, src, secure_options, radius = 36, require_near = TRUE)
		if(!secure_response)
			return FALSE
		switch(secure_response)
			if("Yes")
				user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
				bolt(user)
				return FALSE
		return FALSE
	return TRUE

/obj/structure/bloodsucker/AltClick(mob/user)
	. = ..()
	if(user == owner && user.Adjacent(src))
		balloon_alert(user, "unbolt [src]?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				unbolt(user)
/*
/obj/structure/bloodsucker/bloodaltar
	name = "bloody altar"
	desc = "It is made of marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."
/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."
/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. Those reds don't seem to be painted in oil..."
/obj/structure/bloodsucker/bloodbrazier
	name = "lit brazier"
	desc = "It burns slowly, but doesn't radiate any heat."
/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."
/obj/item/restraints/legcuffs/beartrap/bloodsucker
*/

/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	ghost_desc = "This is a Vassal rack, which allows Bloodsuckers to thrall crewmembers into loyal minions."
	vamp_desc = "This is the Vassal rack, which allows you to thrall crewmembers into loyal minions in your service.\n\
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Right-click on the vassal rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack. The time required scales with the tool in your off hand. This costs Blood to do.\n\
		Vassals can be turned into special ones by continuing to torture them once converted."
	vassal_desc = "This is the vassal rack, which allows your master to thrall crewmembers into their minions.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassal rack by click dragging the victim onto the rack while it is secured."
	hunter_desc = "This is the vassal rack, which monsters use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt it."

	/// Resets on each new character to be added to the chair. Some effects should lower it...
	var/convert_progress = 3
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/disloyalty_confirm = FALSE
	/// Prevents popup spam.
	var/disloyalty_offered = FALSE

/obj/structure/bloodsucker/vassalrack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 14)

/obj/structure/bloodsucker/vassalrack/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/iron(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/bloodsucker/vassalrack/bolt()
	. = ..()
	density = FALSE
	anchored = TRUE

/obj/structure/bloodsucker/vassalrack/unbolt()
	. = ..()
	density = TRUE
	anchored = FALSE

/obj/structure/bloodsucker/vassalrack/MouseDrop_T(atom/movable/movable_atom, mob/user)
	var/mob/living/living_target = movable_atom
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that this machine cannot be vassalized, therefore it is useless to buckle them."))
		return
	if(do_after(user, 5 SECONDS, living_target))
		attach_victim(living_target, user)

/// Attempt Release (Owner vs Non Owner)
/obj/structure/bloodsucker/vassalrack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!user.can_perform_action(src))
		return
	if(!has_buckled_mobs() || !isliving(user))
		return
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(buckled_carbons)
		if(user == owner)
			unbuckle_mob(buckled_carbons)
		else
			user_unbuckle_mob(buckled_carbons, user)

/**
 * Attempts to buckle target into the vassalrack
 */
/obj/structure/bloodsucker/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing them."),
		span_boldnotice("You secure [target] tightly in place. They won't escape you now."),
	)

	playsound(loc, 'sound/effects/pop_expl.ogg', 25, 1)
	update_appearance(UPDATE_ICON)
	density = TRUE

	// Set up Torture stuff now
	convert_progress = 3
	disloyalty_confirm = FALSE
	disloyalty_offered = FALSE

/// Attempt Unbuckle
/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
		return ..()

	if(buckled_mob == user)
		buckled_mob.visible_message(
			span_danger("[user] tries to release themself from the rack!"),
			span_danger("You attempt to release yourself from the rack!"),
			span_hear("You hear a squishy wet noise."))
		if(!do_after(user, 20 SECONDS, buckled_mob))
			return
	else
		buckled_mob.visible_message(
			span_danger("[user] tries to pull [buckled_mob] rack!"),
			span_danger("[user] tries to pull [buckled_mob] rack!"),
			span_hear("You hear a squishy wet noise."))
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return

	return ..()

/obj/structure/bloodsucker/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	if(!.)
		return FALSE
	visible_message(span_danger("[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	density = FALSE
	buckled_mob.Paralyze(2 SECONDS)
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/bloodsucker/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return FALSE
	// Is there anyone on the rack & If so, are they being tortured?
	if(!has_buckled_mobs())
		return FALSE

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	// If I'm not a Bloodsucker, try to unbuckle them.
	if(!istype(bloodsuckerdatum))
		user_unbuckle_mob(buckled_carbons, user)
		return
	if(!bloodsuckerdatum.my_clan)
		to_chat(user, span_warning("You can't vassalize people until you enter a Clan (Through your Antagonist UI button)"))
		user.balloon_alert(user, "join a clan first!")
		return

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_carbons)
	// Are they our Vassal?
	if(vassaldatum && (vassaldatum in bloodsuckerdatum.vassals))
		SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_INTERACT_WITH_VASSAL, vassaldatum)
		return

	// Not our Vassal, but Alive & We're a Bloodsucker, good to torture!
	torture_victim(user, buckled_carbons)

/**
 * Torture steps:
 *
 * * Tick Down Conversion from 3 to 0
 * * Break mindshielding/antag (on approve)
 * * Vassalize target
 */
/obj/structure/bloodsucker/vassalrack/proc/torture_victim(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(IS_VASSAL(target))
		var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
		if(!vassaldatum.master.broke_masquerade)
			balloon_alert(user, "someone else's vassal!")
			return FALSE

	var/disloyalty_requires = RequireDisloyalty(user, target)

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		balloon_alert(user, "its pointless to try and change their loyalties!")
		return FALSE

	if(disloyalty_requires == VASSALIZATION_BANNED)
		balloon_alert(user, "can't be vassalized!")
		return FALSE

	// Conversion Process
	if(convert_progress)
		balloon_alert(user, "spilling blood...")
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		if(!do_torture(user, target))
			return FALSE
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		// Prevent them from unbuckling themselves as long as we're torturing.
		target.Paralyze(1 SECONDS)
		convert_progress--

		// We're done? Let's see if they can be Vassal.
		if(convert_progress)
			balloon_alert(user, "needs more persuasion...")
			return

		if(disloyalty_requires)
			balloon_alert(user, "has external loyalties! more persuasion required!")
		else
			balloon_alert(user, "ready for communion!")
		return

	if(!disloyalty_confirm && disloyalty_requires)
		if(!do_disloyalty(user, target))
			return
		if(!disloyalty_confirm)
			balloon_alert(user, "refused persuasion!")
		else
			balloon_alert(user, "ready for communion!")
		return

	user.balloon_alert_to_viewers("smears blood...", "painting bloody marks...")
	if(!do_after(user, 5 SECONDS, target))
		balloon_alert(user, "interrupted!")
		return
	// Convert to Vassal!
	bloodsuckerdatum.AddBloodVolume(-TORTURE_CONVERSION_COST)
	if(bloodsuckerdatum.make_vassal(target))
		remove_loyalties(target)
		SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_MADE_VASSAL, user, target)

/obj/structure/bloodsucker/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, mult = 1)
	// Fifteen seconds if you aren't using anything. Shorter with weapons and such.
	var/torture_time = 15
	var/torture_dmg_brute = 2
	var/torture_dmg_burn = 0
	var/obj/item/bodypart/selected_bodypart = pick(target.bodyparts)
	// Get Weapon
	var/obj/item/held_item = user.get_inactive_held_item()
	/// Weapon Bonus
	if(held_item)
		torture_time -= held_item.force / 4
		if(!held_item.use_tool(src, user, 0, volume = 5))
			return
		switch(held_item.damtype)
			if(BRUTE)
				torture_dmg_brute = held_item.force / 4
				torture_dmg_burn = 0
			if(BURN)
				torture_dmg_brute = 0
				torture_dmg_burn = held_item.force / 4
		switch(held_item.sharpness)
			if(SHARP_EDGED)
				torture_time -= 2
			if(SHARP_POINTY)
				torture_time -= 3

	// Minimum 5 seconds.
	torture_time = max(5 SECONDS, torture_time * 10)
	// Now run process.
	if(!do_after(user, (torture_time * mult), target))
		return FALSE

	if(held_item)
		held_item.play_tool_sound(target)
	target.visible_message(
		span_danger("[user] performs a ritual, spilling some of [target]'s blood from their [selected_bodypart.name] and shaking them up!"),
		span_userdanger("[user] performs a ritual, spilling some blood from your [selected_bodypart.name], shaking you up!"))

	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	target.set_timed_status_effect(5 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	target.apply_damages(brute = torture_dmg_brute, burn = torture_dmg_burn, def_zone = selected_bodypart.body_zone)
	return TRUE

/// Offer them the oppertunity to join now.
/obj/structure/bloodsucker/vassalrack/proc/do_disloyalty(mob/living/user, mob/living/target)
	if(disloyalty_offered)
		return FALSE

	disloyalty_offered = TRUE
	to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await their decision..."))
	var/alert_response = tgui_alert(
		user = target, \
		message = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]? \n\
			You will not lose your current objectives, but they come second to the will of your new master!", \
		title = "THE HORRIBLE PAIN! WHEN WILL IT END?!",
		buttons = list("Accept", "Refuse"),
		timeout = 10 SECONDS, \
		autofocus = TRUE, \
	)
	switch(alert_response)
		if("Accept")
			disloyalty_confirm = TRUE
		else
			target.balloon_alert_to_viewers("stares defiantly", "refused vassalization!")
	disloyalty_offered = FALSE
	return TRUE

/obj/structure/bloodsucker/vassalrack/proc/RequireDisloyalty(mob/living/user, mob/living/target)
#ifdef BLOODSUCKER_TESTING
	if(!target || !target.mind)
#else
	if(!target || !target.client)
#endif
		balloon_alert(user, "target has no mind!")
		return VASSALIZATION_BANNED

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	return bloodsuckerdatum.AmValidAntag(target)

/obj/structure/bloodsucker/vassalrack/proc/remove_loyalties(mob/living/target)
	// Find Mind Implant & Destroy
	for(var/obj/item/implant/all_implants as anything in target.implants)
		if(all_implants.type == /obj/item/implant/mindshield)
			all_implants.removed(target, silent = TRUE)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "candelabrum"
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 3
	light_outer_range = 0 // to 2
	density = FALSE
	can_buckle = TRUE
	anchored = FALSE
	ghost_desc = "This is a magical candle which drains at the sanity of non Bloodsuckers and Vassals.\n\
		Vassals can turn the candle on manually, while Bloodsuckers can do it from a distance."
	vamp_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.\n\
		You can right-click on it from any range to turn it on remotely, or simply be next to it and click on it to turn it on and off normally."
	vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n\
		You can turn it on and off by clicking on it while you are next to it.\n\
		If your Master is part of the Ventrue Clan, they utilize this to upgrade their Favorite Vassal."
	hunter_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/bloodsucker/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bloodsucker/candelabrum/update_icon_state()
	icon_state = "candelabrum[lit ? "_lit" : ""]"
	return ..()

/obj/structure/bloodsucker/candelabrum/bolt()
	. = ..()
	set_anchored(TRUE)
	density = TRUE

/obj/structure/bloodsucker/candelabrum/unbolt()
	. = ..()
	set_anchored(FALSE)
	density = FALSE

/obj/structure/bloodsucker/candelabrum/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(anchored && (IS_VASSAL(user) || IS_BLOODSUCKER(user)))
		toggle()
	return ..()

/obj/structure/bloodsucker/candelabrum/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		desc = initial(desc)
		set_light(l_outer_range = 2, l_power = 3, l_color = "#66FFFF")
		START_PROCESSING(SSobj, src)
	else
		desc = "Despite not being lit, it makes your skin crawl."
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/candelabrum/process()
	if(!lit)
		return
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people))
			continue
		nearly_people.adjust_hallucinations(5 SECONDS)
		nearly_people.add_mood_event("vampcandle", /datum/mood_event/vampcandle)

/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a Bloodsucker throne, any Bloodsucker sitting on it can remotely speak to their Vassals by attempting to speak aloud."
	vamp_desc = "This is a blood throne, sitting on it will allow you to telepathically speak to your vassals by simply speaking."
	vassal_desc = "This is a blood throne, it allows your Master to telepathically speak to you and others like you."
	hunter_desc = "This is a chair that hurts those that try to buckle themselves onto it, though the Undead have no problem latching on.\n\
		While buckled, Monsters can use this to telepathically communicate with eachother."
	var/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/bloodsucker/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/bloodsucker/bloodthrone/bolt()
	. = ..()
	anchored = TRUE

/obj/structure/bloodsucker/bloodthrone/unbolt()
	. = ..()
	anchored = FALSE

// Armrests
/obj/structure/bloodsucker/bloodthrone/proc/GetArmrest()
	return mutable_appearance('monkestation/icons/bloodsuckers/vamp_obj_64.dmi', "thronearm")

/obj/structure/bloodsucker/bloodthrone/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..()
	user.visible_message(
		span_notice("[user] sits down on [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_BLOODSUCKER(user))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		unbuckle_mob(user)
		user.Paralyze(10 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	src.visible_message(span_danger("[user] unbuckles themselves from [src]."))
	if(IS_BLOODSUCKER(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	. = ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 2

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	for(var/datum/antagonist/vassal/receiver as anything in bloodsuckerdatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered)
	to_chat(user, rendered) // tell yourself, too.

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""
