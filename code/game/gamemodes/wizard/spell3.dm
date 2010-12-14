/client/proc/knock()
	set category = "Spells"
	set name = "Knock"
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/knock
	spawn(100)
		usr.verbs += /client/proc/knock

	usr.whisper("AULIE OXIN FIERA")
//	usr.spellvoice()

	for(var/obj/machinery/door/G in oview(3))
		spawn(1)
			G.open()
	return
