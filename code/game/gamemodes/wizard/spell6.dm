/obj/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'mob.dmi'
	icon_state = "shield"
	anchored = 1.0
	opacity = 0
	density = 1

/client/proc/forcewall()

	set category = "Spells"
	set name = "Forcewall"
	set desc = "Create a forcewall on your location."

//	if(!usr.casting()) return

	usr.verbs -= /client/proc/forcewall
	spawn(100)
		usr.verbs += /client/proc/forcewall
	var/forcefield

	usr.whisper("TARCOL MINTI ZHERI")
//	usr.spellvoice()

	forcefield =  new /obj/forcefield(locate(usr.x,usr.y,usr.z))
	spawn (300)
		del (forcefield)
	return
