/datum/event

	var/Lifetime  = 0
	var/ActiveFor = 0

	New()
		..()
		if(!Lifetime)
			Lifetime = rand(30, 120)

	proc
		Announce()

		Tick()

		Die()

		LongTerm()
			LongTermEvent = ActiveEvent
			ActiveEvent = null