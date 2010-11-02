var/list/sacrificed = list()

/obj/rune/proc/sacrifice()
	var/culcount = 0
	for(var/mob/living/carbon/human/C in orange(1,src))
		if(cultists.Find(C))
			culcount++
	if(culcount>=3)
		for(var/mob/living/carbon/human/S in src.loc)
			if(ticker.mode.name == "cult")
				if(S == ticker.mode:sacrifice_target.current)//Iunno, check if it's a target
					sacrificed += S.mind
					S.gib(1)
					usr << "\red The Geometer of Blood accepts this sacrifice."
				else
					usr << "\red The Geometer of Blood does not accept this sacrifice."
				return
	return fizzle()