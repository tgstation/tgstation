// Admin Tab - Game Verbs

ADMIN_CONTEXT_ENTRY(context_player_panel, "Show Player Panel", R_ADMIN, mob/player in GLOB.mob_list)
	log_admin("[key_name(usr)] checked the individual player panel for [key_name(player)][isobserver(usr)?"":" while in game"].")
	var/body = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Options for [player.key]</title></head>"
	body += "<body>Options panel for <b>[player]</b>"
	if(player.client)
		body += " played by <b>[player.client]</b> "
		body += "\[<A href='?_src_=holder;[HrefToken()];editrights=[(GLOB.admin_datums[player.client.ckey] || GLOB.deadmins[player.client.ckey]) ? "rank" : "add"];key=[player.key]'>[player.client.holder ? player.client.holder.rank_names() : "Player"]</A>\]"
		if(CONFIG_GET(flag/use_exp_tracking))
			body += "\[<A href='?_src_=holder;[HrefToken()];getplaytimewindow=[REF(player)]'>" + player.client.get_exp_living(FALSE) + "</a>\]"

	if(isnewplayer(player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?_src_=holder;[HrefToken()];revive=[REF(player)]'>Heal</A>\] "

	if(player.ckey)
		body += "<br>\[<A href='?_src_=holder;[HrefToken()];ppbyckey=[player.ckey];ppbyckeyorigmob=[REF(player)]'>Find Updated Panel</A>\]"

	if(player.client)
		body += "<br>\[<b>First Seen:</b> [player.client.player_join_date]\]\[<b>Byond account registered on:</b> [player.client.account_join_date]\]"
		body += "<br><br><b>CentCom Galactic Ban DB: </b> "
		if(CONFIG_GET(string/centcom_ban_db))
			body += "<a href='?_src_=holder;[HrefToken()];centcomlookup=[player.client.ckey]'>Search</a>"
		else
			body += "<i>Disabled</i>"
		body += "<br><br><b>Show related accounts by:</b> "
		body += "\[ <a href='?_src_=holder;[HrefToken()];showrelatedacc=cid;client=[REF(player.client)]'>CID</a> | "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=ip;client=[REF(player.client)]'>IP</a> \]"
		var/full_version = "Unknown"
		if(player.client.byond_version)
			full_version = "[player.client.byond_version].[player.client.byond_build ? player.client.byond_build : "xxx"]"
		body += "<br>\[<b>Byond version:</b> [full_version]\]<br>"


	body += "<br><br>\[ "
	body += "<a href='?_src_=vars;[HrefToken()];Vars=[REF(player)]'>VV</a> - "
	if(player.mind)
		body += "<a href='?_src_=holder;[HrefToken()];traitor=[REF(player)]'>TP</a> - "
		body += "<a href='?_src_=holder;[HrefToken()];skill=[REF(player)]'>SKILLS</a> - "
	else
		body += "<a href='?_src_=holder;[HrefToken()];initmind=[REF(player)]'>Init Mind</a> - "
	if (iscyborg(player))
		body += "<a href='?_src_=holder;[HrefToken()];borgpanel=[REF(player)]'>BP</a> - "
	body += "<a href='?priv_msg=[player.ckey]'>PM</a> - "
	body += "<a href='?_src_=holder;[HrefToken()];subtlemessage=[REF(player)]'>SM</a> - "
	if (ishuman(player) && player.mind)
		body += "<a href='?_src_=holder;[HrefToken()];HeadsetMessage=[REF(player)]'>HM</a> - "
	body += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(player)]'>FLW</a> - "
	//Default to client logs if available
	var/source = LOGSRC_MOB
	if(player.ckey)
		source = LOGSRC_CKEY
	body += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(player)];log_src=[source]'>LOGS</a>\] <br>"

	body += "<b>Mob type</b> = [player.type]<br><br>"

	body += "<A href='?_src_=holder;[HrefToken()];boot2=[REF(player)]'>Kick</A> | "
	if(player.client)
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[player.key];newbanip=[player.client.address];newbancid=[player.client.computer_id]'>Ban</A> | "
	else
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[player.key]'>Ban</A> | "

	body += "<A href='?_src_=holder;[HrefToken()];showmessageckey=[player.ckey]'>Notes | Messages | Watchlist</A> | "
	if(player.client)
		body += "| <A href='?_src_=holder;[HrefToken()];sendtoprison=[REF(player)]'>Prison</A> | "
		body += "\ <A href='?_src_=holder;[HrefToken()];sendbacktolobby=[REF(player)]'>Send back to Lobby</A> | "
		var/muted = player.client.prefs.muted
		body += "<br><b>Mute: </b> "
		body += "\[<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]"
		body += "(<A href='?_src_=holder;[HrefToken()];mute=[player.ckey];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)"

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];jumpto=[REF(player)]'><b>Jump to</b></A> | "
	body += "<A href='?_src_=holder;[HrefToken()];getmob=[REF(player)]'>Get</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];sendmob=[REF(player)]'>Send To</A>"

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];traitor=[REF(player)]'>Traitor panel</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];narrateto=[REF(player)]'>Narrate to</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];subtlemessage=[REF(player)]'>Subtle message</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];playsoundto=[REF(player)]'>Play sound to</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];languagemenu=[REF(player)]'>Language Menu</A>"

	if(player.client)
		if(!isnewplayer(player))
			body += "<br><br>"
			body += "<b>Transformation:</b><br>"
			if(isobserver(player))
				body += "<b>Ghost</b> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];simplemake=observer;mob=[REF(player)]'>Make Ghost</A> | "

			if(ishuman(player) && !ismonkey(player))
				body += "<b>Human</b> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];simplemake=human;mob=[REF(player)]'>Make Human</A> | "

			if(ismonkey(player))
				body += "<b>Monkey</b> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];simplemake=monkey;mob=[REF(player)]'>Make Monkey</A> | "

			if(iscyborg(player))
				body += "<b>Cyborg</b> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];simplemake=robot;mob=[REF(player)]'>Make Cyborg</A> | "

			if(isAI(player))
				body += "<b>AI</b>"
			else
				body += "<A href='?_src_=holder;[HrefToken()];makeai=[REF(player)]'>Make AI</A>"

		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		if(!isnewplayer(player))
			body += "<A href='?_src_=holder;[HrefToken()];forcespeech=[REF(player)]'>Forcesay</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];applyquirks=[REF(player)]'>Apply Client Quirks</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];tdome1=[REF(player)]'>Thunderdome 1</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];tdome2=[REF(player)]'>Thunderdome 2</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];tdomeadmin=[REF(player)]'>Thunderdome Admin</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];tdomeobserve=[REF(player)]'>Thunderdome Observer</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];admincommend=[REF(player)]'>Commend Behavior</A> | "

	body += "<br>"
	body += "</body></html>"

	usr << browse(body, "window=adminplayeropts-[REF(player)];size=550x515")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(game, toggle_godmode, "", R_ADMIN, mob/demigod in view())
	demigod.status_flags ^= GODMODE
	to_chat(usr, span_adminnotice("Toggled [(demigod.status_flags & GODMODE) ? "ON" : "OFF"]"), confidential = TRUE)

	log_admin("[key_name(usr)] has toggled [key_name(demigod)]'s nodamage to [(demigod.status_flags & GODMODE) ? "On" : "Off"]")
	var/msg = "[key_name_admin(usr)] has toggled [ADMIN_LOOKUPFLW(demigod)]'s nodamage to [(demigod.status_flags & GODMODE) ? "On" : "Off"]"
	message_admins(msg)
	admin_ticket_log(demigod, msg)

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
*/
ADMIN_VERB(game, respawn_character, "Respawn a player that has been gibbed/dusted/killed. They must be a ghost", R_SPAWN, input as text)
	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>", confidential = TRUE)
		return

	if(G_found.mind && !G_found.mind.active) //mind isn't currently in use by someone/something
		//check if they were a monkey
		if(findtext(G_found.real_name,"monkey"))
			if(tgui_alert(usr,"This character appears to have been a monkey. Would you like to respawn them as such?",,list("Yes","No")) == "Yes")
				var/mob/living/carbon/human/species/monkey/new_monkey = new
				SSjob.SendToLateJoin(new_monkey)
				G_found.mind.transfer_to(new_monkey) //be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.", confidential = TRUE)
				var/msg = span_adminnotice("[key_name_admin(usr)] has respawned [new_monkey.key] as a filthy monkey.")
				message_admins(msg)
				admin_ticket_log(new_monkey, msg)
				return //all done. The ghost is auto-deleted


	//Ok, it's not a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	var/datum/record/locked/record_found //Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active) //mind isn't currently in use by someone/something
		record_found = find_record(G_found.name, locked_only = TRUE)

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.name
		new_character.gender = record_found.gender
		new_character.age = record_found.age
		var/datum/dna/found_dna = record_found.dna_ref
		new_character.hardset_dna(found_dna.unique_identity, record_found.dna_string, null, record_found.name, record_found.blood_type, new record_found.species, found_dna.features)
	else
		new_character.randomize_human_appearance()
		new_character.dna.update_dna_identity()

	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character) //be careful when doing stuff like this! I've already checked the mind isn't in use
	else
		new_character.mind_initialize()
	if(is_unassigned_job(new_character.mind.assigned_role))
		new_character.mind.set_assigned_role(SSjob.GetJobType(SSjob.overflow_role))

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	var/datum/antagonist/traitor/traitordatum = new_character.mind.has_antag_datum(/datum/antagonist/traitor)
	if(traitordatum)
		SSjob.EquipRank(new_character, new_character.mind.assigned_role, new_character.client)
		new_character.mind.give_uplink(silent = TRUE, antag_datum = traitordatum)

	switch(new_character.mind.special_role)
		if(ROLE_WIZARD)
			new_character.forceMove(pick(GLOB.wizardstart))
			var/datum/antagonist/wizard/A = new_character.mind.has_antag_datum(/datum/antagonist/wizard,TRUE)
			A.equip_wizard()
		if(ROLE_SYNDICATE)
			new_character.forceMove(pick(GLOB.nukeop_start))
			var/datum/antagonist/nukeop/N = new_character.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
			N.equip_op()
		if(ROLE_NINJA)
			var/list/ninja_spawn = list()
			for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
				ninja_spawn += L
			var/datum/antagonist/ninja/ninjadatum = new_character.mind.has_antag_datum(/datum/antagonist/ninja)
			ninjadatum.equip_space_ninja()
			if(ninja_spawn.len)
				new_character.forceMove(pick(ninja_spawn))

		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role.type)
				if(/datum/job/cyborg)//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize(TRUE)
				if(/datum/job/ai)
					new_character = new_character.AIize()
				else
					if(!traitordatum) // Already equipped there.
						SSjob.EquipRank(new_character, new_character.mind.assigned_role, new_character.client)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!record_found && (new_character.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
		//Power to the user!
		if(tgui_alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,list("No","Yes")) == "Yes")
			GLOB.manifest.inject(new_character)

		if(tgui_alert(new_character,"Would you like an active AI to announce this character?",,list("No","Yes")) == "Yes")
			announce_arrival(new_character, new_character.mind.assigned_role.title)

	var/msg = span_adminnotice("[admin] has respawned [player_key] as [new_character.real_name].")
	message_admins(msg)
	admin_ticket_log(new_character, msg)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.", confidential = TRUE)

	return new_character

ADMIN_VERB(game, manage_job_slots, "", R_ADMIN)
	usr.client.holder.manage_free_slots()

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return
	var/datum/browser/browser = new(usr, "jobmanagement", "Manage Free Slots", 520)
	var/list/dat = list()
	var/count = 0

	if(!SSjob.initialized)
		tgui_alert(usr, "You cannot manage jobs before the job subsystem is initialized!")
		return

	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		dat += "<div class='notice red' style='font-size: 125%'>Lag Switch \"Disable non-observer late joining\" is ON. Only Observers may join!</div>"

	dat += "<table>"

	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		count++
		var/J_title = html_encode(job.title)
		var/J_opPos = html_encode(job.total_positions - (job.total_positions - job.current_positions))
		var/J_totPos = html_encode(job.total_positions)
		dat += "<tr><td>[J_title]:</td> <td>[J_opPos]/[job.total_positions < 0 ? " (unlimited)" : J_totPos]"

		dat += "</td>"
		dat += "<td>"
		if(job.total_positions >= 0)
			dat += "<A href='?src=[REF(src)];[HrefToken()];customjobslot=[job.title]'>Custom</A> | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];addjobslot=[job.title]'>Add 1</A> | "
			if(job.total_positions > job.current_positions)
				dat += "<A href='?src=[REF(src)];[HrefToken()];removejobslot=[job.title]'>Remove</A> | "
			else
				dat += "Remove | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];unlimitjobslot=[job.title]'>Unlimit</A></td>"
		else
			dat += "<A href='?src=[REF(src)];[HrefToken()];limitjobslot=[job.title]'>Limit</A></td>"

	browser.height = min(100 + count * 20, 650)
	browser.set_content(dat.Join())
	browser.open()

ADMIN_VERB(game, change_view_range, "Switch between default and larger views", R_ADMIN)
	var/datum/view_data/view_size = usr.client.view_size
	if(view_size.getView() == view_size.default)
		view_size.setTo(input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,37) - 7)
	else
		view_size.resetToDefault(getScreenSize(usr.client.prefs.read_preference(/datum/preference/toggle/widescreen)))
	log_admin("[key_name(usr)] changed their view range to [usr.client.view].")

ADMIN_VERB(game, toggle_combo_hud, "Toggles the Admin Combo HUD (all huds)", R_ADMIN)
	if(usr.client.combo_hud_enabled)
		usr.client.disable_combo_hud()
	else
		usr.client.enable_combo_hud()

	to_chat(usr, "You toggled your admin combo HUD [usr.client.combo_hud_enabled ? "ON" : "OFF"].", confidential = TRUE)
	message_admins("[key_name_admin(usr)] toggled their admin combo HUD [usr.client.combo_hud_enabled ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled their admin combo HUD [usr.client.combo_hud_enabled ? "ON" : "OFF"].")

/client/proc/enable_combo_hud()
	if (combo_hud_enabled)
		return

	combo_hud_enabled = TRUE

	for (var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED))
		var/datum/atom_hud/atom_hud = GLOB.huds[hudtype]
		atom_hud.show_to(mob)

	for (var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antag_hud in GLOB.active_alternate_appearances)
		antag_hud.show_to(mob)

	mob.lighting_alpha = mob.default_lighting_alpha()
	mob.update_sight()

/client/proc/disable_combo_hud()
	if (!combo_hud_enabled)
		return

	combo_hud_enabled = FALSE

	for (var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED))
		var/datum/atom_hud/atom_hud = GLOB.huds[hudtype]
		atom_hud.hide_from(mob)

	for (var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antag_hud in GLOB.active_alternate_appearances)
		antag_hud.hide_from(mob)

	mob.lighting_alpha = mob.default_lighting_alpha()
	mob.update_sight()

ADMIN_VERB(game, traitor_panel, "", R_ADMIN, mob/traitor in view())
	var/datum/mind/target_mind = traitor.mind
	if(!target_mind)
		to_chat(usr, "This mob has no mind!", confidential = TRUE)
		return
	target_mind.traitor_panel()

ADMIN_VERB(game, skill_panel, "", R_ADMIN, mob/skilled in view())
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"The game hasn't started yet!")
		return

	var/datum/mind/target_mind = skilled.mind
	if(!target_mind)
		to_chat(usr, "This mob has no mind!", confidential = TRUE)
		return
	var/datum/skill_panel/SP = new(usr, target_mind)
	SP.ui_interact(usr)

ADMIN_VERB(game, show_lag_switches, "Display the controls for drastic lag mitigation measures", R_ADMIN)
	if(!SSlag_switch.initialized)
		to_chat(usr, span_notice("The Lag Switch subsystem has not yet been initialized."))
		return

	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Lag Switches</title></head><body><h2><B>Lag (Reduction) Switches</B></h2>")
	dat += "Automatic Trigger: <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=TOGGLE_AUTO'><b>[SSlag_switch.auto_switch ? "On" : "Off"]</b></a><br/>"
	dat += "Population Threshold: <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=NUM'><b>[SSlag_switch.trigger_pop]</b></a><br/>"
	dat += "Slowmode Cooldown (toggle On/Off below): <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=SLOWCOOL'><b>[SSlag_switch.slowmode_cooldown/10] seconds</b></a><br/>"
	dat += "<br/><b>SET ALL MEASURES: <a href='?_src_=holder;[HrefToken()];change_lag_switch=ALL_ON'>ON</a> | <a href='?_src_=holder;[HrefToken()];change_lag_switch=ALL_OFF'>OFF</a></b><br/>"
	dat += "<br/>Disable ghosts zoom and t-ray verbs (except staff): <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_GHOST_ZOOM_TRAY]'><b>[SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] ? "On" : "Off"]</b></a><br/>"
	dat += "Disable late joining: <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_NON_OBSJOBS]'><b>[SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "On" : "Off"]</b></a><br/>"
	dat += "<br/>============! MAD GHOSTS ZONE !============<br/>"
	dat += "Disable deadmob keyLoop (except staff, informs dchat): <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_DEAD_KEYLOOP]'><b>[SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] ? "On" : "Off"]</b></a><br/>"
	dat += "==========================================<br/>"
	dat += "<br/><b>Measures below can be bypassed with a <abbr title='TRAIT_BYPASS_MEASURES'><u>special trait</u></abbr></b><br/>"
	dat += "Slowmode say verb (informs world): <a href='?_src_=holder;[HrefToken()];change_lag_switch=[SLOWMODE_SAY]'><b>[SSlag_switch.measures[SLOWMODE_SAY] ? "On" : "Off"]</b></a><br/>"
	dat += "Disable runechat: <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_RUNECHAT]'><b>[SSlag_switch.measures[DISABLE_RUNECHAT] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to speaker</span><br/>"
	dat += "Disable examine icons: <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_USR_ICON2HTML]'><b>[SSlag_switch.measures[DISABLE_USR_ICON2HTML] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to examiner</span><br/>"
	dat += "Disable parallax: <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_PARALLAX]'><b>[SSlag_switch.measures[DISABLE_PARALLAX] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to character</span><br />"
	dat += "Disable footsteps: <a href='?_src_=holder;[HrefToken()];change_lag_switch=[DISABLE_FOOTSTEPS]'><b>[SSlag_switch.measures[DISABLE_FOOTSTEPS] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to character</span><br />"
	dat += "</body></html>"
	usr << browse(dat.Join(), "window=lag_switch_panel;size=420x480")
