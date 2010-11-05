/obj/rune/proc/convert()
	for(var/mob/living/carbon/human/M in src.loc)
		if(cultists.Find(M))
			return fizzle()
		if(M.stat==2)
			return fizzle()
		if(ticker.mode.name == "cult")
			var/list/uncons = call(/datum/game_mode/cult/proc/get_unconvertables)()
			if(M.mind in uncons)
				return fizzle()
			ticker.mode:add_cultist(M.mind)
		usr.say("Mah'weyh pleggh at e'ntrath!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [M] writhes in pain as the markings below him glow a bloody red.", 3, "\red You hear an anguished scream.", 2)
		M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
		M << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
		cultists.Add(M)
		return
	return fizzle()