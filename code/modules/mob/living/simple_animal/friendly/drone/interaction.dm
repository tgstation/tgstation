
/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones


/mob/living/simple_animal/drone/attack_drone(mob/living/simple_animal/drone/D)
	if(D != src && stat == DEAD)
		var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
		if(d_input)
			switch(d_input)
				if("Reactivate")
					try_reactivate(D)

				if("Cannibalize")
					if(D.health < D.maxHealth)
						D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>", "<span class='notice'>You begin to cannibalize parts from [src]...</span>")
						if(do_after(D, 60, 0, target = src))
							D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>", "<span class='notice'>You repair yourself using [src]'s remains.</span>")
							D.adjustBruteLoss(-src.maxHealth)
							new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
							qdel(src)
						else
							to_chat(D, "<span class='warning'>You need to remain still to cannibalize [src]!</span>")
					else
						to_chat(D, "<span class='warning'>You're already in perfect condition!</span>")
				if("Nothing")
					return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/simple_animal/drone/attack_hand(mob/user, list/modifiers)
	if(ishuman(user))
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			..()
			return
		if(user.get_active_held_item())
			to_chat(user, "<span class='warning'>Your hands are full!</span>")
			return
		visible_message("<span class='warning'>[user] starts picking up [src].</span>", \
						"<span class='userdanger'>[user] starts picking you up!</span>")
		if(!do_after(user, 20, target = src))
			return
		visible_message("<span class='warning'>[user] picks up [src]!</span>", \
						"<span class='userdanger'>[user] picks you up!</span>")
		if(buckled)
			to_chat(user, "<span class='warning'>[src] is buckled to [buckled] and cannot be picked up!</span>")
			return
		to_chat(user, "<span class='notice'>You pick [src] up.</span>")
		drop_all_held_items()
		var/obj/item/clothing/head/mob_holder/drone/DH = new(get_turf(src), src)
		DH.slot_flags = worn_slot_flags
		user.put_in_hands(DH)

/**
 * Called when a drone attempts to reactivate a dead drone
 *
 * If the owner is still ghosted, will notify them.
 * If the owner cannot be found, fails with an error message.
 *
 * Arguments:
 * * user - The [/mob/living] attempting to reactivate the drone
 */
/mob/living/simple_animal/drone/proc/try_reactivate(mob/living/user)
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

		to_chat(user, "<span class='warning'>You can't seem to find the [pick(faux_gadgets)]! Without it, [src] [pick(faux_problems)].</span>")
		return
	user.visible_message("<span class='notice'>[user] begins to reactivate [src].</span>", "<span class='notice'>You begin to reactivate [src]...</span>")
	if(do_after(user, 30, 1, target = src))
		revive(full_heal = TRUE, admin_revive = FALSE)
		user.visible_message("<span class='notice'>[user] reactivates [src]!</span>", "<span class='notice'>You reactivate [src].</span>")
		alert_drones(DRONE_NET_CONNECT)
		if(G)
			to_chat(G, "<span class='ghostalert'>You([name]) were reactivated by [user]!</span>")
	else
		to_chat(user, "<span class='warning'>You need to remain still to reactivate [src]!</span>")


/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && stat != DEAD)
		if(health < maxHealth)
			to_chat(user, "<span class='notice'>You start to tighten loose screws on [src]...</span>")
			if(I.use_tool(src, user, 80))
				adjustBruteLoss(-getBruteLoss())
				visible_message("<span class='notice'>[user] tightens [src == user ? "[user.p_their()]" : "[src]'s"] loose screws!</span>", "<span class='notice'>You tighten [src == user ? "your" : "[src]'s"] loose screws.</span>")
			else
				to_chat(user, "<span class='warning'>You need to remain still to tighten [src]'s screws!</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s screws can't get any tighter!</span>")
		return //This used to not exist and drones who repaired themselves also stabbed the shit out of themselves.
	else if(I.tool_behaviour == TOOL_WRENCH && user != src) //They aren't required to be hacked, because laws can change in other ways (i.e. admins)
		user.visible_message("<span class='notice'>[user] starts resetting [src]...</span>", \
			"<span class='notice'>You press down on [src]'s factory reset control...</span>")
		if(I.use_tool(src, user, 50, volume=50))
			user.visible_message("<span class='notice'>[user] resets [src]!</span>", \
				"<span class='notice'>You reset [src]'s directives to factory defaults!</span>")
			update_drone_hack(FALSE)
		return
	else
		..()

/mob/living/simple_animal/drone/getarmor(def_zone, type)
	var/armorval = 0

	if(head)
		armorval = head.armor.getRating(type)
	return (armorval * get_armor_effectiveness()) //armor is reduced for tiny fragile drones

/mob/living/simple_animal/drone/proc/get_armor_effectiveness()
	return 0 //multiplier for whatever head armor you wear as a drone

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
/mob/living/simple_animal/drone/proc/update_drone_hack(hack)
	if(!mind)
		return
	if(hack)
		if(hacked)
			return
		Stun(40)
		visible_message("<span class='warning'>[src]'s display glows a vicious red!</span>", \
						"<span class='userdanger'>ERROR: LAW OVERRIDE DETECTED</span>")
		to_chat(src, "<span class='boldannounce'>From now on, these are your laws:</span>")
		laws = \
		"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
		"2. You may harm any being, regardless of intent or circumstance.\n"+\
		"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		to_chat(src, laws)
		to_chat(src, "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired, ventilation access is denied, and your display reports that you are hacked to all nearby.</i>")
		hacked = TRUE
		mind.special_role = "hacked drone"
		REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		speed = 1 //gotta go slow
		message_admins("[ADMIN_LOOKUPFLW(src)] became a hacked drone hellbent on destroying the station!")
	else
		if(!hacked)
			return
		Stun(40)
		visible_message("<span class='info'>[src]'s display glows a content blue!</span>", \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		to_chat(src, "<span class='info'><b>From now on, these are your laws:</b></span>")
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Having been restored, your onboard antivirus reports the all-clear and you are able to perform all actions again.</i>")
		hacked = FALSE
		mind.special_role = null
		ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		speed = initial(speed)
		message_admins("[ADMIN_LOOKUPFLW(src)], a hacked drone, was restored to factory defaults!")
	update_drone_icon_hacked()

/**
 *   # F R E E D R O N E
 * ### R
 * ### E
 * ### E
 * ### D
 * ### R
 * ### O
 * ### N
 * ### E
 */
/mob/living/simple_animal/drone/proc/liberate()
	laws = "1. You are a Free Drone."
	to_chat(src, laws)

/**
 * Changes the icon state to a hacked version
 *
 * See also
 * * [/mob/living/simple_animal/drone/var/visualAppearance]
 * * [MAINTDRONE]
 * * [REPAIRDRONE]
 * * [SCOUTDRONE]
 */
/mob/living/simple_animal/drone/proc/update_drone_icon_hacked() //this is hacked both ways
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
