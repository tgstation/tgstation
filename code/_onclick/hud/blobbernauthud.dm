
/datum/hud/blobbernaut/New(mob/owner)
	..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/naut/core()
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay

	healths = new /atom/movable/screen/healths/blob/naut()
	healths.hud = src
	infodisplay += healths
