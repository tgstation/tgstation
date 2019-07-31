
/datum/hud/revenant/New(mob/owner)
	..()

	healths = new /obj/screen/healths/revenant()
	infodisplay += healths
