/**
 * Lightzones are simple presets to determine what color and brightness the sky will be at a certain time.
 */
/datum/lightzone
	/// The name of this lightzone
	var/name = "DEFAULT"
	/// The HOUR at which this lightzone should start
	var/start_hour = 0
	/// The HOUR at which this lightzone should end
	var/end_hour = 0
	/// The light color of this lightzone
	var/light_color = COLOR_BLACK
	/// The light power of this lightzone
	var/light_alpha = 0

/datum/lightzone/midnight
	name = "midnight"
	end_hour = 4
	light_color = COLOR_BLACK
	light_alpha = 0

/datum/lightzone/early_morning
	name = "early morning"
	start_hour = 5
	end_hour = 7
	light_color = "#c4faff"
	light_alpha = 100

/datum/lightzone/morning
	name = "morning"
	start_hour = 8
	end_hour = 11
	light_color = "#d6fafd"
	light_alpha = 200

/datum/lightzone/midday
	name = "midday"
	start_hour = 12
	end_hour = 16
	light_color = "#ffffff"
	light_alpha = 255

/datum/lightzone/early_evening
	name = "midday"
	start_hour = 17
	end_hour = 19
	light_color = "#ffdb99"
	light_alpha = 200

/datum/lightzone/evening
	name = "evening"
	start_hour = 20
	end_hour = 23
	light_color = "#c43f3f"
	light_alpha = 100
