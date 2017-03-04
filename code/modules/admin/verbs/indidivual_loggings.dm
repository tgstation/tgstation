/proc/show_individual_logging_panel(mob/M, type = "attack")
	if(!M || !ismob(M))
		return
	var/dat = "<center><a href='?_src_=holder;individuallog=\ref[M];log_type=attack'>Attack log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=say'>Say log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=emote'>Emote log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=ooc'>OOC log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=[type]'>Refresh</a></center>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"

	switch(type)
		if("attack")
			dat += "<center>Attack logs of [key_name(M)]</center><br>"
			for(var/entry in M.attack_log)
				dat += "<font size='2px'>[entry]</font><br><hr>"
		if("say")
			dat += "<center>Say logs of [key_name(M)]</center><br>"
			for(var/entry in M.say_log)
				dat += "<font size='3px'>[entry] [M.say_log[entry]]</font><br><hr>"
		if("emote")
			dat += "<center>Emote logs of [key_name(M)]</center><br>"
			for(var/entry in M.emote_log)
				dat += "<font size='3px'>[entry]</font><br><hr>"
		if("ooc")
			dat += "<center>OOC logs of [key_name(M)]</center><br>"
			for(var/entry in M.ooc_log)
				dat += "<font size='3px'>[entry]</font><br><hr>"

	usr << browse(dat, "window=invidual_logging;size=600x480")