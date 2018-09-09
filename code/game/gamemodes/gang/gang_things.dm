/obj/gang_signup_point
	name = "Gang Signup Point"
	icon = 'icons/obj/gang/signup_points.dmi'
	max_integrity = INFINITY
	obj_integrity = INFINITY
	anchored = TRUE
	var/datum/antagonist/gang/gang_to_use
	var/datum/team/gang/team_to_use

/obj/gang_signup_point/examine(mob/user)
	..()
	to_chat(user, "[team_to_use.name] currently has [team_to_use.points] points.")