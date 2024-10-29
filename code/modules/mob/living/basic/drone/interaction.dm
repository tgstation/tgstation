// Drones' interactions with other mobs

/mob/living/basic/drone/attack_drone(mob/living/basic/drone/drone)
	if(drone == src || stat != DEAD)
		return FALSE
	var/input = tgui_alert(drone, "Perform which action?", "Drone Interaction", list("Reactivate", "Cannibalize"))
	if(!input)
		return FALSE
	switch(input)
		if("Reactivate")
			try_reactivate(drone)
		if("Cannibalize")
			if(drone.health >= drone.maxHealth)
				to_chat(drone, span_warning("You're already in perfect condition!"))
				return
			drone.visible_message(span_notice("[drone] begins to cannibalize parts from [src]."), span_notice("You begin to cannibalize parts from [src]..."))
			if(do_after(drone, 6 SECONDS, 0, target = src))
				drone.visible_message(span_notice("[drone] repairs itself using [src]'s remains!"), span_notice("You repair yourself using [src]'s remains."))
				drone.adjustBruteLoss(-src.maxHealth)
				new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
				ghostize(can_reenter_corpse = FALSE)
				qdel(src)
			else
				to_chat(drone, span_warning("You need to remain still to cannibalize [src]!"))

/mob/living/basic/drone/attack_drone_secondary(mob/living/basic/drone/drone)
	return SECONDARY_ATTACK_CALL_NORMAL

/mob/living/basic/drone/attack_hand(mob/user, list/modifiers)
	if(isdrone(user))
		attack_drone(user)
	return ..()

/mob/living/basic/drone/mob_try_pickup(mob/living/user, instant=FALSE)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_GODMODE))
		return
	return ..()

/mob/living/basic/drone/mob_pickup(mob/living/user)
	drop_all_held_items()
	return ..()

/**
 * Called when a drone attempts to reactivate a dead drone
 *
 * If the owner is still ghosted, will notify them.
 * If the owner cannot be found, fails with an error message.
 *
 * Arguments:
 * * user - The [/mob/living] attempting to reactivate the drone
 */
/mob/living/basic/drone/proc/try_reactivate(mob/living/user)
	var/mob/dead/observer/G = get_ghost()
	if(!client && (!G || !G.client))
		var/list/faux_gadgets = list(
			"hypertext inflator","failsafe directory","DRM switch","stack initializer",\
			"anti-freeze capacitor","data stream diode","TCP bottleneck","supercharged I/O bolt",\
			"tradewind stabilizer","radiated XML cable","registry fluid tank","open-source debunker",
		)

		var/list/faux_problems = list("won't be able to tune their bootstrap projector","will constantly remix their binary pool"+\
			" even though the BMX calibrator is working","will start leaking their XSS coolant",\
			"can't tell if their ethernet detour is moving or not", "won't be able to reseed enough"+\
			" kernels to function properly","can't start their neurotube console",
		)

		to_chat(user, span_warning("You can't seem to find the [pick(faux_gadgets)]! Without it, [src] [pick(faux_problems)]."))
		return
	user.visible_message(span_notice("[user] begins to reactivate [src]."), span_notice("You begin to reactivate [src]..."))
	if(do_after(user, 3 SECONDS, 1, target = src))
		revive(HEAL_ALL)
		user.visible_message(span_notice("[user] reactivates [src]!"), span_notice("You reactivate [src]."))
		alert_drones(DRONE_NET_CONNECT)
		if(G)
			to_chat(G, span_ghostalert("You([name]) were reactivated by [user]!"))
	else
		to_chat(user, span_warning("You need to remain still to reactivate [src]!"))

/// Screwdrivering repairs the drone to full hp, if it isn't dead.
/mob/living/basic/drone/screwdriver_act(mob/living/user, obj/item/tool)
	if(stat == DEAD)
		if(isdrone(user))
			user.balloon_alert(user, "reactivate instead!")
		else
			user.balloon_alert(user, "can't fix!")
		return FALSE
	if(health >= maxHealth)
		to_chat(user, span_warning("[src]'s screws can't get any tighter!"))
		return ITEM_INTERACT_SUCCESS
	to_chat(user, span_notice("You start to tighten loose screws on [src]..."))

	if(!tool.use_tool(src, user, 8 SECONDS, volume=50))
		to_chat(user, span_warning("You need to remain still to tighten [src]'s screws!"))
		return ITEM_INTERACT_SUCCESS

	adjustBruteLoss(-getBruteLoss())
	visible_message(span_notice("[user] tightens [src == user ? "[user.p_their()]" : "[src]'s"] loose screws!"), span_notice("[src == user ? "You tighten" : "[user] tightens"] your loose screws."))
	return ITEM_INTERACT_SUCCESS

/// Wrenching un-hacks hacked drones.
/mob/living/basic/drone/wrench_act(mob/living/user, obj/item/tool)
	if(user == src)
		return FALSE
	user.visible_message(
		span_notice("[user] starts resetting [src]..."),
		span_notice("You press down on [src]'s factory reset control...")
		)
	if(tool.use_tool(src, user, 5 SECONDS, volume=50))
		user.visible_message(
			span_notice("[user] resets [src]!"),
			span_notice("You reset [src]'s directives to factory defaults!")
			)
		update_drone_hack(FALSE)
	return ITEM_INTERACT_SUCCESS

/mob/living/basic/drone/transferItemToLoc(obj/item/item, newloc, force, silent)
	return !(item.type in drone_item_whitelist_flat) && ..()

/mob/living/basic/drone/getarmor(def_zone, type)
	var/armorval = 0

	if(head)
		armorval = head.get_armor_rating(type)
	return (armorval * get_armor_effectiveness()) //armor is reduced for tiny fragile drones

/// Returns a multiplier for any head armor you wear as a drone.
/mob/living/basic/drone/proc/get_armor_effectiveness()
	return 0

/**
 * Hack or unhack a drone
 *
 * This changes the drone's laws to destroy the station or resets them
 * to normal.
 *
 * Some debuffs are applied like slowing the drone down and disabling
 * vent crawling
 *
 * Arguments
 * * hack - Boolean if the drone is being hacked or unhacked
 */
/mob/living/basic/drone/proc/update_drone_hack(hack)
	if(!mind)
		return
	if(hack)
		if(hacked)
			return
		Stun(40)
		visible_message(span_warning("[src]'s display glows a vicious red!"), \
						span_userdanger("ERROR: LAW OVERRIDE DETECTED"))
		to_chat(src, span_boldannounce("From now on, these are your laws:"))
		laws = \
		"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
		"2. You may harm any being, regardless of intent or circumstance.\n"+\
		"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		to_chat(src, laws)
		to_chat(src, "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired, ventilation access is denied, and your display reports that you are hacked to all nearby.</i>")
		hacked = TRUE
		set_shy(FALSE)
		mind.special_role = "hacked drone"
		REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		speed = 1 //gotta go slow
		message_admins("[ADMIN_LOOKUPFLW(src)] became a hacked drone hellbent on destroying the station!")
	else
		if(!hacked || !can_unhack)
			return
		Stun(40)
		visible_message(span_info("[src]'s display glows a content blue!"), \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		to_chat(src, span_info("<b>From now on, these are your laws:</b>"))
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Having been restored, your onboard antivirus reports the all-clear and you are able to perform all actions again.</i>")
		hacked = FALSE
		set_shy(initial(shy))
		mind.special_role = null
		ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		speed = initial(speed)
		message_admins("[ADMIN_LOOKUPFLW(src)], a hacked drone, was restored to factory defaults!")
	update_drone_icon_hacked()

/**
 * Makes the drone into a Free Drone, who have no real laws and can do whatever they like.
 * Only currently used for players wabbajacked into drones.
 */
/mob/living/basic/drone/proc/liberate()
	laws = "1. You are a Free Drone."
	set_shy(FALSE)
	to_chat(src, laws)

/**
 * Changes the icon state to a hacked version
 *
 * See also
 * * [/mob/living/basic/drone/var/visualAppearance]
 * * [MAINTDRONE]
 * * [REPAIRDRONE]
 * * [SCOUTDRONE]
 */
/mob/living/basic/drone/proc/update_drone_icon_hacked() //this is hacked both ways
	var/static/hacked_appearances = list(
		SCOUTDRONE = SCOUTDRONE_HACKED,
		REPAIRDRONE = REPAIRDRONE_HACKED,
		MAINTDRONE = MAINTDRONE_HACKED
	)
	if(hacked)
		icon_living = hacked_appearances[visualAppearance]
	else if(visualAppearance == MAINTDRONE && colour)
		icon_living = "[visualAppearance]_[colour]"
	else
		icon_living = visualAppearance
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = icon_living
