

datum/radio_info
	var/title = ""
	var/description = ""
	var/url = ""

	New(var/list/json)
		title  = json["title"]
		description = json["description"]
		url  = json["url"]

	proc/display()
		// TODO

	proc/display_title()
		// TODO

/obj/machinery/media/boombox
	name = "Boombox
	desc = "The reason the singularity is loose..."
	icon = 'icons/obj/boombox.dmi' // TODO
	icon_state = "placeholder"
	density = 1"

	anchored = 1
	luminosity = 2

	var/playing = 0
	var/power = 0 // powered by batteries

/obj/machinery/media/boombox/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/media/boombox/attack_paw()
	return

// main stuff here, focus on making it work for now, polish after
/obj/machinery/media/boombox/attack_hand(var/mob/user)
	if (playing)
		playing = 0

	else
		playing = 1
