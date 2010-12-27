/mob/living/silicon/aihologram/New()
	..()
	if(parent_ai)
		src.name = parent_ai:name
		src.real_name = parent_ai:real_name

/mob/living/silicon/aihologram/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/living/silicon/aihologram/proc/ai_roster()
	set category = "AI Commands"
	set name = "Show Crew Manifest"

	var/dat = "<html><head><title>Crew Roster</title></head><body><b>Crew Roster:</b><br><br>"

	for (var/datum/data/record/t in data_core.general)
		dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"

	dat += "</body></html>"

	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/aihologram/ex_act(severity) //something immaterial is immune to bombs and everything else, really
	return

/mob/living/silicon/aihologram/meteorhit(obj/O as obj)
	return

/mob/living/silicon/aihologram/bullet_act(flag)
	return

/mob/living/silicon/aihologram/proc/back_to_ai()
	set category = "AI Commands"
	set name = "Return To AI"
	del(src)
