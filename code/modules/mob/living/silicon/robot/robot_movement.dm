/mob/living/silicon/robot/Move()
	. = ..()
	if(module.chop_on_move)
		var/mob/living/carbon/M = locate(/mob/living/carbon) in loc
		handle_slice(M)

/mob/living/silicon/robot/proc/handle_slice(mob/living/carbon/M)
	if(M.lying && iscarbon(M))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		playsound(loc, 'sound/weapons/chainsawhit.ogg', 50, 1)
		M.visible_message("<span class='warning'[src] drives over [M], crushing them!</span>")
		M.emote("scream")
		M.Unconscious(30) //Ouch!
		M.adjustBruteLoss(30)
		return TRUE
	else
		return FALSE


/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	if(ionpulse())
		return 1
	return ..()

/mob/living/silicon/robot/movement_delay()
	. = ..()
	var/static/config_robot_delay
	if(isnull(config_robot_delay))
		config_robot_delay = CONFIG_GET(number/robot_delay)
	. += speed + config_robot_delay

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
