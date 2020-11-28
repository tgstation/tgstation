/mob/living/Topic(href, href_list)
	. = ..()
	if(href_list["temporary_flavor"])
		if(temporary_flavor_text)
			var/datum/browser/popup = new(usr, "[name]'s temporary flavor text", "[name]'s Temporary Flavor Text", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s temporary flavor text", replacetext(temporary_flavor_text, "\n", "<BR>")))
			popup.open()
			return
