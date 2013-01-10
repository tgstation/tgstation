

//TODO: put these somewhere else
/client/proc/mimewall()
	set category = "Mime"
	set name = "Invisible wall"
	set desc = "Create an invisible wall on your location."
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(!H.miming)
		usr << "You still haven't atoned for your speaking transgression. Wait."
		return
	H.verbs -= /client/proc/mimewall
	spawn(300)
		H.verbs += /client/proc/mimewall
	for (var/mob/V in viewers(H))
		if(V!=usr)
			V.show_message("[H] looks as if a wall is in front of them.", 3, "", 2)
	usr << "You form a wall in front of yourself."
	new /obj/effect/forcefield/mime(locate(usr.x,usr.y,usr.z))
	return

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	var/timeleft = 300
	var/last_process = 0

/obj/effect/forcefield/mime/New()
	..()
	last_process = world.time
	processing_objects.Add(src)

/obj/effect/forcefield/mime/process()
	timeleft -= (world.time - last_process)
	if(timeleft <= 0)
		processing_objects.Remove(src)
		del(src)

///////////////////////////////

/client/proc/mimespeak()
	set category = "Mime"
	set name = "Speech"
	set desc = "Toggle your speech."
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(H.miming)
		H.miming = 0
	else
		H << "You'll have to wait if you want to atone for your sins."
		spawn(3000)
			H.miming = 1
	return
