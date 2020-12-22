/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			. += "The current alert level is green."
		if(SEC_LEVEL_BLUE)
			. += "The current alert level is blue."
		if(SEC_LEVEL_AMBER)
			. += "The current alert level is amber."
		if(SEC_LEVEL_ORANGE)
			. += "The current alert level is orange."
		if(SEC_LEVEL_VIOLET)
			. += "The current alert level is violet."
		if(SEC_LEVEL_RED)
			. += "The current alert level is red!"
		if(SEC_LEVEL_DELTA)
			. += "The current alert level is delta! Evacuate!"
		if(SEC_LEVEL_GAMMA)
			. += "Gamma alert! All crew to stations!"