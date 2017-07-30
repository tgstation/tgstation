/datum/mind/proc/HandleShadowling()
	var/text = "shadowling"
	if(SSticker.mode.config_tag == "shadowling")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(src in SSticker.mode.shadows)
		text += "<b>SHADOWLING</b>|thrall|<a href='?src=\ref[src];shadowling=clear'>human</a>"
	else if(src in SSticker.mode.thralls)
		text += "shadowling|<b>THRALL</b>|<a href='?src=\ref[src];shadowling=clear'>human</a>"
	else
		text += "<a href='?src=\ref[src];shadowling=shadowling'>shadowling</a>|<a href='?src=\ref[src];shadowling=thrall'>thrall</a>|<b>HUMAN</b>"
	if(current && current.client && (ROLE_SHADOWLING in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	return text