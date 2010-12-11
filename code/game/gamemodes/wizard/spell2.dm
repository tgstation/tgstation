/mob/proc/kill(mob/M as mob in oview(1))
	set category = "Spells"
	set name = "Disintegrate"
	if(!usr.casting()) return
	usr.verbs -= /mob/proc/kill
	spawn(600)
		usr.verbs += /mob/proc/kill

	usr.say("EI NATH")
	usr.spellvoice()

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(4, 1, M)
	s.start()

	M.dust()
