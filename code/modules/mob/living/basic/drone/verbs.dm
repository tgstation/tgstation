/**
 * Echoes drone laws to the user
 *
 * See [/mob/living/basic/drone/var/laws]
 */
GAME_VERB(/mob/living/basic/drone, check_laws, "Check Laws", "Drone")

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
<<<<<<< HEAD
DEFINE_VERB(/mob/living/basic/drone, drone_ping, "Drone ping", "Relinquish your life and enter the land of the dead.", FALSE, "Drone")
=======
GAME_VERB(/mob/living/basic/drone, drone_ping, "Drone ping", "Drone")

	var/area/A = get_area(loc)
	if(alert_s && A && stat != DEAD)
		var/msg = span_big("DRONE PING: [name]: [alert_s] priority alert in [A.name]!")
		alert_drones(msg)
