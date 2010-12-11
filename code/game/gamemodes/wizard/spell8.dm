/client/proc/magicmissile()
	set category = "Spells"
	set name = "Magic missile"
	set desc="Whom"
	if(!usr.casting()) return

	for (var/mob/M as mob in oview())
		spawn(0)
			var/obj/overlay/A = new /obj/overlay( usr.loc )
			A.icon_state = "magicm"
			A.icon = 'wizard.dmi'
			A.name = "a magic missile"
			A.anchored = 0
			A.density = 0
			A.layer = 4
			var/i
			for(i=0, i<20, i++)
				var/obj/overlay/B = new /obj/overlay( A.loc )
				B.icon_state = "magicmd"
				B.icon = 'wizard.dmi'
				B.name = "trail"
				B.anchored = 1
				B.density = 0
				B.layer = 3
				spawn(5)
					del(B)
				step_to(A,M,0)
				if (get_dist(A,M) == 0)
					M.weakened += 5
					M.fireloss += 10
					del(A)
					return
				sleep(5)
			del(A)

	usr.verbs -= /client/proc/magicmissile
	spawn(100)
		usr.verbs += /client/proc/magicmissile
