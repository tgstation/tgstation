/// Ratwood's game master tools (admin/admin.dm, verbs/randomverbs.dm) on TG's admin verbs, in Rogue Systems: player
/// quality, triumphs, sending someone back to the lobby, sleeping them, and a panel of all that for one player.

/// Ratwood's way of picking whom to act on: a character in the round, a connected player, or a typed ckey.
/proc/rogue_admin_pick_ckey(client/user, title)
	var/how = tgui_alert(user, "Pick the player by...", title, list("Character", "Player", "Ckey"))
	switch(how)
		if("Character")
			var/list/characters = list()
			for(var/mob/living/character in GLOB.player_list)
				characters["[character.real_name] ([character.ckey])"] = character.ckey
			if(!length(characters))
				to_chat(user, span_warning("No characters in the round."), confidential = TRUE)
				return
			var/picked = tgui_input_list(user, "Which character?", title, sort_list(characters))
			return picked && characters[picked]
		if("Player")
			var/list/ckeys = list()
			for(var/client/player as anything in GLOB.clients)
				ckeys += player.ckey
			return tgui_input_list(user, "Which player?", title, sort_list(ckeys))
		if("Ckey")
			return ckey(tgui_input_text(user, "Which ckey?", title, max_length = MAX_NAME_LEN))

/// Asks for a PQ change and makes it (Ratwood's adjust_pq): an amount, and a reason; 0 with a reason is a note.
/proc/rogue_admin_adjust_pq(client/user, ckey)
	if(!rogue_player_known(ckey))
		to_chat(user, span_warning("[ckey] has never played here."), confidential = TRUE)
		return
	var/amount = tgui_input_number(user, "How much to change [ckey]'s PQ by? (0 to just add a note)", "Adjust PQ", 0, 600, -600)
	if(isnull(amount))
		return
	var/reason = tgui_input_text(user, "A short reason for the change", "Adjust PQ", max_length = MAX_MESSAGE_LEN)
	if(!amount && !reason)
		return
	rogue_adjust_pq(amount, ckey, user.key, reason)

/proc/rogue_admin_adjust_triumphs(client/user, ckey)
	if(!rogue_player_known(ckey))
		to_chat(user, span_warning("[ckey] has never played here."), confidential = TRUE)
		return
	var/old_count = rogue_get_triumphs(ckey)
	var/amount = tgui_input_number(user, "How many triumphs to add to [ckey] (negative to take)? They have [old_count].", "Adjust Triumphs", 0, 100000, -100000)
	if(!amount)
		return
	var/count = rogue_adjust_triumphs(ckey, amount)
	log_admin("[key_name(user)]: Modified [ckey]'s Triumphs by [amount], from [old_count] to [count]")
	message_admins(span_adminnotice("[key_name_admin(user)]: Modified [ckey]'s Triumphs by [amount], from [old_count] to [count]"))

/// Sends a player back to the lobby from any body (Ratwood's admin_send_back_to_lobby; TG's own does it only from a ghost):
/// their role and class free a place again and their name leaves the manifest. The body stays, without its player, unless
/// it is deleted.
/proc/rogue_send_back_to_lobby(mob/target, client/admin, delete_body = FALSE)
	if(!target?.ckey)
		if(admin)
			to_chat(admin, span_warning("[target] has no player to send back."), confidential = TRUE)
		return FALSE
	if(isliving(target) && target.mind)
		var/datum/job/job = target.mind.assigned_role
		if(job && !istype(job, /datum/job/unassigned))
			job.current_positions = max(0, job.current_positions - 1)
		var/mob/living/carbon/human/human = target
		if(istype(human) && human.rockhill_advclass)
			human.rockhill_advclass.taken = max(0, human.rockhill_advclass.taken - 1)
		GLOB.manifest.remove(target.real_name)
		target.mind.rogue_leave_acquaintances()
	if(admin)
		log_admin("[key_name(admin)] has sent [key_name(target)] back to the Lobby.")
		message_admins("[key_name_admin(admin)] has sent [key_name_admin(target)] back to the Lobby.")
	var/mob/dead/new_player/lobby = new()
	lobby.ckey = target.ckey
	if(delete_body || isobserver(target))
		qdel(target)
	return TRUE

/proc/rogue_admin_send_back_to_lobby(client/user, mob/target)
	if(!target?.ckey)
		to_chat(user, span_warning("[target] has no player."), confidential = TRUE)
		return
	if(isnewplayer(target))
		to_chat(user, span_warning("[key_name(target)] is in the lobby already."), confidential = TRUE)
		return
	var/delete_body = FALSE
	if(isliving(target))
		var/answer = tgui_alert(user, "Send [key_name(target)] back to the Lobby? Their role frees a place again.", "Back to Lobby", list("Keep the body", "Delete the body", "Cancel"))
		if(answer != "Keep the body" && answer != "Delete the body")
			return
		delete_body = (answer == "Delete the body")
	else if(tgui_alert(user, "Send [key_name(target)] back to the Lobby?", "Back to Lobby", list("Yes", "No")) != "Yes")
		return
	rogue_send_back_to_lobby(target, user, delete_body)

/proc/rogue_admin_toggle_sleeping(client/user, mob/living/target)
	if(target.IsSleeping())
		target.SetSleeping(0)
		target.set_resting(FALSE, instant = TRUE)
	else
		target.SetSleeping(999999)
	message_admins(span_danger("Admin [key_name_admin(user)] toggled [key_name_admin(target)]'s sleeping state!"))
	log_admin("[key_name(user)] toggled [key_name(target)]'s sleeping state.")

ADMIN_VERB(rogue_check_pq, R_ADMIN, "PQ - Check", "Show a player's PQ and its log.", ADMIN_CATEGORY_ROGUE)
	var/ckey = rogue_admin_pick_ckey(user, "Check PQ")
	if(!ckey)
		return
	if(!rogue_player_known(ckey))
		to_chat(user, span_warning("[ckey] has never played here."), confidential = TRUE)
		return
	rogue_show_pq(user, ckey)
	BLACKBOX_LOG_ADMIN_VERB("Check PQ")

ADMIN_VERB(rogue_adjust_pq, R_ADMIN, "PQ - Adjust", "Raise or lower a player's PQ, or note something in its log.", ADMIN_CATEGORY_ROGUE)
	var/ckey = rogue_admin_pick_ckey(user, "Adjust PQ")
	if(ckey)
		rogue_admin_adjust_pq(user, ckey)
		BLACKBOX_LOG_ADMIN_VERB("Adjust PQ")

ADMIN_VERB(rogue_adjust_triumphs, R_ADMIN, "Adjust Triumphs", "Give or take a player's triumphs.", ADMIN_CATEGORY_ROGUE)
	var/ckey = rogue_admin_pick_ckey(user, "Adjust Triumphs")
	if(ckey)
		rogue_admin_adjust_triumphs(user, ckey)
		BLACKBOX_LOG_ADMIN_VERB("Adjust Triumphs")

ADMIN_VERB(rogue_back_to_lobby, R_ADMIN, "Back to Lobby", "Leave your body and go back to the lobby; your role frees a place again.", ADMIN_CATEGORY_ROGUE)
	if(isnewplayer(user.mob))
		return
	if(tgui_alert(user, "Go back to the lobby? Your body stays where it is.", "Back to Lobby", list("Yes", "No")) != "Yes")
		return
	rogue_send_back_to_lobby(user.mob, user)
	BLACKBOX_LOG_ADMIN_VERB("Back to Lobby")

ADMIN_VERB_AND_CONTEXT_MENU(rogue_toggle_sleeping, R_ADMIN, "Toggle Sleeping", "Put a mob to sleep, or wake it.", ADMIN_CATEGORY_ROGUE, /mob/living)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob/living)
	rogue_admin_toggle_sleeping(user, target)
	BLACKBOX_LOG_ADMIN_VERB("Toggle Sleeping")

ADMIN_VERB(rogue_sleep_in_view, R_ADMIN, "Sleep In View", "Put every mob you can see to sleep.", ADMIN_CATEGORY_ROGUE)
	if(tgui_alert(user, "This will sleep ALL mobs within your view range. Are you sure?", "Sleep In View", list("Yes", "Cancel")) != "Yes")
		return
	for(var/mob/living/sleeper in view(user))
		sleeper.SetSleeping(999999)
	message_admins("[key_name_admin(user)] used Sleep In View.")
	log_admin("[key_name(user)] used Sleep In View.")
	BLACKBOX_LOG_ADMIN_VERB("Sleep In View")

ADMIN_VERB(rogue_wake_in_view, R_ADMIN, "Wake In View", "Wake every mob you can see.", ADMIN_CATEGORY_ROGUE)
	for(var/mob/living/sleeper in view(user))
		sleeper.SetSleeping(0)
	message_admins("[key_name_admin(user)] used Wake In View.")
	log_admin("[key_name(user)] used Wake In View.")
	BLACKBOX_LOG_ADMIN_VERB("Wake In View")

ADMIN_VERB_ONLY_CONTEXT_MENU(rogue_player_panel, R_ADMIN, "Rogue Player Panel", /mob)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob)
	GLOB.rogue_admin_panel.show(user, target)
	BLACKBOX_LOG_ADMIN_VERB("Rogue Player Panel")

GLOBAL_DATUM_INIT(rogue_admin_panel, /datum/rogue_admin_panel, new)

/// The game master's part of Ratwood's player panel, beside TG's: PQ, triumphs, role and class, and the actions on them.
/datum/rogue_admin_panel

/datum/rogue_admin_panel/proc/show(client/user, mob/target)
	if(!target)
		return
	var/link = "byond://?src=[REF(src)];[HrefToken()];target=[REF(target)];action="
	var/list/body = list("Rogue options for <b>[target]</b>[target.ckey ? " played by <b>[target.ckey]</b>" : ""]<br><br>")
	if(target.ckey)
		var/pq = rogue_get_pq(target.ckey)
		body += "Player Quality: [rogue_pq_rank(pq)] ([pq])<br>"
		body += "<a href='[link]check_pq'>\[Check PQ\]</a> <a href='[link]adjust_pq'>\[Modify PQ\]</a><br>"
		body += "Triumphs: [rogue_get_triumphs(target.ckey)] <a href='[link]adjust_triumphs'>\[Modify Triumphs\]</a><br><br>"
	var/mob/living/carbon/human/human = target
	if(target.mind)
		body += "Role: [target.mind.assigned_role?.title || "None"]<br>"
	if(istype(human))
		body += "Class: [human.rockhill_advclass?.name || "None"]<br>"
	body += "<br>"
	if(target.ckey && !isnewplayer(target))
		body += "<a href='[link]lobby'>Send back to Lobby</a>"
	if(isliving(target))
		var/mob/living/living = target
		body += " | <a href='[link]sleep'>[living.IsSleeping() ? "Wake" : "Sleep"]</a>"
	var/datum/browser/popup = new(user.mob, "rogue_admin_panel-[REF(target)]", "Rogue Options for [target.key || target]", 420, 280)
	popup.set_content(jointext(body, ""))
	popup.open()

/datum/rogue_admin_panel/Topic(href, list/href_list)
	var/client/user = usr?.client
	if(!user?.holder?.CheckAdminHref(href, href_list) || !check_rights_for(user, R_ADMIN))
		return
	var/mob/target = locate(href_list["target"]) in GLOB.mob_list
	if(!target)
		to_chat(user, span_warning("That mob is gone."), confidential = TRUE)
		return
	switch(href_list["action"])
		if("check_pq")
			if(target.ckey)
				rogue_show_pq(user, target.ckey)
			return
		if("adjust_pq")
			if(target.ckey)
				rogue_admin_adjust_pq(user, target.ckey)
		if("adjust_triumphs")
			if(target.ckey)
				rogue_admin_adjust_triumphs(user, target.ckey)
		if("lobby")
			rogue_admin_send_back_to_lobby(user, target)
			return
		if("sleep")
			if(isliving(target))
				rogue_admin_toggle_sleeping(user, target)
	if(!QDELETED(target))
		show(user, target)
