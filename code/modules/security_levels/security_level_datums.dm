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
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The sound that we will play when this security level is set
	var/sound
	/// The shuttle call time modification of this security level
	var/shuttle_call_time_mod = 0
	/// Our announcement when lowering to this level
	var/lowering_to_announcement
	/// Our announcement when elevating to this level
	var/elevating_to_announcemnt
	/// Our configuration key for lowering to text, if set, will override the default lowering to announcement.
	var/lowering_to_configuration_key
	/// Our configuration key for elevating to text, if set, will override the default elevating to announcement.
	var/elevating_to_configuration_key

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key)
		lowering_to_announcement = CONFIG_GET(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcemnt = CONFIG_GET(elevating_to_configuration_key)

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	number_level = SEC_LEVEL_GREEN
	lowering_to_configuration_key = /datum/config_entry/string/alert_green

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	number_level = SEC_LEVEL_BLUE
	lowering_to_configuration_key = /datum/config_entry/string/alert_blue_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_blue_upto

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	number_level = SEC_LEVEL_RED
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto

/**
 * DELTA
 *
 * Station destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	number_level = SEC_LEVEL_DELTA
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
