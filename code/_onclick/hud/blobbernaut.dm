/datum/hud/living/blobbernaut/New(mob/living/owner)
	. = ..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/overmind(null, src)
	infodisplay += blobpwrdisplay
