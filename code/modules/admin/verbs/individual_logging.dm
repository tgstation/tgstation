/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
	if(!M || !ismob(M))
		return
	
	//Add client links
	var/dat = ""
	if(M.client) 
		dat += "<center><p>Client</p></center>"	
		dat += "<center><a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_ATTACK_LOG];log_src=[LOGSRC_CLIENT]'>Attack log</a> | "
		dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_SAY_LOG];log_src=[LOGSRC_CLIENT]'>Say log</a> | "
		dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_EMOTE_LOG];log_src=[LOGSRC_CLIENT]'>Emote log</a> | "
		dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_OOC_LOG];log_src=[LOGSRC_CLIENT]'>OOC log</a> | "
		dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_SHOW_ALL_LOG];log_src=[LOGSRC_CLIENT]'>Show all</a> | "
		dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[type];log_src=[LOGSRC_CLIENT]'>Refresh</a></center>"
	else
		dat += "<p> No client attached to mob </p>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"
	dat += "<center><p>Mob</p></center>"	
	//Add the links for the mob specific log
	dat += "<center><a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_ATTACK_LOG];log_src=[LOGSRC_MOB]'>Attack log</a> | "
	dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_SAY_LOG];log_src=[LOGSRC_MOB]'>Say log</a> | "
	dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_EMOTE_LOG];log_src=[LOGSRC_MOB]'>Emote log</a> | "
	dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_OOC_LOG];log_src=[LOGSRC_MOB]'>OOC log</a> | "
	dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[INDIVIDUAL_SHOW_ALL_LOG];log_src=[LOGSRC_MOB]'>Show all</a> | "
	dat += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_type=[type];log_src=[LOGSRC_MOB]'>Refresh</a></center>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"

	var/log_source = M.logging;
	if(source == LOGSRC_CLIENT && M.client) //if client doesn't exist just fall back to the mob log
		log_source = M.client.player_details.logging //should exist, if it doesn't that's a bug, don't check for it not existing

	if(type == INDIVIDUAL_SHOW_ALL_LOG)
		dat += "<center>Displaying all [source] logs of [key_name(M)]</center><br><hr>"
		for(var/log_type in log_source)
			dat += "<center><b>[log_type]</b></center><br>"
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				reversed = reverseRange(reversed.Copy())
				for(var/entry in reversed)
					dat += "<font size=2px>[entry]: [reversed[entry]]</font><br>"
			dat += "<hr>"
	else
		dat += "<center>[source] [type] of [key_name(M)]</center><br>"
		var/list/reversed = log_source[type]
		if(reversed)
			reversed = reverseRange(reversed.Copy())
			for(var/entry in reversed)
				dat += "<font size=2px>[entry]: [reversed[entry]]</font><hr>"

	usr << browse(dat, "window=invidual_logging_[key_name(M)];size=600x480")
