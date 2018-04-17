/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	if(!round_end_sound)
		round_end_sound = pick(\
		'sound/roundend/newroundsexy.ogg',
		'sound/roundend/apcdestroyed.ogg',
		'sound/roundend/bangindonk.ogg',
		'sound/roundend/leavingtg.ogg',
		'sound/roundend/its_only_game.ogg',
		'sound/roundend/yeehaw.ogg',
		'hippiestation/sound/roundend/disappointed.ogg',
		'hippiestation/sound/roundend/enjoyedyourchaos.ogg',
		'hippiestation/sound/roundend/yamakemesick.ogg',
		'hippiestation/sound/roundend/trapsaregay.ogg',
		'hippiestation/sound/roundend/gayfrogs.ogg',
		'hippiestation/sound/roundend/nitrogen.ogg',
		'hippiestation/sound/roundend/henderson.ogg',
		'hippiestation/sound/roundend/gameoverinsertfourcoinstoplayagain.ogg',
		'hippiestation/sound/roundend/reasonsunknown.ogg'\
		)

	SEND_SOUND(world, sound(round_end_sound))
	text2file(login_music, "data/last_round_lobby_music.txt")