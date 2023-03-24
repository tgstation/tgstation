GLOBAL_VAR_INIT(gods_battling, FALSE)
GLOBAL_VAR_INIT(narsie_breaching, FALSE)
GLOBAL_VAR(narsie_arrival)

/proc/check_gods_battle()
	if(GLOB.cult_narsie && GLOB.cult_ratvar)
		if(!GLOB.gods_battling)
			GLOB.gods_battling = TRUE
			trigger_battle_of_the_gods()
		return TRUE
	return FALSE

/proc/trigger_battle_of_the_gods()
	//Oh dear god what have you done.
	//The only way this is actually possible in game is on dynamic (with restrictions turned off) and cult summon nar'sie after the ark activates.
	to_chat(world, span_userdanger("Мне страшно!"))
	var/obj/ratvar/R = GLOB.cult_ratvar
	var/obj/narsie/N = GLOB.cult_narsie
	R.ratvar_target = N
	N.clashing = R
