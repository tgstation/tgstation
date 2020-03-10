/mob/living/proc/check_if_can_breathe(mob/living/L)
	if(!istype(L, /mob/living/carbon))
		return
	var/mob/living/carbon/C = L
	if(C.failed_last_breath == 1 && C.silent < 5)
		C.silent = 5