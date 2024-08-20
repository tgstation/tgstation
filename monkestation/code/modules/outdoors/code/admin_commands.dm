/client/proc/run_particle_weather()
	set category = "Admin.Events"
	set name = "Run Particle Weather"
	set desc = "Triggers a particle weather"

	if(!holder)
		return

	if(!SSparticle_weather.enabled)
		to_chat(src, span_warning("Particle weather is currently disabled!"), type = MESSAGE_TYPE_ADMINLOG)
		return

	var/weather_type = input("Choose a weather", "Weather")  as null|anything in sort_list(subtypesof(/datum/particle_weather), /proc/cmp_typepaths_asc)
	if(!weather_type)
		return

	var/where = input("Choose Where", "Weather") as null|anything in list("Eclipse", "Default")
	if(!where)
		return

	var/send_value = FALSE
	if(where == "Eclipse")
		send_value = TRUE
	SSparticle_weather.run_weather(new weather_type(where), TRUE, send_value)

	message_admins("[key_name_admin(usr)] started weather of type [weather_type].")
	log_admin("[key_name(usr)] started weather of type [weather_type].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Run Particle Weather")
