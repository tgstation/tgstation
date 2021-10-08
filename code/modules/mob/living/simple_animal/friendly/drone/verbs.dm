
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons

/**
 * Echoes drone laws to the user
 *
 * See [/mob/living/simple_animal/drone/var/laws]
 */
/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

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
/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = span_boldnotice("DRONE PING: [name]: [alert_s] priority alert in [A.name]!")
		alert_drones(msg)
