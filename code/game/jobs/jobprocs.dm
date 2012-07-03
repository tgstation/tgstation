

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
	var/obj/effect/forcefield/F =  new /obj/effect/forcefield(locate(usr.x,usr.y,usr.z))
	F.icon_state = "empty"
	F.name = "invisible wall"
	F.desc = "You have a bad feeling about this."
	spawn (300)
		del (F)
	return

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
