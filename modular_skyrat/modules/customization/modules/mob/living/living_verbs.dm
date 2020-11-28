/mob/living/verb/set_temporary_flavor()
	set category = "IC"
	set name = "Set Temporary Flavor Text"
	set desc = "Allows you to set a temporary flavor text."

	if(stat != CONSCIOUS)
		to_chat(usr, "<span class='warning'>You can't set your temporary flavor text now...</span>")
		return

	var/msg = input(usr, "Set the temporary flavor text in your 'examine' verb. This is for describing what people can tell by looking at your character.", "Temporary Flavor Text", temporary_flavor_text) as message|null
	if(msg)
		if(msg == "")
			temporary_flavor_text = null
		else
			temporary_flavor_text = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
	return
