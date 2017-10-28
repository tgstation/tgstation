/atom/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/image/I = image('hippiestation/icons/mob/hud.dmi', src, "")
		I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
		hud_list[hud] = I