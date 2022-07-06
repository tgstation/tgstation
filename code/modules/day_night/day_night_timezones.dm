/**
 * Timezones are simple presets to determine what color the sky will be at a certain time.
 */
/datum/timezone
	/// The name of this timezone
	var/name = "DEFAULT"
	/// The HOUR at which this timezone should start
	var/start_hour = 0
	/// The HOUR at which this timezone should end
	var/end_hour = 0
	/// The light color of this timezone
	var/light_color = COLOR_BLACK
	/// The light power of this timezone
	var/light_alpha = 0

/datum/timezone/midnight
	name = "midnight"
	end_hour = 4
	light_color = COLOR_BLACK
	light_alpha = 0

/datum/timezone/early_morning
	name = "early morning"
	start_hour = 5
	end_hour = 7
	light_color = "#c4faff"
	light_alpha = 100

/datum/timezone/morning
	name = "morning"
	start_hour = 8
	end_hour = 11
	light_color = "#d6fafd"
	light_alpha = 200

/datum/timezone/midday
	name = "midday"
	start_hour = 12
	end_hour = 16
	light_color = "#ffffff"
	light_alpha = 255

/datum/timezone/early_evening
	name = "midday"
	start_hour = 17
	end_hour = 19
	light_color = "#ffdb99"
	light_alpha = 200

/datum/timezone/evening
	name = "evening"
	start_hour = 20
	end_hour = 23
	light_color = "#c43f3f"
	light_alpha = 100
