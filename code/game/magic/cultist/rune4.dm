/obj/rune/proc/tearreality()
	var/cultist_count = 0
	for(var/mob/M in orange(1,src))
		if(cultists.Find(M))
			M.say("Tok-lyr rqa'nap g'lt-ulotf!")
			cultist_count += 1
	if(cultist_count >= 9)
		var/obj/machinery/the_singularity/S = new /obj/machinery/the_singularity/(src.loc)
		S.icon = 'magic_terror.dmi'
		S.name = "Tear in the Fabric of Reality"
		S.desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
		S.pixel_x = -89
		S.pixel_y = -85
		message_admins("<h1><font color=\"purple\"><b><u>[key_name_admin(usr)] has summoned a Tear in the Fabric of Reality!", 1)
		return
	else
		return fizzle()