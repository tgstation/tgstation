/// Main controller for Khaaroot hivemind pseudo-antagonist system.
/// Attached to the infector (Apex Field Officer), manages thralls and provides TGUI control interface.
/datum/khaaroot_hivemind
	/// Weakref to the infector's mind
	var/datum/weakref/infector_ref
	/// List of weakrefs to thrall minds
	var/list/datum/weakref/thralls = list()
	/// Team datum for shared HUD
	var/datum/team/khaaroot_hivemind/team
	/// Whether the hivemind is active
	var/active = TRUE

/datum/khaaroot_hivemind/New(datum/mind/infector)
	infector_ref = WEAKREF(infector)
	team = new(infector)
	team.hivemind_ref = WEAKREF(src)
	infector.add_antag_datum(/datum/antagonist/khaaroot_source, team)

	var/mob/living/infector_mob = infector.current
	if(infector_mob)
		var/datum/action/cooldown/khaaroot_hivemind_comm/comm = new(src)
		comm.Grant(infector_mob)
		var/datum/action/cooldown/khaaroot_hivemind_panel/panel = new(src)
		panel.Grant(infector_mob)

/datum/khaaroot_hivemind/Destroy()
	QDEL_NULL(team)
	for(var/datum/weakref/ref in thralls)
		var/datum/mind/thrall = ref.resolve()
		if(thrall)
			thrall.remove_antag_datum(/datum/antagonist/khaaroot_thrall)
	thralls.Cut()
	infector_ref = null
	return ..()

/// Returns the infector mind, or null
/datum/khaaroot_hivemind/proc/get_infector()
	return infector_ref?.resolve()

/// Returns the infector mob, or null
/datum/khaaroot_hivemind/proc/get_infector_mob()
	var/datum/mind/mind = get_infector()
	return mind?.current

/// Infects a target mob, making them a thrall
/datum/khaaroot_hivemind/proc/infect(mob/living/carbon/human/target, mob/living/infector)
	if(!target || !infector)
		return FALSE
	if(!target.mind)
		to_chat(infector, span_warning("Цель не имеет разума для подчинения."))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		to_chat(infector, span_warning("Разум цели защищён от воздействия Кхаарут."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(infector, span_warning("Щит разума цели блокирует проникновение вируса."))
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/khaaroot_thrall))
		to_chat(infector, span_warning("Цель уже является частью улья Кхаарут."))
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/khaaroot_source))
		to_chat(infector, span_warning("Невозможно заразить источник улья."))
		return FALSE

	thralls += WEAKREF(target.mind)
	target.mind.add_antag_datum(/datum/antagonist/khaaroot_thrall, team)

	RegisterSignal(target.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_thrall_mind_transferred))
	RegisterSignals(target, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_thrall_update))

	to_chat(target, span_userdanger("Чужеродная воля пронзает ваш разум! Вы чувствуете непреодолимую связь с источником улья Кхаарут..."))
	to_chat(infector, span_notice("Вы успешно внедрили вирус Кхаарут в сознание [target.declent_ru(GENITIVE)]."))
	target.do_alert_animation()

	return TRUE

/// Removes a thrall from the hivemind
/datum/khaaroot_hivemind/proc/remove_thrall(datum/mind/thrall_mind, silent = FALSE)
	thralls -= WEAKREF(thrall_mind)
	if(thrall_mind)
		UnregisterSignal(thrall_mind, COMSIG_MIND_TRANSFERRED)
		if(thrall_mind.current)
			UnregisterSignal(thrall_mind.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
		thrall_mind.remove_antag_datum(/datum/antagonist/khaaroot_thrall)
		if(!silent)
			broadcast_message("[thrall_mind.name] исключён из улья Кхаарут.")

/// Kill a thrall remotely
/datum/khaaroot_hivemind/proc/kill_thrall(datum/mind/thrall_mind)
	var/mob/living/target = thrall_mind?.current
	if(!target)
		return FALSE
	if(target.stat == DEAD)
		return FALSE

	to_chat(target, span_userdanger("Ваша связь с ульем Кхаарут резко обрывается! Вирус в вашей крови начинает разрушать организм изнутри!"))
	target.visible_message(
		span_danger("[target.real_name] внезапно хватается за голову и падает!"),
		blind_message = span_hear("Вы слышите мучительный крик.")
	)

	target.adjust_oxy_loss(200, forced = TRUE)
	target.adjust_tox_loss(200, forced = TRUE)
	target.emote("scream", intentional = FALSE)

	addtimer(CALLBACK(src, PROC_REF(finish_kill), thrall_mind, WEAKREF(target)), 3 SECONDS)
	return TRUE

/datum/khaaroot_hivemind/proc/finish_kill(datum/mind/thrall_mind, datum/weakref/target_ref)
	var/mob/living/target = target_ref?.resolve()
	if(!target || target.stat == DEAD)
		return
	target.death(FALSE)
	remove_thrall(thrall_mind, silent = TRUE)
	broadcast_message("[thrall_mind.name] был умерщвлён через разрыв связи улья.")

/// Send a command/message to a specific thrall from the infector
/datum/khaaroot_hivemind/proc/send_command(datum/mind/thrall_mind, message, mob/living/sender)
	if(!thrall_mind?.current)
		return
	to_chat(thrall_mind.current, span_hypnophrase("<b>Источник улья приказывает:</b><br>«[message]»"))
	if(sender != thrall_mind.current)
		log_directed_talk(sender, thrall_mind.current, message, LOG_SAY, "khaaroot hivemind command")

/// Broadcast a message to all thralls and the infector
/datum/khaaroot_hivemind/proc/broadcast_message(message, mob/living/sender)
	var/is_infector_message = is_infector(sender)
	var/formatted
	if(is_infector_message)
		formatted = "<i><font color='#ff5500' size='+3'>\[Улей Кхаарут\] [sender]: [message]</font></i>"
	else
		formatted = "<i><font color='#ff5500'>\[Улей Кхаарут\] [sender ? "[sender]: " : ""][message]</font></i>"

	var/datum/mind/infector = get_infector()
	var/mob/living/infector_mob = infector?.current

	if(infector_mob)
		to_chat(infector_mob, formatted, type = MESSAGE_TYPE_RADIO, avoid_highlighting = infector_mob == sender)
		if(sender)
			sender.cast_tts(infector_mob, message, is_local = FALSE, effects = list(/datum/singleton/sound_effect/telepathy), channel_override = CHANNEL_TTS_TELEPATHY, check_deafness = FALSE)

	for(var/datum/weakref/ref in thralls)
		var/datum/mind/thrall = ref.resolve()
		var/mob/living/thrall_mob = thrall?.current
		if(thrall_mob)
			to_chat(thrall_mob, formatted, type = MESSAGE_TYPE_RADIO, avoid_highlighting = thrall_mob == sender)
			if(sender)
				sender.cast_tts(thrall_mob, message, is_local = FALSE, effects = list(/datum/singleton/sound_effect/telepathy), channel_override = CHANNEL_TTS_TELEPATHY, check_deafness = FALSE)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		var/sender_link = sender ? "[FOLLOW_LINK(recipient, sender)] " : ""
		to_chat(recipient, "[sender_link][formatted]", type = MESSAGE_TYPE_RADIO)

/// Get data for all thralls for TGUI
/datum/khaaroot_hivemind/proc/get_thralls_data()
	var/list/data = list()
	var/list/to_remove = list()
	for(var/datum/weakref/ref in thralls)
		var/datum/mind/thrall = ref.resolve()
		if(!thrall)
			to_remove += ref
			continue
		var/mob/living/mob = thrall.current
		if(!mob)
			to_remove += ref
			continue
		var/turf/T = get_turf(mob)
		var/area/A = T ? get_area(T) : null
		data += list(list(
			"name" = thrall.name,
			"ref" = REF(thrall),
			"status" = mob.stat == DEAD ? "Мёртв" : (IS_UNCONSCIOUS(mob) ? "Без сознания" : (mob.health <= mob.crit_threshold ? "Критическое" : "Активен")),
			"health" = round((mob.health / mob.maxHealth) * 100, 1),
			"location" = A ? A.name : "Неизвестно",
			"objective" = get_thrall_objective(thrall),
			"has_mob" = TRUE,
		))
	thralls -= to_remove
	return data

/// Handler for thrall mind transfer
/datum/khaaroot_hivemind/proc/on_thrall_mind_transferred(datum/mind/source, mob/old_body)
	SIGNAL_HANDLER
	if(old_body)
		UnregisterSignal(old_body, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	if(source.current)
		RegisterSignals(source.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_thrall_update))
	broadcast_message("Сигнал [source.name] изменился.")
	update_ui()

/// Handler for thrall state changes
/datum/khaaroot_hivemind/proc/on_thrall_update(datum/source)
	SIGNAL_HANDLER
	update_ui()

/// Checks if the given mob is the infector
/datum/khaaroot_hivemind/proc/is_infector(mob/user)
	if(!user)
		return FALSE
	var/datum/mind/infector = get_infector()
	return infector?.current == user

/// Updates all open UIs
/datum/khaaroot_hivemind/proc/update_ui()
	var/datum/mind/infector = get_infector()
	if(!infector?.current)
		return
	SStgui.update_uis(src)

/// Returns the current objective for a thrall
/datum/khaaroot_hivemind/proc/get_thrall_objective(datum/mind/thrall)
	var/datum/antagonist/khaaroot_thrall/antag = thrall?.has_antag_datum(/datum/antagonist/khaaroot_thrall)
	return antag?.thrall_objective || "Нет текущей цели"

/// Sets a new objective for a thrall
/datum/khaaroot_hivemind/proc/set_thrall_objective(datum/mind/thrall, objective_text)
	var/datum/antagonist/khaaroot_thrall/antag = thrall?.has_antag_datum(/datum/antagonist/khaaroot_thrall)
	if(!antag)
		return FALSE
	antag.thrall_objective = objective_text
	to_chat(thrall.current, span_hypnophrase("<b>Источник улья ставит новую цель:</b><br>«[objective_text]»"))
	return TRUE

// TGUI INTERACTION

/datum/khaaroot_hivemind/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KhaarootHivemind", "Улей Кхаарут")
		ui.open()

/datum/khaaroot_hivemind/ui_state(mob/user)
	return GLOB.always_state

/datum/khaaroot_hivemind/ui_status(mob/user, datum/ui_state/state)
	if(!is_infector(user) && !check_rights_for(user.client, R_ADMIN))
		return UI_CLOSE
	return ..()

/datum/khaaroot_hivemind/ui_static_data(mob/user)
	return list()

/datum/khaaroot_hivemind/ui_data(mob/user)
	var/list/data = list()

	data["thralls"] = get_thralls_data()
	data["thrall_count"] = length(thralls)

	return data

/datum/khaaroot_hivemind/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("send_command")
			var/datum/mind/target = find_thrall_mind(params["ref"])
			if(!target)
				return
			var/message = tgui_input_text(ui.user, "Введите команду для [target.name]:", "Команда улья", max_length = MAX_MESSAGE_LEN)
			if(!message)
				return
			send_command(target, message, ui.user)
			return TRUE

		if("set_objective")
			var/datum/mind/target = find_thrall_mind(params["ref"])
			if(!target)
				return
			var/objective = tgui_input_text(ui.user, "Введите цель для [target.name]:", "Цель улья", max_length = MAX_MESSAGE_LEN)
			if(!objective)
				return
			set_thrall_objective(target, objective)
			return TRUE

		if("kill_thrall")
			var/datum/mind/target = find_thrall_mind(params["ref"])
			if(!target)
				return
			var/confirm = tgui_alert(ui.user, "Вы уверены, что хотите умертвить [target.name]? Это необратимо.", "Подтверждение", list("Да", "Нет"))
			if(confirm != "Да")
				return
			kill_thrall(target)
			return TRUE

		if("refresh")
			update_ui()
			return TRUE

/// Find a thrall mind by its REF string
/datum/khaaroot_hivemind/proc/find_thrall_mind(ref_string)
	for(var/datum/weakref/ref in thralls)
		var/datum/mind/mind = ref.resolve()
		if(mind && REF(mind) == ref_string)
			return mind
	return null


// ============================================================
//  ANTAGONIST DATUMS
// ============================================================

/// Hidden antagonist datum for the infector — provides HUD icon, team membership, and hivemind communication.
/// Does NOT appear in round-end reports or regular antagonist lists.
/datum/antagonist/khaaroot_source
	name = "источник Улья Кхаарут"
	roundend_category = "Улей Кхаарут"
	show_in_roundend = FALSE
	antagpanel_category = "Улей Кхаарут"
	show_in_antagpanel = FALSE
	show_to_ghosts = FALSE
	hud_icon = 'modular_bandastation/prime_only/icons/antag_hud.dmi'
	antag_hud_name = "khaaroot_source"
	ui_name = null
	pref_flag = NONE
	jobban_flag = NONE
	replace_banned = FALSE
	can_elimination_hijack = ELIMINATION_NEUTRAL

	/// Reference to the team
	var/datum/team/khaaroot_hivemind/team

/datum/antagonist/khaaroot_source/create_team(datum/team/kh_team)
	team = kh_team

/datum/antagonist/khaaroot_source/get_team()
	return team

/datum/antagonist/khaaroot_source/Destroy()
	team = null
	return ..()

/datum/antagonist/khaaroot_source/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	add_team_hud(target, /datum/antagonist/khaaroot_thrall)

/datum/antagonist/khaaroot_source/on_gain()
	. = ..()
	ADD_TRAIT(owner.current, TRAIT_UNCONVERTABLE, REF(src))

/datum/antagonist/khaaroot_source/on_removal()
	REMOVE_TRAIT(owner.current, TRAIT_UNCONVERTABLE, REF(src))
	return ..()


/// Antagonist datum for Khaaroot-infected thralls — provides HUD icon, team membership, hivemind communication, and configurable objective.
/datum/antagonist/khaaroot_thrall
	name = "заражённый Ульем Кхаарут"
	roundend_category = "Улей Кхаарут"
	show_in_roundend = FALSE
	antagpanel_category = "Улей Кхаарут"
	show_in_antagpanel = FALSE
	show_to_ghosts = FALSE
	hud_icon = 'modular_bandastation/prime_only/icons/antag_hud.dmi'
	antag_hud_name = "khaaroot_thrall"
	ui_name = null
	pref_flag = NONE
	jobban_flag = NONE
	replace_banned = FALSE
	can_elimination_hijack = ELIMINATION_NEUTRAL

	/// Reference to the team
	var/datum/team/khaaroot_hivemind/team

	/// Custom objective set by the infector
	var/thrall_objective

/datum/antagonist/khaaroot_thrall/create_team(datum/team/kh_team)
	team = kh_team

/datum/antagonist/khaaroot_thrall/get_team()
	return team

/datum/antagonist/khaaroot_thrall/Destroy()
	team = null
	return ..()

/datum/antagonist/khaaroot_thrall/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	add_team_hud(target, type)

/datum/antagonist/khaaroot_thrall/on_gain()
	. = ..()
	ADD_TRAIT(owner.current, TRAIT_FEARLESS, REF(src))

	var/datum/khaaroot_hivemind/hivemind = team?.hivemind_ref?.resolve()
	if(hivemind)
		var/datum/action/cooldown/khaaroot_hivemind_comm/comm = new(hivemind)
		comm.Grant(owner.current)
		hivemind.broadcast_message("[owner.name] принят в Улей Кхаарут.")

/datum/antagonist/khaaroot_thrall/on_removal()
	. = ..()
	REMOVE_TRAIT(owner.current, TRAIT_FEARLESS, REF(src))


// ============================================================
//  TEAM DATUM
// ============================================================

/// Team datum for Khaaroot hivemind — enables shared HUD icons between infector and thralls.
/datum/team/khaaroot_hivemind
	name = "\improper Khaaroot Hivemind"
	member_name = "участник улья"
	show_roundend_report = FALSE
	/// Weakref back to the hivemind controller
	var/datum/weakref/hivemind_ref
