/datum/station_trait/random_event_weight_modifier/ion_storms/get_pulsar_message()
	var/advisory_string = "Advisory Level: <b>ERROR</b></center><BR>"
	advisory_string += scramble_message_replace_chars("Your sector's advisory level is ERROR. An electromagnetic field has stormed through nearby surveillance equipment, causing major data loss. Partial data was recovered and showed no credible threats to Port Authority assets within Crusoe's Rest; however, the Department of Intelligence advises maintaining high alert against potential threats due to the lack of complete data.", 35)
	return advisory_string
