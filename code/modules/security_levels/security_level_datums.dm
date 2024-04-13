/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */

/datum/security_level
	/// The name of this security level.
	var/name = "not set"
	/// The color of our announcement divider.
	var/announcement_color = "default"
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The sound that we will play when this security level is set
	var/sound
	/// The looping sound that will be played while the security level is set
	var/looping_sound
	/// The looping sound interval
	var/looping_sound_interval
	/// The shuttle call time modification of this security level
	var/shuttle_call_time_mod = 0
	/// Our announcement when lowering to this level
	var/lowering_to_announcement
	/// Our announcement when elevating to this level
	var/elevating_to_announcement
	/// Our configuration key for lowering to text, if set, will override the default lowering to announcement.
	var/lowering_to_configuration_key
	/// Our configuration key for elevating to text, if set, will override the default elevating to announcement.
	var/elevating_to_configuration_key

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // I'm not sure about you, but isn't there an easier way to do this?
		lowering_to_announcement = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcement = global.config.Get(elevating_to_configuration_key)

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	announcement_color = "green"
	sound = 'sound/misc/notice2.ogg' // Friendly beep
	number_level = SEC_LEVEL_GREEN
	lowering_to_configuration_key = /datum/config_entry/string/alert_green
	shuttle_call_time_mod = ALERT_COEFF_GREEN

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	announcement_color = "blue"
	sound = 'sound/misc/notice1.ogg' // Angry alarm
	number_level = SEC_LEVEL_BLUE
	lowering_to_configuration_key = /datum/config_entry/string/alert_blue_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_blue_upto
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	announcement_color = "red"
	sound = 'sound/misc/notice3.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * DELTA
 *
 * Station destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	sound = 'sound/misc/airraid.ogg' // Air alarm to signify importance
	number_level = SEC_LEVEL_DELTA
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	shuttle_call_time_mod = ALERT_COEFF_DELTA
