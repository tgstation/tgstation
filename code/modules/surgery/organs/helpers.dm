mob/proc/getorgan()
	return
mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)