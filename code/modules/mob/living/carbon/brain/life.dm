
/mob/living/carbon/brain/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return
	. = ..()
	handle_emp_damage()

/mob/living/carbon/brain/handle_breathing()
	return

/mob/living/carbon/brain/handle_mutations_and_radiation()
	return

/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/carbon/brain/update_stat()
	if(status_flags & GODMODE)
		return
	if(health <= config.health_threshold_dead)
		if(stat != DEAD)
			death()
		var/obj/item/organ/internal/brain/BR
		if(container && container.brain)
			BR = container.brain
		else if(istype(loc, /obj/item/organ/internal/brain))
			BR = loc
		if(BR)
			BR.damaged_brain = 1 //beaten to a pulp

/* //currently unused feature, since brain outside a mmi is always dead.
/mob/living/carbon/brain/proc/handle_brain_revival_life()
	if(stat != DEAD)
		if(config.revival_brain_life != -1)
			if( !container && (world.time - timeofhostdeath) > config.revival_brain_life)
				death()
*/

/mob/living/carbon/brain/proc/handle_emp_damage()
	if(emp_damage)
		if(stat == DEAD)
			emp_damage = 0
		else
			emp_damage = max(emp_damage-1, 0)

/mob/living/carbon/brain/handle_status_effects()
	return

/mob/living/carbon/brain/handle_disabilities()
	return

/mob/living/carbon/brain/setEarDamage() // no ears to damage or heal
	return

/mob/living/carbon/brain/adjustEarDamage()
	return

/mob/living/carbon/brain/blind_eyes() // no eyes to damage or heal
	return

/mob/living/carbon/brain/blur_eyes()
	return

/mob/living/carbon/brain/adjust_blindness()
	return

/mob/living/carbon/brain/adjust_blurriness()
	return

/mob/living/carbon/brain/set_blindness()
	return

/mob/living/carbon/brain/set_blurriness()
	return

/mob/living/carbon/brain/become_blind()
	return

/mob/living/carbon/brain/handle_changeling()
	return


