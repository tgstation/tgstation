// see _DEFINES/is_helpers.dm for mob type checks

///Find the mob at the bottom of a buckle chain
/mob/proc/lowest_buckled_mob()
	. = src
	if(buckled && ismob(buckled))
		var/mob/Buckled = buckled
		. = Buckled.lowest_buckled_mob()

///Convert a PRECISE ZONE into the BODY_ZONE
/proc/check_zone(zone)
	if(!zone)
		return BODY_ZONE_CHEST
	switch(zone)
		if(BODY_ZONE_PRECISE_EYES)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_L_HAND)
			zone = BODY_ZONE_L_ARM
		if(BODY_ZONE_PRECISE_R_HAND)
			zone = BODY_ZONE_R_ARM
		if(BODY_ZONE_PRECISE_L_FOOT)
			zone = BODY_ZONE_L_LEG
		if(BODY_ZONE_PRECISE_R_FOOT)
			zone = BODY_ZONE_R_LEG
		if(BODY_ZONE_PRECISE_GROIN)
			zone = BODY_ZONE_CHEST
	return zone

/**
 * Return the zone or randomly, another valid zone
 *
 * probability controls the chance it chooses the passed in zone, or another random zone
 * defaults to 80
 */
/proc/ran_zone(zone, probability = 80, list/weighted_list)
	if(prob(probability))
		zone = check_zone(zone)
	else
		zone = pick_weight(weighted_list ? weighted_list : list(BODY_ZONE_HEAD = 1, BODY_ZONE_CHEST = 1, BODY_ZONE_L_ARM = 4, BODY_ZONE_R_ARM = 4, BODY_ZONE_L_LEG = 4, BODY_ZONE_R_LEG = 4))
	return zone


/**
 * More or less ran_zone, but only returns bodyzones that the mob /actually/ has.
 *
 * * blacklisted_parts - allows you to specify zones that will not be chosen. eg: list(BODY_ZONE_CHEST, BODY_ZONE_R_LEG)
 * * * !!!! blacklisting BODY_ZONE_CHEST is really risky since it's the only bodypart guarunteed to ALWAYS exists  !!!!
 * * * !!!! Only do that if you're REALLY CERTAIN they have limbs, otherwise we'll CRASH() !!!!
 *
 * * ran_zone has a base prob(80) to return the base_zone (or if null, BODY_ZONE_CHEST) vs something in our generated list of limbs.
 * * this probability is overriden when either blacklisted_parts contains BODY_ZONE_CHEST and we aren't passed a base_zone (since the default fallback for ran_zone would be the chest in that scenario), or if even_weights is enabled.
 * * you can also manually adjust this probability by altering base_probability
 *
 * * even_weights - ran_zone has a 40% chance (after the prob(80) mentioned above) of picking a limb, vs the torso & head which have an additional 10% chance.
 * * Setting even_weight to TRUE will make it just a straight up pick() between all possible bodyparts.
 *
 */
/mob/proc/get_random_valid_zone(base_zone, base_probability = 80, list/blacklisted_parts, even_weights, bypass_warning)
	return BODY_ZONE_CHEST //even though they don't really have a chest, let's just pass the default of check_zone to be safe.

/mob/living/carbon/get_random_valid_zone(base_zone, base_probability = 80, list/blacklisted_parts, even_weights, bypass_warning)
	var/list/limbs = list()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		var/limb_zone = part.body_zone //cache the zone since we're gonna check it a ton.
		if(limb_zone in blacklisted_parts)
			continue
		if(even_weights)
			limbs[limb_zone] = 1
			continue
		if(limb_zone == BODY_ZONE_CHEST || limb_zone == BODY_ZONE_HEAD)
			limbs[limb_zone] = 1
		else
			limbs[limb_zone] = 4

	if(base_zone && !(check_zone(base_zone) in limbs))
		base_zone = null //check if the passed zone is infact valid

	var/chest_blacklisted
	if((BODY_ZONE_CHEST in blacklisted_parts))
		chest_blacklisted = TRUE
		if(bypass_warning && !limbs.len)
			CRASH("limbs is empty and the chest is blacklisted. this may not be intended!")
	return (((chest_blacklisted && !base_zone) || even_weights) ? pick_weight(limbs) : ran_zone(base_zone, base_probability, limbs))


///Would this zone be above the neck
/proc/above_neck(zone)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	if(zones.Find(zone))
		return TRUE
	else
		return FALSE

/**
 * Convert random parts of a passed in message to stars
 *
 * * phrase - the string to convert
 * * probability - probability any character gets changed
 *
 * This proc is dangerously laggy, avoid it or die
 */
/proc/stars(phrase, probability = 25)
	if(probability <= 0)
		return phrase
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/char = ""
	for(var/i = 1, i <= leng, i += length(char))
		char = phrase[i]
		if(char == " " || !prob(probability))
			. += char
		else
			. += "*"
	return sanitize(.)

/**
 * Turn text into complete gibberish!
 *
 * text is the inputted message, replace_characters will cause original letters to be replaced and chance are the odds that a character gets modified.
 */
/proc/Gibberish(text, replace_characters = FALSE, chance = 50)
	text = html_decode(text)
	. = ""
	var/rawchar = ""
	var/letter = ""
	var/lentext = length(text)
	for(var/i = 1, i <= lentext, i += length(rawchar))
		rawchar = letter = text[i]
		if(prob(chance))
			if(replace_characters)
				letter = ""
			for(var/j in 1 to rand(0, 2))
				letter += pick("#", "@", "*", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*")
		. += letter
	return sanitize(.)

#define TILES_PER_SECOND 0.7
///Shake the camera of the person viewing the mob SO REAL!
///Takes the mob to shake, the time span to shake for, and the amount of tiles we're allowed to shake by in tiles
///Duration isn't taken as a strict limit, since we don't trust our coders to not make things feel shitty. So it's more like a soft cap.
/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength*world.icon_size
	var/min = -(strength*world.icon_size)

	//How much time to allot for each pixel moved
	var/time_scalar = (1 / world.icon_size) * TILES_PER_SECOND
	var/last_x = oldx
	var/last_y = oldy

	var/time_spent = 0
	while(time_spent < duration)
		//Get a random pos in our box
		var/x_pos = rand(min, max) + oldx
		var/y_pos = rand(min, max) + oldy

		//We take the smaller of our two distances so things still have the propencity to feel somewhat jerky
		var/time = round(max(min(abs(last_x - x_pos), abs(last_y - y_pos)) * time_scalar, 1))

		if (time_spent == 0)
			animate(C, pixel_x=x_pos, pixel_y=y_pos, time=time)
		else
			animate(pixel_x=x_pos, pixel_y=y_pos, time=time)

		last_x = x_pos
		last_y = y_pos
		//We go based on time spent, so there is a chance we'll overshoot our duration. Don't care
		time_spent += time

	animate(pixel_x=oldx, pixel_y=oldy, time=3)

#undef TILES_PER_SECOND

///Find if the message has the real name of any user mob in the mob_list
/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(M.real_name == msg)
			return M
	return 0

///Find the first name of a mob from the real name with regex
/mob/proc/first_name()
	var/static/regex/firstname = new("^\[^\\s-\]+") //First word before whitespace or "-"
	firstname.Find(real_name)
	return firstname.match

/// Find the last name of a mob from the real name with regex
/mob/proc/last_name()
	var/static/regex/lasttname = new("\[^\\s-\]+$") //First word before whitespace or "-"
	lasttname.Find(real_name)
	return lasttname.match

///Returns a mob's real name between brackets. Useful when you want to display a mob's name alongside their real name
/mob/proc/get_realname_string()
	if(real_name && real_name != name)
		return " \[[real_name]\]"
	return ""

// moved out of admins.dm because things other than admin procs were calling this.
/// Returns TRUE if the game has started and we're either an AI with a 0th law, or we're someone with a special role/antag datum
/proc/is_special_character(mob/M)
	if(!SSticker.HasRoundStarted())
		return FALSE
	if(!istype(M))
		return FALSE
	if(iscyborg(M)) //as a borg you're now beholden to your laws rather than greentext
		return FALSE
	if(isAI(M))
		var/mob/living/silicon/ai/A = M
		return (A.laws?.zeroth && (A.mind?.special_role || !isnull(M.mind?.antag_datums)))
	if(M.mind?.special_role || !isnull(M.mind?.antag_datums)) //they have an antag datum!
		return TRUE
	return FALSE

/**
 * Fancy notifications for ghosts
 *
 * The kitchen sink of notification procs
 *
 * Arguments:
 * * message
 * * ghost_sound sound to play
 * * enter_link Href link to enter the ghost role being notified for
 * * source The source of the notification
 * * alert_overlay The alert overlay to show in the alert message
 * * action What action to take upon the ghost interacting with the notification, defaults to NOTIFY_JUMP
 * * flashwindow Flash the byond client window
 * * ignore_key  Ignore keys if they're in the GLOB.poll_ignore list
 * * header The header of the notifiaction
 * * notify_suiciders If it should notify suiciders (who do not qualify for many ghost roles)
 * * notify_volume How loud the sound should be to spook the user
 */
/proc/notify_ghosts(message, ghost_sound, enter_link, atom/source, mutable_appearance/alert_overlay, action = NOTIFY_JUMP, flashwindow = TRUE, ignore_mapload = TRUE, ignore_key, header, notify_suiciders = TRUE, notify_volume = 100) //Easy notification of ghosts.

	if(ignore_mapload && SSatoms.initialized != INITIALIZATION_INNEW_REGULAR) //don't notify for objects created during a map load
		return
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!notify_suiciders && HAS_TRAIT(ghost, TRAIT_SUICIDED))
			continue
		if(ignore_key && (ghost.ckey in GLOB.poll_ignore[ignore_key]))
			continue
		var/orbit_link
		if(source && action == NOTIFY_ORBIT)
			orbit_link = " <a href='?src=[REF(ghost)];follow=[REF(source)]'>(Orbit)</a>"
		to_chat(ghost, span_ghostalert("[message][(enter_link) ? " [enter_link]" : ""][orbit_link]"))
		if(ghost_sound)
			SEND_SOUND(ghost, sound(ghost_sound, volume = notify_volume))
		if(flashwindow)
			window_flash(ghost.client)
		if(!source)
			continue
		var/atom/movable/screen/alert/notify_action/alert = ghost.throw_alert("[REF(source)]_notify_action", /atom/movable/screen/alert/notify_action)
		if(!alert)
			continue
		var/ui_style = ghost.client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
		if(ui_style)
			alert.icon = ui_style2icon(ui_style)
		if (header)
			alert.name = header
		alert.desc = message
		alert.action = action
		alert.target = source
		if(!alert_overlay)
			alert_overlay = new(source)
			alert_overlay.pixel_x = 0
			alert_overlay.pixel_y = 0
			var/icon/size_check = icon(source.icon, source.icon_state)
			var/scale = 1
			var/width = size_check.Width()
			var/height = size_check.Height()
			if(width > world.icon_size)
				alert_overlay.pixel_x = -(world.icon_size / 2) * ((width - world.icon_size) / world.icon_size)
			if(height > world.icon_size)
				alert_overlay.pixel_y = -(world.icon_size / 2) * ((height - world.icon_size) / world.icon_size)
			if(width > world.icon_size || height > world.icon_size)
				if(width >= height)
					scale = world.icon_size / width
				else
					scale = world.icon_size / height
			alert_overlay.transform = alert_overlay.transform.Scale(scale)
		alert_overlay.appearance_flags |= TILE_BOUND
		alert_overlay.layer = FLOAT_LAYER
		alert_overlay.plane = FLOAT_PLANE
		alert.add_overlay(alert_overlay)

/**
 * Heal a robotic body part on a mob
 */
/proc/item_heal_robotic(mob/living/carbon/human/human, mob/user, brute_heal, burn_heal)
	var/obj/item/bodypart/affecting = human.get_bodypart(check_zone(user.zone_selected))
	if(!affecting || IS_ORGANIC_LIMB(affecting))
		to_chat(user, span_warning("[affecting] is already in good condition!"))
		return FALSE
	var/brute_damage = brute_heal > burn_heal //changes repair text based on how much brute/burn was supplied
	if((brute_heal > 0 && affecting.brute_dam > 0) || (burn_heal > 0 && affecting.burn_dam > 0))
		if(affecting.heal_damage(brute_heal, burn_heal, BODYTYPE_ROBOTIC))
			human.update_damage_overlays()
		user.visible_message(span_notice("[user] fixes some of the [brute_damage ? "dents on" : "burnt wires in"] [human]'s [affecting.name]."), \
			span_notice("You fix some of the [brute_damage ? "dents on" : "burnt wires in"] [human == user ? "your" : "[human]'s"] [affecting.name]."))
		return TRUE //successful heal


///Is the passed in mob a ghost with admin powers, doesn't check for AI interact like isAdminGhost() used to
/proc/isAdminObserver(mob/user)
	if(!user) //Are they a mob? Auto interface updates call this with a null src
		return
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	return TRUE

///Is the passed in mob an admin ghost WITH AI INTERACT enabled
/proc/isAdminGhostAI(mob/user)
	if(!isAdminObserver(user))
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE

/**
 * Offer control of the passed in mob to dead player
 *
 * Automatic logging and uses poll_candidates_for_mob, how convenient
 */
/proc/offer_control(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	if(usr)
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([ADMIN_LOOKUPFLW(M)]) to ghosts")
	var/poll_message = "Do you want to play as [M.real_name]?"
	if(M.mind)
		poll_message = "[poll_message] Job: [M.mind.assigned_role.title]."
		if(M.mind.special_role)
			poll_message = "[poll_message] Status: [M.mind.special_role]."
		else
			var/datum/antagonist/A = M.mind.has_antag_datum(/datum/antagonist/)
			if(A)
				poll_message = "[poll_message] Status: [A.name]."
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob(poll_message, ROLE_PAI, FALSE, 10 SECONDS, M)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(M)])")
		M.ghostize(FALSE)
		M.key = C.key
		M.client?.init_verbs()
		return TRUE
	else
		to_chat(M, "There were no ghosts willing to take control.")
		message_admins("No ghosts were willing to take control of [ADMIN_LOOKUPFLW(M)])")
		return FALSE

///Clicks a random nearby mob with the source from this mob
/mob/proc/click_random_mob()
	var/list/nearby_mobs = list()
	for(var/mob/living/L in range(1, src))
		if(L != src)
			nearby_mobs |= L
	if(nearby_mobs.len)
		var/mob/living/T = pick(nearby_mobs)
		ClickOn(T)

///Can the mob hear
/mob/proc/can_hear()
	. = TRUE

/**
 * Examine text for traits shared by multiple types.
 *
 * I wish examine was less copypasted. (oranges say, be the change you want to see buddy)
 */
/mob/proc/common_trait_examine()
	if(HAS_TRAIT(src,TRAIT_HUSK))
		. += span_warning("This body has been reduced to a grotesque husk.")

/**
 * Get the list of keywords for policy config
 *
 * This gets the type, mind assigned roles and antag datums as a list, these are later used
 * to send the user relevant headadmin policy config
 */
/mob/proc/get_policy_keywords()
	. = list()
	. += "[type]"
	if(mind)
		if(mind.assigned_role.policy_index)
			. += mind.assigned_role.policy_index
		. += mind.assigned_role.title //A bit redunant, but both title and policy index are used
		. += mind.special_role //In case there's something special leftover, try to avoid
		for(var/datum/antagonist/antag_datum as anything in mind.antag_datums)
			. += "[antag_datum.type]"

///Can the mob see reagents inside of containers?
/mob/proc/can_see_reagents()
	return stat == DEAD || has_unlimited_silicon_privilege || HAS_TRAIT(src, TRAIT_REAGENT_SCANNER) //Dead guys and silicons can always see reagents

///Can this mob hold items
/mob/proc/can_hold_items(obj/item/I)
	return length(held_items)

/// Returns this mob's default lighting alpha
/mob/proc/default_lighting_cutoff()
	if(client?.combo_hud_enabled && client?.prefs?.toggles & COMBOHUD_LIGHTING)
		return LIGHTING_CUTOFF_FULLBRIGHT
	return initial(lighting_cutoff)

/// Returns a generic path of the object based on the slot
/proc/get_path_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return /obj/item/storage/backpack
		if(ITEM_SLOT_MASK)
			return /obj/item/clothing/mask
		if(ITEM_SLOT_NECK)
			return /obj/item/clothing/neck
		if(ITEM_SLOT_HANDCUFFED)
			return /obj/item/restraints/handcuffs
		if(ITEM_SLOT_LEGCUFFED)
			return /obj/item/restraints/legcuffs
		if(ITEM_SLOT_BELT)
			return /obj/item/storage/belt
		if(ITEM_SLOT_ID)
			return /obj/item/card/id/advanced
		if(ITEM_SLOT_EARS)
			return /obj/item/clothing/ears
		if(ITEM_SLOT_EYES)
			return /obj/item/clothing/glasses
		if(ITEM_SLOT_GLOVES)
			return /obj/item/clothing/gloves
		if(ITEM_SLOT_HEAD)
			return /obj/item/clothing/head
		if(ITEM_SLOT_FEET)
			return /obj/item/clothing/shoes
		if(ITEM_SLOT_OCLOTHING)
			return /obj/item/clothing/suit
		if(ITEM_SLOT_ICLOTHING)
			return /obj/item/clothing/under
		if(ITEM_SLOT_LPOCKET)
			return /obj/item
		if(ITEM_SLOT_RPOCKET)
			return /obj/item
		if(ITEM_SLOT_SUITSTORE)
			return /obj/item
	return null

/// Returns a client from a mob, mind or client
/proc/get_player_client(player)
	if(ismob(player))
		var/mob/player_mob = player
		player = player_mob.client
	else if(istype(player, /datum/mind))
		var/datum/mind/player_mind = player
		player = player_mind.current.client
	if(!istype(player, /client))
		return
	return player

/proc/health_percentage(mob/living/mob)
	var/divided_health = mob.health / mob.maxHealth
	if(iscyborg(mob) || islarva(mob))
		divided_health = (mob.health + mob.maxHealth) / (mob.maxHealth * 2)
	else if(iscarbon(mob) || isAI(mob) || isbrain(mob))
		divided_health = abs(HEALTH_THRESHOLD_DEAD - mob.health) / abs(HEALTH_THRESHOLD_DEAD - mob.maxHealth)
	return divided_health * 100

/**
 * Generates a log message when a user manually changes their targeted zone.
 * Only need to one of new_target or old_target, and the other will be auto populated with the current selected zone.
 */
/mob/proc/log_manual_zone_selected_update(source, new_target, old_target)
	if(!new_target && !old_target)
		CRASH("Called log_manual_zone_selected_update without specifying a new or old target")

	old_target ||= zone_selected
	new_target ||= zone_selected
	if(old_target == new_target)
		return

	var/list/data = list(
		"new_target" = new_target,
		"old_target" = old_target,
	)

	if(mind?.assigned_role)
		data["assigned_role"] = mind.assigned_role.title
	if(job)
		data["assigned_job"] = job

	var/atom/handitem = get_active_held_item()
	if(handitem)
		data["active_item"] = list(
			"type" = handitem.type,
			"name" = handitem.name,
		)

	var/atom/offhand = get_inactive_held_item()
	if(offhand)
		data["offhand_item"] = list(
			"type" = offhand.type,
			"name" = offhand.name,
		)

	logger.Log(
		LOG_CATEGORY_TARGET_ZONE_SWITCH,
		"[key_name(src)] manually changed selected zone",
		data,
	)
