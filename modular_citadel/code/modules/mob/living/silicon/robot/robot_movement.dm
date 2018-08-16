/mob/living/silicon/robot
	var/sprinting = FALSE

/mob/living/silicon/robot/Move(NewLoc, direct)
	. = ..()
	if(. && sprinting && !(movement_type & FLYING) && canmove && !resting)
		if(istype(cell))
			cell.charge -= 25

/mob/living/silicon/robot/movement_delay()
	. = ..()
	if(!resting && !sprinting)
		. += 1

/mob/living/silicon/robot/proc/togglesprint() //Basically a copypaste of the proc from /mob/living/carbon/human
	sprinting = !sprinting
	if(!resting && canmove)
		if(sprinting)
			playsound_local(src, 'modular_citadel/sound/misc/sprintactivate.ogg', 50, FALSE, pressure_affected = FALSE)
		else
			playsound_local(src, 'modular_citadel/sound/misc/sprintdeactivate.ogg', 50, FALSE, pressure_affected = FALSE)
	if(hud_used && hud_used.static_inventory)
		for(var/obj/screen/sprintbutton/selector in hud_used.static_inventory)
			selector.insert_witty_toggle_joke_here(src)
	return TRUE
