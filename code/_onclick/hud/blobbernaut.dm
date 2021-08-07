/datum/hud/living/blobbernaut/New(mob/living/owner)
	. = ..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/overmind()
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay
