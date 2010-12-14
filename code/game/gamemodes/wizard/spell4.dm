/client/proc/fireball(mob/T as mob in oview())
	set category = "Spells"
	set name = "Fireball"
	set desc="Fireball target:"
//	if(!usr.casting()) return

	usr.verbs -= /client/proc/fireball
	spawn(200)
		usr.verbs += /client/proc/fireball

	usr.say("ONI SOMA")
//	usr.spellvoice()

	var/obj/overlay/A = new /obj/overlay( usr.loc )
	A.icon_state = "fireball"
	A.icon = 'wizard.dmi'
	A.name = "a fireball"
	A.anchored = 0
	A.density = 0
	var/i
	for(i=0, i<100, i++)
		step_to(A,T,0)
		if (get_dist(A,T) <= 1)
			T.bruteloss += 20
			T.fireloss += 25

			explosion(T.loc, -1, -1, 2, 2)
			del(A)
			return
		sleep(2)
	del(A)
	return
