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
		user.playsound_local(null, 'sound/machines/buzz/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
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
				user.playsound_local(null, 'sound/items/tools/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
				bolt(user)
				return FALSE
		return FALSE
	return TRUE

/obj/structure/bloodsucker/click_alt(mob/user)
	prompt_unsecure(user)

///Separate from 'click_alt()' so certain structures can easily prompt unsecuring
///through different inputs.
/obj/structure/bloodsucker/proc/prompt_unsecure(mob/user)
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
/obj/item/restraints/legcuffs/beartrap/bloodsucker
*/

/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "This is clearly either meant for torture or correcting spinal injuries." //TODO: Make persuasion racks actually correct torso bone wounds
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	buckle_prevents_pull = TRUE
	ghost_desc = "This is a persuassion rack, which allows Bloodsuckers to thrall crewmembers into loyal minions."
	vamp_desc = "This is a persuassion rack, which allows you to thrall crewmembers into loyal minions in your service.\n\
		Simply drag a victim's sprite onto the rack to buckle them to it. Right-click on the rack to unbuckle them.\n\
		To convert into a vassal, repeatedly click on the persuasion rack. The time required scales with the tool in your off hand. This costs blood to do.\n\
		Vassals can be turned into special ones by continuing to torture them once converted."
	vassal_desc = "This is a persuassion rack, which allows your master to thrall crewmembers into their service.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the rack by dragging their sprite onto the rack while it is secured."
	hunter_desc = "This is a persuassion rack, which vampires use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt them."

#ifdef BLOODSUCKER_TESTING
	var/convert_progress = 1
#else
	/// Resets on each new character to be added to the chair. Some effects should lower it...
	var/convert_progress = 3
#endif
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/disloyalty_confirm = FALSE
	/// Prevents popup spam.
	var/disloyalty_offered = FALSE

/obj/structure/bloodsucker/vassalrack/atom_deconstruct(disassembled = TRUE)
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

/obj/structure/bloodsucker/vassalrack/mouse_drop_receive(atom/target, mob/user, params)
	var/mob/living/living_target = target
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the persuasion rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(target) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated || living_target.buckled)
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
		span_boldnotice("You secure [target] tightly in place. They won't escape now."),
	)

	playsound(loc, 'sound/effects/pop_expl.ogg', 25, 1)
	update_appearance(UPDATE_ICON)
	density = TRUE

	// Set up Torture stuff now
	convert_progress = initial(convert_progress)
	disloyalty_confirm = FALSE
	disloyalty_offered = FALSE

/// Attempt Unbuckle
/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
		return ..()

	if(buckled_mob == user)
		buckled_mob.visible_message(
			span_danger("[user] struggles to break off of the rack!"),
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
		to_chat(user, span_warning("You can't vassalize people until you enter a clan through your Antagonist UI button"))
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
	if(target.stat > UNCONSCIOUS)
		balloon_alert(user, "too badly injured!")
		return FALSE

	if(IS_VASSAL(target))
		var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
		if(!vassaldatum.master.broke_masquerade)
			balloon_alert(user, "someone else's vassal!")
			return FALSE

	var/disloyalty_requires = RequireDisloyalty(user, target)
	if(disloyalty_requires == VASSALIZATION_BANNED)
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
		for(var/obj/item/implant/mindshield/implant in target.implants)
			implant.removed(target, silent = TRUE)
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

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		return VASSALIZATION_DISLOYAL
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	return bloodsuckerdatum.AmValidAntag(target)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Subtype for bloodsucker lighting structures (candelabrum and blazier)

/obj/structure/bloodsucker/lighting
	name = "NONDESCRIPT BLOODSUCKER LIGHTING FIXTURE THAT SHOULDN'T EXIST"
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 1
	light_range = 0
	density = FALSE
	anchored = FALSE
	interaction_flags_click = BYPASS_ADJACENCY // Needed for the Ctrl+Click ranged interaction.
	var/lit = FALSE 						  //I'm sure it will have no unforeseen consequences, none whatsoever
	var/active_light_range = 3

/obj/structure/bloodsucker/lighting/Initialize()
	. = ..()
	register_context()
	update_appearance()
	desc = "Its proportions seem... <i>off</i>."

/obj/structure/bloodsucker/lighting/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/bloodsucker/lighting/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!anchored)
		return
	if(in_range(source, user))
		if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
			context[SCREENTIP_CONTEXT_LMB] = "[lit ? "Extinguish":"Ignite"]"
			return CONTEXTUAL_SCREENTIP_SET
	else
		if(IS_BLOODSUCKER(user))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "[lit ? "Extinguish":"Ignite"]"
			return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bloodsucker/lighting/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][lit ? "_lit" : ""]"

/obj/structure/bloodsucker/lighting/bolt()
	. = ..()
	set_anchored(TRUE)
	density = TRUE

/obj/structure/bloodsucker/lighting/unbolt()
	. = ..()
	set_anchored(FALSE)
	density = FALSE
	if(lit)
		toggle()

/obj/structure/bloodsucker/lighting/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(anchored && (IS_VASSAL(user) || IS_BLOODSUCKER(user)))
		toggle()
	return ..()

/obj/structure/bloodsucker/lighting/click_ctrl(mob/user)
	if(!in_range(src, user) && anchored && IS_BLOODSUCKER(user))
		toggle()
		user.visible_message(span_danger("The [lit ? "[src.name] suddenly crackles to life" : "[src.name] is abruptly extinguished"]!"),
		span_danger("<i>With a subtle hand motion you [lit ? "ignite [src]" : "snuff out [src]"].</i>"))
		return CLICK_ACTION_SUCCESS
	return

/obj/structure/bloodsucker/lighting/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		desc = initial(desc)
		set_light(active_light_range, light_power, light_color)
		playsound(loc, 'sound/items/match_strike.ogg', 25)
		START_PROCESSING(SSobj, src)
	else
		desc = "Its proportions seem... <i>off</i>."
		set_light(0)
		playsound(loc, 'sound/effects/bamf.ogg', 20, FALSE, 0, 2)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/lighting/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Candelabrum - Drains the sanity of non-bloodsuckers/non-vassals near it, has the brightness of a lightbulb
/obj/structure/bloodsucker/lighting/candelabrum
	name = "candelabrum"
	desc = "It burns slowly and doesn't radiate heat."
	icon_state = "candelabrum_lit"
	base_icon_state = "candelabrum"
	active_light_range = 3
	ghost_desc = "This magical candle causes hallucinations and negatively affects the mood of those who are neither bloodsuckers nor vassals."
	vamp_desc = "This magical candle drains the sanity of unvassalized mortals while active.\n\
		You alone can toggle it from afar by <b>ctrl-clicking</b> it."
	vassal_desc = "This magical candle drains the sanity of those fools who havent yet accepted your master while active."
	hunter_desc = "This magical candle causes insanity to those near it while active."

/obj/structure/bloodsucker/lighting/cendelabrum/process()
	. = ..()
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people))
			continue
		nearly_people.adjust_hallucinations(5 SECONDS)
		nearly_people.add_mood_event("vampcandle", /datum/mood_event/vampcandle)

// Brazier - Currently nothing more than an aesthetic light with roughly the brightness of a bonfire
/obj/structure/bloodsucker/lighting/brazier
	name = "brazier"
	desc = "It's bright and crackling, yet there's a hint of constraint to its somber flame."
	icon_state = "brazier_lit"
	base_icon_state = "brazier"
	light_power = 1.125
	active_light_range = 6
	vamp_desc = "You alone can toggle this from afar by <b>ctrl-clicking</b> it."
	vassal_desc = "You can toggle this by <b>clicking</b> it."

	/// Our slightly quieter looping burn sound effect; copied over from 'bonfire.dm'
	var/datum/looping_sound/burning/brazier/burning_loop

/obj/structure/bloodsucker/lighting/brazier/Initialize()
	. = ..()
	burning_loop = new(src)

/obj/structure/bloodsucker/lighting/brazier/toggle(mob/user)
	. = ..()
	if(lit)
		particles = new /particles/brazier
		burning_loop.start()
	else
		QDEL_NULL(particles)
		burning_loop.stop()

//Quieter burning sound loop based off of 'code\datums\looping_sounds\burning.dm'
/datum/looping_sound/burning/brazier
	volume = 15
	ignore_walls = FALSE

/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests, making it appear very uncomfortable. Still, it might sell well at an antique shop."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a Bloodsucker's throne, any Bloodsucker sitting on it can remotely speak to their vassals by attempting to speak aloud."
	vamp_desc = "This is a blood throne, sitting on it will allow you to telepathically broadcast messages to all of your vassals by simply speaking. \n\
		Unlike other blood structures this throne may be unsecured by a <b>right-click</b> (just make sure it's unoccupied first)."
	vassal_desc = "This is a blood throne, it allows your master to telepathically speak to you and others who work under them."
	hunter_desc = "This blood-red seat allows vampires to telepathically communicate with those in their fold."

	///The static armrest that the throne has while someone is buckled onto it.
	var/static/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation, ROTATION_IGNORE_ANCHORED)
	if(!armrest)
		armrest = mutable_appearance('modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj_64.dmi', "thronearm")
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

/obj/structure/bloodsucker/bloodthrone/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(length(buckled_mobs))
		return
	if(anchored)
		prompt_unsecure(user)

/obj/structure/bloodsucker/bloodthrone/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += armrest

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.setDir(newdir)

	if(dir == NORTH)
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
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	target.pixel_y += 3
	update_appearance(UPDATE_ICON)

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	UnregisterSignal(user, COMSIG_MOB_SAY)
	return ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	. = ..()
	target.pixel_y -= 2
	update_appearance(UPDATE_OVERLAYS)

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = source
	if(!user.mind || !IS_BLOODSUCKER(user))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/rendered = span_cult_large("<b>[user.real_name]:</b> [message]")
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

/// Blood mirror wallframe item.
/obj/item/wallframe/blood_mirror
	name = "scarlet mirror"
	desc = "A pool of stilled blood kept secure between unanchored glass and silver. Attach it to a wall to use."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_mirror"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	result_path = /obj/structure/bloodsucker/mirror
	pixel_shift = 28

//Copied over from 'wall_mounted.dm' with necessary alterations
/obj/item/wallframe/blood_mirror/attach(turf/on_wall, mob/user)
	if(!IS_BLOODSUCKER(user))
		balloon_alert(user, "you don't understand its mounting mechanism!")
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(get_area(user) == bloodsuckerdatum.bloodsucker_lair_area)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
			span_notice("You attach [src] to the wall."),
			span_hear("You hear clicking."))
		var/floor_to_wall = get_dir(user, on_wall)

		var/obj/structure/bloodsucker/mirror/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
		hanging_object.setDir(floor_to_wall)
		if(pixel_shift)
			switch(floor_to_wall)
				if(NORTH)
					hanging_object.pixel_y = pixel_shift
				if(SOUTH)
					hanging_object.pixel_y = -pixel_shift
				if(EAST)
					hanging_object.pixel_x = pixel_shift
				if(WEST)
					hanging_object.pixel_x = -pixel_shift
		transfer_fingerprints_to(hanging_object)
		hanging_object.bolt(user)
		qdel(src)
	else
		balloon_alert(user, "you can only mount it while in your lair!")


/// Blood mirror, allows bloodsuckers to remotely observe their vassals. Vassals being observed gain red eyes.
/// Lots of code from regular mirrors has been copied over here for obvious reasons.
/obj/structure/bloodsucker/mirror
	name = "scarlet mirror"
	desc = "It bleeds with visions of a world rendered in red."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_mirror"
	movement_type = FLOATING
	density = FALSE
	anchored = TRUE
	integrity_failure = 0.5
	max_integrity = 200
	vamp_desc = "This is a blood mirror, it will allow you to see through the eyes of your vassals remotely (though it will cause said eyes to redden as a side effect.) \n\
		It is warded against usage by unvassalized mortals with teleportation magic that can rend psyches asunder at the cost of its own integrity."
	vassal_desc = "This is a magical blood mirror that Bloodsuckers alone may use to watch over their devotees.\n\
		Those unworthy of the mirror who haven't been sworn to the service of a Bloodsucker may anger it if they attempt to use it."
	hunter_desc = "This is a mirror cursed with blood, it allows vampires to spy upon their thralls. \n\
		 An incredibly shy mirror spirit has also been bound to it, so try not to look into it directly lest you wish to face a phantasmal panic response."
	light_system = OVERLAY_LIGHT //It glows a bit when in use.
	light_range = 2
	light_power = 1.5
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_on = FALSE

	/// Boolean indicating whether or not the mirror is actively being used to observe someone.
	var/in_use = FALSE
	/// The mob currently using the mirror to observe someone (if any.)
	var/mob/living/carbon/human/current_user = null
	/// The mob currently being observed by someone using the mirror (if any.)
	var/mob/living/carbon/human/current_observed = null
	/// The typepath of the action used to stop observing someone with the mirror.
	var/datum/action/innate/mirror_observe_stop/stop_observe = /datum/action/innate/mirror_observe_stop
	/// The original left eye color of the mob being observed.
	var/original_eye_color_left
	/// The original right eye color of the mob being observed.
	var/original_eye_color_right
	/// Boolean indicating whether or not the mirror is angry (see 'proc/katabasis' for more info.)
	var/mirror_will_not_forget_this = FALSE

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi', "blood_mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	var/datum/callback/can_reflect = CALLBACK(src, PROC_REF(can_reflect))
	var/list/update_signals = list(COMSIG_ATOM_BREAK)

	AddComponent(/datum/component/reflection, reflection_filter = reflection_filter, reflection_matrix = reflection_matrix, can_reflect = can_reflect, update_signals = update_signals)
	stop_observe = new stop_observe(src)
	register_context()

/obj/structure/bloodsucker/mirror/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(in_use)
		stop_observing(current_user, current_observed)
	QDEL_NULL(stop_observe)

/obj/structure/bloodsucker/mirror/examine(mob/user)
	. = ..()
	if(in_use)
		. += span_cult_bold("It's glowing ominously and [current_user] is staring into it!")

/obj/structure/bloodsucker/mirror/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(IS_BLOODSUCKER(user) && broken && in_range(source, user))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Clear Up"
		return CONTEXTUAL_SCREENTIP_SET

/// Default 'click_alt()' interaction overriden since mirrors are a unique case.
/obj/structure/bloodsucker/mirror/click_alt(mob/user)
	if(user == owner && user.Adjacent(src))
		if(broken)
			balloon_alert(user, "clear up [src]?")
		else
			balloon_alert(user, "unsecure [src]?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				if(broken) //Clear up broken mirrors by "gibbing" them.
					new /obj/effect/gibspawner/generic(src.loc)
					qdel(src)
				else
					new /obj/item/wallframe/blood_mirror(src.loc)
					playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
					user.visible_message(span_notice("[user.name] removes [src] from the wall."),
					span_notice("You remove [src] from the wall."),
					span_hear("You hear clicking."))
					qdel(src)

/// Copied from 'mirror/proc/can_reflect()'
/obj/structure/bloodsucker/mirror/proc/can_reflect(atom/movable/target)
	if(atom_integrity <= integrity_failure * max_integrity)
		return FALSE
	if(broken || !isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror, 28)

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	bolt()

/obj/structure/bloodsucker/mirror/broken
	icon_state = "blood_mirror_broken"

/obj/structure/bloodsucker/mirror/broken/Initialize(mapload)
	. = ..()
	atom_break(null, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror/broken, 28)

/obj/structure/bloodsucker/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken)
		return
	src.visible_message(span_warning("Blood spews out of the mirror as it breaks!"))
	if(!owner && !mapload) //If we don't have an owner then just clear ourself up completely.
		new /obj/effect/gibspawner/generic(src.loc)
		qdel(src)
		return //This return might not be necessary since we've already qdel'd the mirror... idk
	icon_state = "blood_mirror_broken"
	if(!mapload)
		playsound(src, SFX_SHATTER, 70, TRUE)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 60, TRUE)
	if(desc == initial(desc))
		desc = "It's a suspended pool of darkened fragments resembling a scab."

	new /obj/effect/decal/cleanable/blood/splatter(src.loc)
	broken = TRUE

/**
 * Proc used by blood mirrors to allow a user to see from the perspective of a target.
 *
 * Made using 'dullahan.dm', '_machinery.dm', 'camera_advanced.dm', 'drug_effects.dm', and a lot of
 * other files as references.
 */
/obj/structure/bloodsucker/mirror/proc/begin_observing(mob/living/carbon/human/user, mob/living/carbon/human/observed)
	if(!observed)
		balloon_alert(user, "chosen vassal doesn't exist!")
		return
	var/obj/item/organ/eyes/observed_eyes = observed.get_organ_slot(ORGAN_SLOT_EYES)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	stop_observe.Grant(user)
	START_PROCESSING(SSobj, src)
	user.add_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(TRUE)

	if(observed_eyes)
		user.reset_perspective(observed, TRUE)
		original_eye_color_left = observed.eye_color_left
		original_eye_color_right = observed.eye_color_right
		observed.eye_color_left = BLOODCULT_EYE
		observed.eye_color_right = BLOODCULT_EYE
		observed.update_body()
	else
		balloon_alert(user, "targeted vassal has no eyes!")
		return

	in_use = TRUE
	icon_state = "blood_mirror_active"
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 25, frequency = 0.75, use_reverb = TRUE)
	current_user = user
	current_observed = observed
	bloodsuckerdatum.blood_structure_in_use = src

/// Proc used by blood mirrors to stop observing. Arguments default to 'current_user' and 'current_observed'
/obj/structure/bloodsucker/mirror/proc/stop_observing(mob/living/carbon/human/user = current_user, mob/living/carbon/human/observed = current_observed)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	user.reset_perspective()
	stop_observe.Remove(user)
	STOP_PROCESSING(SSobj, src)
	user.remove_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(FALSE)

	observed.eye_color_left = original_eye_color_left
	observed.eye_color_right = original_eye_color_right
	observed.update_body()

	in_use = FALSE
	if(broken)
		icon_state = "blood_mirror_broken"
	else
		icon_state = /obj/structure/bloodsucker/mirror::icon_state
	playsound(user, 'sound/effects/portal/portal_travel.ogg', 25, frequency = -0.75, use_reverb = TRUE)
	current_user = null
	current_observed = null
	bloodsuckerdatum.blood_structure_in_use = null

/obj/structure/bloodsucker/mirror/process(seconds_per_tick)
	if(isdead(current_user))
		balloon_alert(current_user, "you are dead!")
		stop_observing()
		return

	if(isdead(current_observed))
		balloon_alert(current_user, "[current_observed] is dead!")
		stop_observing()
		return

	if(!current_observed.get_organ_slot(ORGAN_SLOT_EYES))
		balloon_alert(current_user, "[current_observed] has lost their eyes!")
		stop_observing()
		return

	if(broken)
		balloon_alert(current_user, "[src] has broken!")
		stop_observing()
		return

	if(!in_range(src, current_user))
		current_user.balloon_alert(current_user, "you have moved too far from [src]!")
		stop_observing()
		return

	if(!current_user.mind.has_antag_datum(/datum/antagonist/bloodsucker)) //Unlikely, but still...
		balloon_alert(current_user, "you aren't a bloodsucker anymore!")
		stop_observing()
		return

/obj/structure/bloodsucker/mirror/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(broken)
		balloon_alert(user, "it's broken!")
		return

	if(IS_BLOODSUCKER(user))
		var/datum/antagonist/bloodsucker/user_bloodsucker_datum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker, FALSE)

		if(!length(user_bloodsucker_datum.vassals))
			balloon_alert(user, "no vassals!")
			return
		if(in_use)
			balloon_alert(user, "already in use!")
			return
		if(user_bloodsucker_datum.blood_structure_in_use)
			balloon_alert(user, "already using a mirror!")
			return


		var/vassal_name_list[0]
		for(var/datum/antagonist/vassal/vassal_datum as anything in user_bloodsucker_datum.vassals)
			vassal_name_list[vassal_datum.owner.name] = vassal_datum
		var/chosen = tgui_input_list(user, "Select a vassal to watch over...", "Vassal Observation List", vassal_name_list)

		if(chosen)
			var/datum/antagonist/vassal/chosen_datum = vassal_name_list[chosen]
			var/mob/chosen_datum_current = chosen_datum.owner.current
			if(isdead(chosen_datum_current))
				balloon_alert(user, "[chosen_datum_current.name] is dead!")
				return

			begin_observing(user, chosen_datum_current)
			return
		else
			balloon_alert(user, "no vassal selected!")
			return

	if(IS_VASSAL(user))
		balloon_alert(user, "you don't know how to use it!")
		return

	if(mirror_will_not_forget_this)
		katabasis(user, TRUE)
		return

	to_chat(user, span_warning("You peer deeply into [src], but the reflection you see is not your own. You are stunned as <b>it begins reaching towards you...</b>"))

	var/mob/living/carbon/human/victim = user //(Just for code readability purposes.)
	var/original_victim_loc = victim.loc
	victim.Stun(6 SECONDS, TRUE)
	victim.playsound_local(get_turf(victim), 'sound/music/antag/bloodcult/ghost_whisper.ogg', 20, frequency = 5)
	flash_color(victim, flash_time = 80) //Defaults to cult stun flash, which fits here.
	sleep(5 SECONDS)//Wait five seconds and then...

	if(broken)		//...return if the mirror is broken...
		return
	if(!src)		//...return if the mirror has been completely destroyed...
		return
	if(victim.loc != original_victim_loc) //...return and become angry if the victim has been moved...
		visible_message(span_warning("A dark red silhouette appears in [src], but as it bangs against the glass in vain."))
		mirror_will_not_forget_this = TRUE
		playsound('sound/effects/glass/glasshit.ogg')
		return

	katabasis(victim) //...make the victim undergo katabasis otherwise.

/**
 * The mirror is trapped, and this proc represents the trap's effects.
 * In short, it will deal moderate damage to its victim, teleport them to a random (mostly safe) location on the station,
 * give them a deep-rooted fear of blood, give them a severe negative moodlet, and then shatter itself.
 *
 * * victim - The person affected by this proc.
 * * aggressive - Increases mirror damage if true.
 */
/obj/structure/bloodsucker/mirror/proc/katabasis(mob/living/carbon/human/victim, var/aggressive = FALSE)
	//Damage
	if((victim.maxHealth - victim.get_total_damage()) >= victim.crit_threshold)
		var/refined_damage_amount = (victim.maxHealth - victim.get_total_damage()) * (aggressive ? 0.45 : 0.35)
		victim.adjustBruteLoss(refined_damage_amount)

	//Break mirror
	atom_break()

	//Flavor
	var/turf/victim_turf = get_turf(victim)
	playsound(victim_turf, 'sound/effects/hallucinations/veryfar_noise.ogg', 100, frequency = 1.25, use_reverb = TRUE)
	victim.visible_message(span_danger("A red hand erupts from [src], dragging [victim.name] away through broken glass!"),
	span_bolddanger(span_big("A crimson palm envelops your face, and with a horrible jolt it pulls you into [src]!")),
	span_warning("You briefly hear the sound of glass breaking accompanied by an eerie, almost fluid gust and a sudden thump!"),
	)

	//Find a reasonable/safe area and teleport the victim to it
	var/turf/target_turf = get_safe_random_station_turf(typesof(/area/station/commons))
	if(!target_turf)
		target_turf = get_safe_random_station_turf(typesof(/area/station/hallway))
	if(!target_turf)
		target_turf = get_safe_random_station_turf()

	do_teleport(victim, target_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE)

	//Nightmare, trauma, and mood event
	victim.playsound_local(get_turf(victim), 'sound/music/antag/bloodcult/ghost_whisper.ogg', 5, frequency = 0.75)
	victim.Sleeping(6 SECONDS)
	sleep(6 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...you were dragged through an infinite expanse of carmine..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...within it all things were stagnant— clotting to no end..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...this place was where those of ages old once claimed their vitality..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("<b>...and soon, you're sure, those claims will be renewed.</b>"))
	victim.playsound_local(get_turf(victim), 'sound/effects/blob/blobattack.ogg', 60, frequency = -1)
	victim.gain_trauma(/datum/brain_trauma/mild/phobia/blood, TRAUMA_RESILIENCE_LOBOTOMY)
	victim.add_mood_event("blood_mirror", /datum/mood_event/bloodmirror)

/// The action button that allows players to stop using blood mirrors.
/datum/action/innate/mirror_observe_stop
	name = "Stop Overseeing"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blind"

/datum/action/innate/mirror_observe_stop/Activate()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/obj/structure/bloodsucker/mirror/our_mirror = bloodsuckerdatum.blood_structure_in_use

	if(!our_mirror)
		return

	our_mirror.stop_observing(our_mirror.current_user, our_mirror.current_observed)
