/datum/station_trait/announcement_ytp
	name = "Announcement Poop"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "This shit so suus. faaaf."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/birthday, /datum/station_trait/announcement_intern)

/datum/station_trait/announcement_ytp/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/ytp

/datum/station_trait/announcement_ytp/get_pulsar_message()
	var/advisory_string = "Advisory Level: <b>Green</b></center><BR>"
	advisory_string += "Your sector's Green. Surveillance information shows Nanotrasen is Green. As always, the Department is Green. Potential threats is Green, regardless of a lack of Green.<BR>"
	advisory_string += "The Star Advisory Department of Spinward Nanotrasen Cybersun Sector Stations Intelligence is highly vigilant and on high alert.<BR>"
	advisory_string += "this time potential threats ? Nanotrasen is no credible !"
	return advisory_string
