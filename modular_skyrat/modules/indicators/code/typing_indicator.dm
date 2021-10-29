GLOBAL_VAR_INIT(typing_indicator_overlay, mutable_appearance('modular_skyrat/modules/indicators/icons/typing_indicator.dmi', "default0", FLY_LAYER))

/mob
	var/typing_indicator = FALSE

/mob/proc/set_typing_indicator(var/state)
	typing_indicator = state
	if(typing_indicator)
		add_overlay(GLOB.typing_indicator_overlay)
	else
		cut_overlay(GLOB.typing_indicator_overlay)

/mob/living/key_down(_key, client/user)
	if(!typing_indicator && stat == CONSCIOUS)
		var/list/binds = user.prefs?.key_bindings_by_key[_key]
		if(binds)
			if("Say" in binds)
				set_typing_indicator(TRUE)
			if("Me" in binds)
				set_typing_indicator(TRUE)
	return ..()

/proc/animate_speechbubble(image/I, list/show_to, duration)
	var/matrix/M = matrix()
	M.Scale(0,0)
	I.transform = M
	I.alpha = 0
	for(var/client/C in show_to)
		C.images += I
	animate(I, transform = 0, alpha = 255, time = 5, easing = ELASTIC_EASING)
	sleep(duration-5)
	animate(I, alpha = 0, time = 5, easing = EASE_IN)
	sleep(20)
	for(var/client/C in show_to)
		C.images -= I
