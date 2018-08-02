/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
	if(!M || !ismob(M))
		return

	var/ntype = text2num(type)

	//Add client links
	var/dat = ""
	if(M.client)
		dat += "<center><p>Client</p></center>"
		dat += "<center>"
		dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_CLIENT, "Attack Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_CLIENT, "Say Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_CLIENT, "Emote Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_CLIENT, "Comms Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_CLIENT, "OOC Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_OWNERSHIP_LOG, LOGSRC_CLIENT, "Ownership Log", ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_CLIENT, "Show All", ntype)
		dat += "</center>"
	else
		dat += "<p> No client attached to mob </p>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"
	dat += "<center><p>Mob</p></center>"
	//Add the links for the mob specific log
	dat += "<center>"
	dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_MOB, "Attack Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_MOB, "Say Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_MOB, "Emote Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_CLIENT, "Comms Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_MOB, "OOC Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_OWNERSHIP_LOG, LOGSRC_MOB, "Ownership Log", ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_MOB, "Show All", ntype)
	dat += "</center>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"

	var/log_source = M.logging;
	if(source == LOGSRC_CLIENT && M.client) //if client doesn't exist just fall back to the mob log
		log_source = M.client.player_details.logging //should exist, if it doesn't that's a bug, don't check for it not existing

	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & ntype)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				reversed = reverseRange(reversed.Copy())
				for(var/entry in reversed)
					dat += "<font size=2px>[entry]: [reversed[entry]]</font><br>"
			dat += "<hr>"

	usr << browse(dat, "window=invidual_logging_[key_name(M)];size=600x480")

/proc/individual_logging_panel_link(mob/M, log_type, log_src, label, selected_type)
	var/slabel = label
	if(selected_type == log_type)
		slabel = "<b>\[[label]\]</b>"

	return "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[log_type];log_src=[LOGSRC_CLIENT]'>[slabel]</a>"