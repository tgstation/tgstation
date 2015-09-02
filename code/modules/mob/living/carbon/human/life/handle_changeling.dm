//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_changeling()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/carbon/human/proc/handle_changeling() called tick#: [world.time]")
	if(mind && mind.changeling)
		mind.changeling.regenerate()
		updateChangelingHUD()
