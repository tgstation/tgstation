/mob/living/carbon/human/whisper(message as text)
	if (src.name != GetVoice())
		var/alt_name = src.get_id_name("Unknown")
		var/list/L = list(message=message,alt_name=alt_name)
		..(arglist(L))
	else
		..(message)