// AI (i.e. game AI, not the AI player) controlled bots
/mob/living/basic/bot
	name = "Bot"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "hygienebot"
	base_icon_state = "hygienebot"
	layer = MOB_LAYER
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)
	has_unlimited_silicon_privilege = TRUE
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE //no default canpush
	pass_flags = PASSFLAPS
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	faction = list("neutral", "silicon", "turret")
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 0.9

	speed = 1
	ai_controller = /datum/ai_controller/basic_controller/bot

	///Bot status flags
	var/bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_PAI_CONTROLLABLE | BOT_MODE_AUTOPATROL
	///Bot-related cover flags on the Bot to deal with what has been done to their cover, including emagging.
	var/bot_cover_flags = BOT_COVER_LOCKED
	///Description of the current task of the bot. Set by the AI
	var/current_status_description = "Inactive"

	///The Robot arm attached to this robot - has a 50% chance to drop on death.
	var/robot_arm = /obj/item/bodypart/r_arm/robot
	///People currently looking into a bot's UI panel.
	var/list/users = list()
	///The inserted (if any) pAI in this bot.
	var/obj/item/pai_card/paicard
	///The type of bot it is, for radio control.
	var/bot_type = NONE

	///Innate access uses an internal ID card.
	var/obj/item/card/id/access_card = null
	///Access required to access this Bot's maintenance protocols
	var/maints_access_required = list(ACCESS_ROBOTICS)
	///Additonal access given to player-controlled bots.
	var/list/player_access = list()
	///All initial access this bot started with.
	var/list/base_access = list()

	///Small name of what the bot gets messed with when getting hacked/emagged.
	var/hackables = "system circuits"

	///The bot's radio, for speaking to people.
	var/obj/item/radio/internal_radio
	///which channels can the bot listen to
	var/radio_key = null
	///The bot's default radio channel
	var/radio_channel = RADIO_CHANNEL_COMMON

	///The type of data HUD the bot uses. Diagnostic by default.
	var/data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC

/mob/living/basic/bot/Initialize(mapload)
	. = ..()
	GLOB.basic_bots_list += src

	// Give bots a fancy new ID card that can hold any access.
	access_card = new /obj/item/card/id/advanced/simple_bot(src)
	// This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	access_card.set_access(list(ACCESS_ROBOTICS))
	internal_radio = new /obj/item/radio(src)
	if(radio_key)
		internal_radio.keyslot = new radio_key
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0 // anything greater will have the bot broadcast the channel as if it were saying it out loud.
	internal_radio.recalculateChannels()

	//Adds bot to the diagnostic HUD system
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()

	//If a bot has its own HUD (for player bots), provide it.
	if(!isnull(data_hud_type))
		var/datum/atom_hud/datahud = GLOB.huds[data_hud_type]
		datahud.show_to(src)

/mob/living/basic/bot/Destroy()
	GLOB.basic_bots_list -= src
	if(paicard)
		ejectpai()
	QDEL_NULL(internal_radio)
	QDEL_NULL(access_card)
	return ..()

/// Returns the current activity of the bot
/mob/living/basic/bot/proc/get_current_behavior_description()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		return paicard ? "pAI Controlled" : "Autonomous"
	else if(!(bot_mode_flags & BOT_MODE_ON))
		return "Inactive"
	else
		return current_status_description

/mob/living/basic/bot/proc/drop_part(obj/item/drop_item, dropzone)
	var/obj/item/item_to_drop
	if(ispath(drop_item))
		item_to_drop = new drop_item(dropzone)
	else
		item_to_drop = drop_item
		item_to_drop.forceMove(dropzone)

	if(istype(item_to_drop, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/dropped_cell = item_to_drop
		dropped_cell.charge = 0
		dropped_cell.update_appearance()

	else if(istype(item_to_drop, /obj/item/storage))
		var/obj/item/storage/storage_to_drop = item_to_drop
		storage_to_drop.contents = list()

	else if(istype(item_to_drop, /obj/item/gun/energy))
		var/obj/item/gun/energy/dropped_gun = item_to_drop
		dropped_gun.cell.charge = 0
		dropped_gun.update_appearance()


/mob/living/basic/bot/proc/turn_on()
	if(stat)
		return FALSE
	bot_mode_flags |= BOT_MODE_ON
	REMOVE_TRAIT(src, TRAIT_INCAPACITATED, POWER_LACK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, POWER_LACK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, POWER_LACK_TRAIT)
	set_light_on(TRUE)
	update_appearance()
	balloon_alert(src, "turned on")
	diag_hud_set_botstat()
	return TRUE

/mob/living/basic/bot/proc/turn_off()
	bot_mode_flags &= ~BOT_MODE_ON
	ADD_TRAIT(src, TRAIT_INCAPACITATED, POWER_LACK_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, POWER_LACK_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, POWER_LACK_TRAIT)
	set_light_on(FALSE)
	balloon_alert(src, "turned off")
	update_appearance()

/mob/living/basic/bot/Bump(atom/A) //Leave no door unopened!
	. = ..()
	if((istype(A, /obj/machinery/door/airlock) || istype(A, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = A
		if(D.check_access(access_card))
			D.open()

/mob/living/basic/bot/proc/reset_bot_access()
	access_card.set_access(base_access)

/mob/living/basic/bot/proc/check_access(mob/living/user, obj/item/card/id)
	if(user.has_unlimited_silicon_privilege || isAdminGhostAI(user)) // Silicon and Admins always have access.
		return TRUE
	if(!maints_access_required) // No requirements to access it.
		return TRUE
	if(!(bot_cover_flags & BOT_COVER_LOCKED)) // Unlocked.
		return TRUE

	var/obj/item/card/id/used_id = id || user.get_idcard(TRUE)

	if(!used_id || !used_id.access)
		return FALSE

	for(var/requested_access in maints_access_required)
		if(requested_access in used_id.access)
			return TRUE
	return FALSE

/mob/living/basic/bot/bee_friendly()
	return TRUE

/mob/living/basic/bot/death(gibbed)
	explode()
	return ..()

/mob/living/basic/bot/proc/explode()
	visible_message(span_boldnotice("[src] blows apart!"))
	do_sparks(3, TRUE, src)
	var/atom/location_destroyed = drop_location()
	if(prob(50))
		drop_part(robot_arm, location_destroyed)
	qdel(src)

/mob/living/basic/bot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(bot_cover_flags & BOT_COVER_LOCKED) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		bot_cover_flags &= ~BOT_COVER_LOCKED
		to_chat(user, span_notice("You bypass [src]'s [hackables]."))
		return
	if(!(bot_cover_flags & BOT_COVER_LOCKED) && bot_cover_flags & BOT_COVER_OPEN) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		bot_cover_flags |= BOT_COVER_EMAGGED
		bot_cover_flags &= ~BOT_COVER_LOCKED //Manually emagging the bot locks out the panel.
		bot_mode_flags &= ~BOT_MODE_REMOTE_ENABLED //Manually emagging the bot also locks the AI from controlling it.
		//bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
		to_chat(src, span_userdanger("(#$*#$^^( OVERRIDE DETECTED"))
		if(user)
			log_combat(user, src, "emagged")
		return
	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		to_chat(user, span_warning("You need to open maintenance panel first!"))

/mob/living/basic/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."
	. += span_notice("Its maintenance panel is [bot_cover_flags & BOT_COVER_OPEN ? "open" : "closed"].")
	. += span_info("You can use a <b>screwdriver</b> to [bot_cover_flags & BOT_COVER_OPEN ? "close" : "open"] it.")
	if(bot_cover_flags & BOT_COVER_OPEN)
		. += span_notice("Its control panel is [bot_cover_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"].")
		var/is_sillycone = issilicon(user)
		if(!(bot_cover_flags & BOT_COVER_EMAGGED) && (is_sillycone || user.Adjacent(src)))
			. += span_info("Alt-click [is_sillycone ? "" : "or use your ID on "]it to [bot_cover_flags & BOT_COVER_LOCKED ? "un" : ""]lock its control panel.")
	if(paicard)
		. += span_notice("It has a pAI device installed.")
		if(!(bot_cover_flags & BOT_COVER_OPEN))
			. += span_info("You can use a <b>hemostat</b> to remove it.")


///Can be an element
/mob/living/basic/bot/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && prob(10))
		new /obj/effect/decal/cleanable/oil(loc)
	. = ..()

/mob/living/basic/bot/updatehealth()
	..()
	diag_hud_set_bothealth()

/mob/living/basic/bot/med_hud_set_health()
	return //we use a different hud

/mob/living/basic/bot/med_hud_set_status()
	return //we use a different hud

/mob/living/basic/bot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!user.combat_mode)
		ui_interact(user)
	else
		return ..()

/mob/living/basic/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		ui_interact(user)
	else
		to_chat(user, span_warning("[src]'s interface is not responding!"))

///The messages that can be sent by a PDA to control a bot
/mob/living/basic/bot/proc/bot_control(command, mob/user, list/user_access = list())
	if(!(bot_mode_flags & BOT_MODE_ON) || bot_cover_flags & BOT_COVER_EMAGGED || !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return TRUE //ACCESS DENIED
	if(client)
		bot_pda_control_message(command, user)
	// process control input
	switch(command)
		///Make this into procs
		if("patroloff")
			bot_mode_flags &= ~BOT_MODE_AUTOPATROL

		if("patrolon")
			bot_mode_flags |= BOT_MODE_AUTOPATROL

		if("summon")
			//bot_reset()
			//summon_target = get_turf(user)
			if(user_access.len != 0)
				access_card.set_access(user_access + base_access) //Adds the user's access, if any.
			speak("Responding.", radio_channel)

		if("ejectpai")
			ejectpairemote(user)
	return


///The message a client sees when it gets a PDA command
/mob/living/basic/bot/proc/bot_pda_control_message(command, user)
	switch(command)
		if("patroloff")
			to_chat(src, "<span class='warning big'>STOP PATROL</span>")
		if("patrolon")
			to_chat(src, "<span class='warning big'>START PATROL</span>")
		if("summon")
			to_chat(src, "<span class='warning big'>PRIORITY ALERT:[user] in [get_area_name(user)]!</span>")
		if("stop")
			to_chat(src, "<span class='warning big'>STOP!</span>")

		if("go")
			to_chat(src, "<span class='warning big'>GO!</span>")

		if("home")
			to_chat(src, "<span class='warning big'>RETURN HOME!</span>")
		if("ejectpai")
			return
		else
			to_chat(src, span_warning("Unidentified control sequence received:[command]"))

/mob/living/basic/bot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SimpleBot", name)
		ui.open()

/mob/living/basic/bot/ui_data(mob/user)
	var/list/data = list()
	data["can_hack"] = (issilicon(user) || isAdminGhostAI(user))
	data["custom_controls"] = list()
	data["emagged"] = bot_cover_flags & BOT_COVER_EMAGGED
	data["has_access"] = check_access(user)
	data["locked"] = bot_cover_flags & BOT_COVER_LOCKED
	data["pai"] = list()
	data["settings"] = list()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["pai"]["allow_pai"] = bot_mode_flags & BOT_MODE_PAI_CONTROLLABLE
		data["pai"]["card_inserted"] = paicard
		data["settings"]["airplane_mode"] = !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)
		data["settings"]["maintenance_lock"] = !(bot_cover_flags & BOT_COVER_OPEN)
		data["settings"]["power"] = bot_mode_flags & BOT_MODE_ON
		data["settings"]["patrol_station"] = bot_mode_flags & BOT_MODE_AUTOPATROL
	return data

// Actions received from TGUI
/mob/living/basic/bot/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!check_access(usr))
		to_chat(usr, span_warning("Access denied."))
		return

	if(action == "lock")
		bot_cover_flags ^= BOT_COVER_LOCKED

	switch(action)
		if("power")
			if(bot_mode_flags & BOT_MODE_ON)
				turn_off()
			else
				turn_on()
		if("maintenance")
			bot_cover_flags ^= BOT_COVER_OPEN
		if("patrol")
			bot_mode_flags ^= BOT_MODE_AUTOPATROL
			//bot_reset()
		if("airplane")
			bot_mode_flags ^= BOT_MODE_REMOTE_ENABLED
		if("hack")
			if(!(issilicon(usr) || isAdminGhostAI(usr)))
				return
			if(!(bot_cover_flags & BOT_COVER_EMAGGED))
				bot_cover_flags |= (BOT_COVER_EMAGGED|BOT_COVER_HACKED|BOT_COVER_LOCKED)
				to_chat(usr, span_warning("You overload [src]'s [hackables]."))
				message_admins("Safety lock of [ADMIN_LOOKUPFLW(src)] was disabled by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)]")
				usr.log_message("disabled safety lock of [src] in [AREACOORD(src)].", LOG_GAME)
				//bot_reset()
			else if(!(bot_cover_flags & BOT_COVER_HACKED))
				to_chat(usr, span_boldannounce("You fail to repair [src]'s [hackables]."))
			else
				bot_cover_flags &= ~(BOT_COVER_EMAGGED|BOT_COVER_HACKED)
				to_chat(usr, span_notice("You reset the [src]'s [hackables]."))
				usr.log_message("re-enabled safety lock of [src] in [AREACOORD(src)].", LOG_GAME)
				//bot_reset()
		if("eject_pai")
			if(paicard)
				to_chat(usr, span_notice("You eject [paicard] from [initial(src.name)]."))
				ejectpai(usr)

/mob/living/basic/bot/proc/topic_denied(mob/user) //Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	if(!user.canUseTopic(src, !issilicon(user)))
		return TRUE
	// 0 for access, 1 for denied.
	if(bot_cover_flags & BOT_COVER_EMAGGED) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!(bot_cover_flags & BOT_COVER_HACKED)) //Manually emagged by a human - access denied to all.
			return TRUE
		else if(!issilicon(user) && !isAdminGhostAI(user)) //Bot is hacked, so only silicons and admins are allowed access.
			return TRUE
	return FALSE

/mob/living/basic/bot/update_icon_state()
	icon_state = "[initial(icon_state)][bot_mode_flags & BOT_MODE_ON]"
	return ..()


/mob/living/basic/bot/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	unlock_with_id(user)

/mob/living/basic/bot/proc/unlock_with_id(mob/user)
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		to_chat(user, span_danger("ERROR"))
		return
	if(bot_cover_flags & BOT_COVER_OPEN)
		to_chat(user, span_warning("Please close the access panel before [bot_cover_flags & BOT_COVER_LOCKED ? "un" : ""]locking it."))
		return
	if(!check_access(user))
		to_chat(user, span_warning("Access denied."))
		return
	bot_cover_flags ^= BOT_COVER_LOCKED
	to_chat(user, span_notice("Controls are now [bot_cover_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"]."))
	return TRUE

/mob/living/basic/bot/screwdriver_act(mob/living/user, obj/item/tool)
	if(bot_cover_flags & BOT_COVER_LOCKED)
		to_chat(user, span_warning("The maintenance panel is locked!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(src)
	bot_cover_flags ^= BOT_COVER_OPEN
	to_chat(user, span_notice("The maintenance panel is now [bot_cover_flags & BOT_COVER_OPEN ? "opened" : "closed"]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/basic/bot/welder_act(mob/living/user, obj/item/tool)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.combat_mode)
		return FALSE

	if(health >= maxHealth)
		to_chat(user, span_warning("[src] does not need a repair!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!(bot_cover_flags & BOT_COVER_OPEN))
		to_chat(user, span_warning("Unable to repair with the maintenance panel closed!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(tool.use_tool(src, user, 0 SECONDS, volume=40))
		adjust_health(-10)
		user.visible_message(span_notice("[user] repairs [src]!"),span_notice("You repair [src]."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/basic/bot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.GetID())
		unlock_with_id(user)
	else if(istype(attacking_item, /obj/item/pai_card))
		insertpai(user, attacking_item)
	else if(attacking_item.tool_behaviour == TOOL_HEMOSTAT && paicard)
		if(bot_cover_flags & BOT_COVER_OPEN)
			to_chat(user, span_warning("Close the access panel before manipulating the personality slot!"))
		else
			to_chat(user, span_notice("You attempt to pull [paicard] free..."))
			if(do_after(user, 30, target = src))
				if (paicard)
					user.visible_message(span_notice("[user] uses [attacking_item] to pull [paicard] out of [initial(src.name)]!"),span_notice("You pull [paicard] out of [initial(src.name)] with [attacking_item]."))
					ejectpai(user)
	else
		if(attacking_item.force) //if force is non-zero
			do_sparks(5, TRUE, src)
		..()

/mob/living/basic/bot/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	if(Proj && (Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(prob(75) && Proj.damage > 0)
			do_sparks(5, TRUE, src)
	return ..()

/mob/living/basic/bot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/was_on = bot_mode_flags & BOT_MODE_ON ? TRUE : FALSE
	stat |= EMPED
	new /obj/effect/temp_visual/emp(loc)
	if(paicard)
		paicard.emp_act(severity)
		src.visible_message(span_notice("[paicard] is flies out of [initial(src.name)]!"), span_warning("You are forcefully ejected from [initial(src.name)]!"))
		ejectpai(0)
	if(bot_mode_flags & BOT_MODE_ON)
		turn_off()
	addtimer(CALLBACK(src, .proc/emp_reset, was_on), severity * 30 SECONDS)

/mob/living/basic/bot/proc/emp_reset(was_on)
	stat &= ~EMPED
	if(was_on)
		turn_on()

/mob/living/basic/bot/proc/speak(message,channel) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!(bot_mode_flags & BOT_MODE_ON)) || (!message))
		return
	if(channel && internal_radio.channels[channel])// Use radio if we have channel key
		internal_radio.talk_into(src, message, channel)
	else
		say(message)


///Make into a datum
/mob/living/basic/bot/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(.)
		return

	if(message_mods[MODE_HEADSET])
		internal_radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT)
		internal_radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		internal_radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE

/mob/living/basic/bot/proc/insertpai(mob/user, obj/item/pai_card/card)
	if(paicard)
		to_chat(user, span_warning("A [paicard] is already inserted!"))
		return
	if(bot_cover_flags & BOT_COVER_LOCKED || !(bot_cover_flags & BOT_COVER_OPEN))
		to_chat(user, span_warning("The personality slot is locked."))
		return
	if(!(bot_mode_flags & BOT_MODE_PAI_CONTROLLABLE) || key) //Not pAI controllable or is already player controlled.
		to_chat(user, span_warning("[src] is not compatible with [card]!"))
		return
	if(!card.pai || !card.pai.mind)
		to_chat(user, span_warning("[card] is inactive."))
		return
	if(!user.transferItemToLoc(card, src))
		return
	paicard = card
	user.visible_message(span_notice("[user] inserts [card] into [src]!"), span_notice("You insert [card] into [src]."))
	paicard.pai.mind.transfer_to(src)
	to_chat(src, span_notice("You sense your form change as you are uploaded into [src]."))
	name = paicard.pai.name
	faction = user.faction.Copy()
	log_combat(user, paicard.pai, "uploaded to [initial(src.name)],")
	return TRUE

/mob/living/basic/bot/proc/ejectpai(mob/user = null, announce = TRUE)
	if(paicard)
		if(mind && paicard.pai)
			mind.transfer_to(paicard.pai)
		else if(paicard.pai)
			paicard.pai.key = key
		else
			ghostize(0) // The pAI card that just got ejected was dead.
		key = null
		paicard.forceMove(loc)
		if(user)
			log_combat(user, paicard.pai, "ejected from [initial(src.name)],")
		else
			log_combat(src, paicard.pai, "ejected")
		if(announce)
			to_chat(paicard.pai, span_notice("You feel your control fade as [paicard] ejects from [initial(src.name)]."))
		paicard = null
		name = initial(src.name)
		faction = initial(faction)

/mob/living/basic/bot/proc/ejectpairemote(mob/user)
	if(check_access(user) && paicard)
		speak("Ejecting personality chip.", radio_channel)
		ejectpai(user)


/mob/living/basic/bot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	// If we have any bonus player accesses, add them to our internal ID card.
	if(length(player_access))
		access_card.add_access(player_access)
	diag_hud_set_botmode()

/mob/living/basic/bot/revive(full_heal = FALSE, admin_revive = FALSE)
	if(..())
		update_appearance()
		. = TRUE


/mob/living/basic/bot/ghost()
	if(stat != DEAD) // Only ghost if we're doing this while alive, the pAI probably isn't dead yet.
		return ..()
	if(paicard && (!client || stat == DEAD))
		ejectpai(0)


/mob/living/basic/bot/rust_heretic_act()
	adjustBruteLoss(400)

/mob/living/basic/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/basic/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(bot_mode_flags & BOT_MODE_ON)
		holder.icon_state = "hudstat"
	else if(stat) //Generally EMP causes this
		holder.icon_state = "hudoffline"
	else //Bot is off
		holder.icon_state = "huddead2"

/mob/living/basic/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	var/image/holder = hud_list[DIAG_BOT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(client) //If the bot is player controlled, it will not be following mode logic!
		holder.icon_state = "hudsentient"
		return
	/*
	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			holder.icon_state = "hudcalled"
		if(BOT_CLEANING, BOT_REPAIRING, BOT_HEALING) //Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			holder.icon_state = "hudworking"
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			holder.icon_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT) //STOP RIGHT THERE, CRIMINAL SCUM!
			holder.icon_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""
	*/

