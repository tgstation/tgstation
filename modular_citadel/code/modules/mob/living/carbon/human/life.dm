/mob/living/carbon/human/Life()
		//citadel code
	if(stat != DEAD)
		handle_arousal()
	. = ..()

/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	if(ismob(loc))
		return ONE_ATMOSPHERE
	if(istype(loc, /obj/item/dogborg/sleeper))
		return ONE_ATMOSPHERE
	. = ..()

/mob/living/carbon/human/update_health_hud(shown_health_amount)
	. = ..()
	if(!client || !hud_used)
		return
	if(hud_used.staminas)
		hud_used.staminas.icon_state = staminahudamount()
	if(hud_used.staminabuffer)
		hud_used.staminabuffer.icon_state = staminabufferhudamount()
