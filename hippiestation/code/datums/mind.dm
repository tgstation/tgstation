/datum/mind/proc/remove_shadowling()
	if(src in SSticker.mode.thralls)
		SSticker.mode.remove_thrall(src)
	if(src in SSticker.mode.shadows)
		SSticker.mode.remove_shadowling(src)
	remove_objectives()

/datum/mind/remove_all_antag()
	. = ..()
	remove_shadowling()


/datum/mind/proc/vampire_hook()
	var/text = "vampire"
	if(SSticker.mode.config_tag == "vampire")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(is_vampire(current))
		text += "<b>VAMPIRE</b> | <a href='?src=[REF(src)];vampire=clear'>human</a> | <a href='?src=[REF(src)];vampire=full'>full-power</a>"
	else
		text += "<a href='?src=[REF(src)];vampire=vampire'>vampire</a> | <b>HUMAN</b> | <a href='?src=[REF(src)];vampire=full'>full-power</a>"
	if(current && current.client && (ROLE_VAMPIRE in current.client.prefs.be_special))
		text += " | Enabled in Prefs"
	else
		text += " | Disabled in Prefs"
	return text

/datum/mind/proc/vampire_href(href, mob/M)
	switch(href)
		if("clear")
			remove_vampire(current)
			message_admins("[key_name_admin(usr)] has de-vampired [current].")
			log_admin("[key_name(usr)] has de-vampired [current].")
		if("vampire")
			if(!is_vampire(current))
				message_admins("[key_name_admin(usr)] has vampired [current].")
				log_admin("[key_name(usr)] has vampired [current].")
				add_vampire(current)
			else
				to_chat(usr, "<span class='warning'>[current] is already a vampire!</span>")
		if("full")
			message_admins("[key_name_admin(usr)] has full-vampired [current].")
			log_admin("[key_name(usr)] has full-vampired [current].")
			if(!is_vampire(current))
				add_vampire(current)
				var/datum/antagonist/vampire/V = has_antag_datum(ANTAG_DATUM_VAMPIRE)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()
			else
				var/datum/antagonist/vampire/V = has_antag_datum(ANTAG_DATUM_VAMPIRE)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()