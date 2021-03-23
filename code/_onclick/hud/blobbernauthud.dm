/datum/hud/living/blobbernaut/New(mob/living/owner)
	. = ..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/naut/core()
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay
