/client/proc/blind(mob/M as mob in oview())
	set category = "Spells"
	set name = "Blind"
	if(!usr.casting()) return
	usr.verbs -= /client/proc/blind
	spawn(300)
		usr.verbs += /client/proc/blind

	usr.say("STI KALY!")
	usr.spellvoice()

	var/obj/overlay/B = new /obj/overlay( M.loc )
	B.icon_state = "blspell"
	B.icon = 'wizard.dmi'
	B.name = "spell"
	B.anchored = 1
	B.density = 0
	B.layer = 4
	M.canmove = 0
	spawn(5)
		del(B)
		M.canmove = 1
	M << text("\blue Your eyes cry out in pain!")
	M.disabilities |= 1
	spawn(300)
		M.disabilities &= ~1
	M.eye_blind = 10
	M.eye_blurry = 20
	return
