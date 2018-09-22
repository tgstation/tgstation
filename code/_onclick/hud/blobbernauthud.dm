
/datum/hud/blobbernaut/New(mob/owner)
	..()

	blobpwrdisplay = new /obj/screen/healths/blob/naut/core()
	infodisplay += blobpwrdisplay

	healths = new /obj/screen/healths/blob/naut()
	infodisplay += healths
