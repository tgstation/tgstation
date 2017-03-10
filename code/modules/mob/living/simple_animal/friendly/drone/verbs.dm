
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	to_chat(src, "<b>Drone Laws</b>")
	to_chat(src, laws)

/mob/living/simple_animal/drone/verb/toggle_light()
	set category = "Drone"
	set name = "Toggle drone light"
	if(light_on)
		set_light(0)
	else
		set_light(8)

	light_on = !light_on

	to_chat(src, "<span class='notice'>Your light is now [light_on ? "on" : "off"].</span>")

/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>DRONE PING: [name]: [alert_s] priority alert in [A.name]!</span>"
		alert_drones(msg)


/mob/living/simple_animal/drone/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove non drone beings from your viewscreen."
	set category = "Drone"

	if(!seeStatic)
		to_chat(src, "<span class='warning'>You have no vision filter to change!</span>")
		return

	var/selectedStatic = input("Select a vision filter", "Vision Filter") as null|anything in staticChoices
	if(selectedStatic in staticChoices)
		staticChoice = selectedStatic

	updateSeeStaticMobs()
