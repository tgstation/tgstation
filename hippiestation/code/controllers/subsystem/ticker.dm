/datum/controller/subsystem/ticker	// hippie lobby music playing
	var/login_music_name

/datum/controller/subsystem/ticker/Initialize(timeofday)	// hippie lobby music playing
	. = ..()
	login_music_name = pop(splittext(login_music, "/"))

/datum/controller/subsystem/ticker/Shutdown()	//hippie roundend sounds
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()
	if(!round_end_sound)
		round_end_sound = pick(\
		'sound/roundend/newroundsexy.ogg',
		'sound/roundend/apcdestroyed.ogg',
		'sound/roundend/bangindonk.ogg',
		'sound/roundend/leavingtg.ogg',
		'sound/roundend/its_only_game.ogg',
		'sound/roundend/yeehaw.ogg',
		'sound/roundend/disappointed.ogg',
		'sound/roundend/scrunglartiy.ogg',
		'sound/roundend/petersondisappointed.ogg',
		'sound/roundend/bully2.ogg',
		'hippiestation/sound/roundend/disappointed.ogg',
		'hippiestation/sound/roundend/enjoyedyourchaos.ogg',
		'hippiestation/sound/roundend/yamakemesick.ogg',
		'hippiestation/sound/roundend/trapsaregay.ogg',
		'hippiestation/sound/roundend/gayfrogs.ogg',
		'hippiestation/sound/roundend/nitrogen.ogg',
		'hippiestation/sound/roundend/henderson.ogg',
		'hippiestation/sound/roundend/gameoverinsertfourcoinstoplayagain.ogg',
		'hippiestation/sound/roundend/reasonsunknown.ogg',
		'hippiestation/sound/roundend/moon.ogg',
		'hippiestation/sound/roundend/welcomehomejosh.ogg',
		'hippiestation/sound/roundend/ssethdisappointed.ogg',
		'hippiestation/sound/roundend/ssethenjoyedyourchaos.ogg',
		'hippiestation/sound/roundend/MEHEARTIESTHERESA.ogg',
		'hippiestation/sound/roundend/nomorecussing.ogg',
		'hippiestation/sound/roundend/ssethyoumakemesick.ogg'\
		)
	///The reference to the end of round sound that we have chosen.
	var/sound/end_of_round_sound_ref = sound(round_end_sound)
	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs?.toggles & SOUND_ENDOFROUND)
			SEND_SOUND(M.client, end_of_round_sound_ref)

	text2file(login_music, "data/last_round_lobby_music.txt")
