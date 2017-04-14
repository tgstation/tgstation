
/mob/living/brain/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return
	. = ..()
	handle_emp_damage()

/mob/living/brain/update_stat()
	if(status_flags & GODMODE)
		return
	if(health <= HEALTH_THRESHOLD_DEAD)
		if(stat != DEAD)
			death()
		var/obj/item/organ/brain/BR
		if(container && container.brain)
			BR = container.brain
		else if(istype(loc, /obj/item/organ/brain))
			BR = loc
		if(BR)
			BR.damaged_brain = 1 //beaten to a pulp

/* //currently unused feature, since brain outside a mmi is always dead.
/mob/living/brain/proc/handle_brain_revival_life()
	if(stat != DEAD)
		if(config.revival_brain_life != -1)
			if( !container && (world.time - timeofhostdeath) > config.revival_brain_life)
				death()
*/

/mob/living/brain/proc/handle_emp_damage()
	if(emp_damage)
		if(stat == DEAD)
			emp_damage = 0
		else
			emp_damage = max(emp_damage-1, 0)

/mob/living/brain/handle_status_effects()
	return

/mob/living/brain/handle_disabilities()
	return



