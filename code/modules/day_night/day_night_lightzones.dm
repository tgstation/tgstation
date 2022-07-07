/**
 * Lightzones are simple presets to determine what color and brightness the sky will be at a certain time.
 * A list of lightzones must add up to 24 regarding start and end times.
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
	start_hour = 0
	end_hour = 4
	light_color = COLOR_BLACK
	light_alpha = 0

/datum/lightzone/early_morning
	name = "early morning"
	start_hour = 4
	end_hour = 8
	light_color = "#0000a6"
	light_alpha = 50

/datum/lightzone/morning
	name = "morning"
	start_hour = 8
	end_hour = 12
	light_color = "#d6fafd"
	light_alpha = 150

/datum/lightzone/midday
	name = "midday"
	start_hour = 12
	end_hour = 16
	light_color = COLOR_WHITE
	light_alpha = 255

/datum/lightzone/early_evening
	name = "early evening"
	start_hour = 16
	end_hour = 20
	light_color = "#ffdb99"
	light_alpha = 150

/datum/lightzone/evening
	name = "evening"
	start_hour = 20
	end_hour = 0
	light_color = "#c43f3f"
	light_alpha = 50
