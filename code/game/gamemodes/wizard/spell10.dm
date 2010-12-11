/client/proc/mutate()
	set category = "Spells"
	set name = "Mutate"
	if(!usr.casting()) return
	usr.verbs -= /client/proc/mutate
	spawn(400)
		usr.verbs += /client/proc/mutate

	usr.say("BIRUZ BENNAR")
	usr.spellvoice()

	usr << text("\blue You feel strong! Your mind expands!")
	if (!(usr.mutations & 8))
		usr.mutations |= 8
	if (!(usr.mutations & 1))
		usr.mutations |= 1
	spawn (300)
		if (usr.mutations & 1) usr.mutations &= ~1
		if (usr.mutations & 8) usr.mutations &= ~8
	return
