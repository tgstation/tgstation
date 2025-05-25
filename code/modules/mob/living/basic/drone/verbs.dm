/**
 * Echoes drone laws to the user
 *
 * See [/mob/living/basic/drone/var/laws]
 */
DEFINE_VERB(/mob/living/basic/drone, check_laws, "Check Laws", "", FALSE, "Drone")
	to_chat(src, "<b>Drone Laws</b>")
	to_chat(src, laws)

/**
 * Creates an alert to drones in the same network
 *
 * Prompts user for alert level of:
 * * Low
 * * Medium
 * * High
 * * Critical
 *
 * Attaches area name to message
 */
DEFINE_VERB(/mob/living/basic/drone, drone_ping, "Drone ping", "Relinquish your life and enter the land of the dead.", FALSE, "Drone")
	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = span_boldnotice("DRONE PING: [name]: [alert_s] priority alert in [A.name]!")
		alert_drones(msg)
