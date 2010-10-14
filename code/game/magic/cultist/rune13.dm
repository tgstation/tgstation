/obj/rune/proc/mend()
	usr.say("Uhrast ka'hfa heldsagen ver'lot!")
	usr.bruteloss+=200
	runedec+=5
	for (var/mob/V in viewers(usr))
		V.show_message("\red [usr] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.", 3, "", 2)
	for(,usr.health<-100)
		sleep(600)
	runedec=0
	return