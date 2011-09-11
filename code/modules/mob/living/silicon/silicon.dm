/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_organ_damage(40)
			src.stunned = max(src.stunned,rand(5,10))
		if(2)
			src.take_organ_damage(20)
			src.stunned = max(src.stunned,rand(1,5))
	flick("noise", src:flash)
	src << "\red <B>*BZZZT*</B>"
	src << "\red Warning: Electromagnetic pulse detected."
	..()

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return
