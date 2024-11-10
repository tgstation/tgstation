///Default override for echo
/sound
	echo = list(
		0, // Direct
		0, // DirectHF
		-10000, // Room, -10000 means no low frequency sound reverb
		-10000, // RoomHF, -10000 means no high frequency sound reverb
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)
	environment = SOUND_ENVIRONMENT_NONE //Default to none so sounds without overrides dont get reverb

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music) //wait for SSticker init to set the login music

	var/volume_modifier = prefs.read_preference(/datum/preference/numeric/sound_lobby_volume)
	if((prefs && volume_modifier) && !CONFIG_GET(flag/disallow_title_music))
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = volume_modifier, channel = CHANNEL_LOBBYMUSIC)) // MAD JAMS

///get a random frequency.
/proc/get_rand_frequency()
	return rand(32000, 55000)

///get_rand_frequency but lower range.
/proc/get_rand_frequency_low_range()
	return rand(38000, 45000)

///Used to convert a SFX define into a .ogg so we can add some variance to sounds. If soundin is already a .ogg, we simply return it
/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	switch(soundin)
		if(SFX_SHATTER)
			soundin = pick(
				'sound/effects/glass/glassbr1.ogg',
				'sound/effects/glass/glassbr2.ogg',
				'sound/effects/glass/glassbr3.ogg',
				)
		if(SFX_EXPLOSION)
			soundin = pick(
				'sound/effects/explosion/explosion1.ogg',
				'sound/effects/explosion/explosion2.ogg',
				)
		if(SFX_EXPLOSION_CREAKING)
			soundin = pick(
				'sound/effects/explosion/explosioncreak1.ogg',
				'sound/effects/explosion/explosioncreak2.ogg',
				)
		if(SFX_HULL_CREAKING)
			soundin = pick(
				'sound/effects/creak/creak1.ogg',
				'sound/effects/creak/creak2.ogg',
				'sound/effects/creak/creak3.ogg',
				)
		if(SFX_SPARKS)
			soundin = pick(
				'sound/effects/sparks/sparks1.ogg',
				'sound/effects/sparks/sparks2.ogg',
				'sound/effects/sparks/sparks3.ogg',
				'sound/effects/sparks/sparks4.ogg',
				)
		if(SFX_RUSTLE)
			soundin = pick(
				'sound/effects/rustle/rustle1.ogg',
				'sound/effects/rustle/rustle2.ogg',
				'sound/effects/rustle/rustle3.ogg',
				'sound/effects/rustle/rustle4.ogg',
				'sound/effects/rustle/rustle5.ogg',
				)
		if(SFX_BODYFALL)
			soundin = pick(
				'sound/effects/bodyfall/bodyfall1.ogg',
				'sound/effects/bodyfall/bodyfall2.ogg',
				'sound/effects/bodyfall/bodyfall3.ogg',
				'sound/effects/bodyfall/bodyfall4.ogg',
				)
		if(SFX_PUNCH)
			soundin = pick(
				'sound/items/weapons/punch1.ogg',
				'sound/items/weapons/punch2.ogg',
				'sound/items/weapons/punch3.ogg',
				'sound/items/weapons/punch4.ogg',
				)
		if(SFX_CLOWN_STEP)
			soundin = pick(
				'sound/effects/footstep/clownstep1.ogg',
				'sound/effects/footstep/clownstep2.ogg',
				)
		if(SFX_SUIT_STEP)
			soundin = pick(
			'sound/items/handling/armor_rustle/riot_armor/suitstep1.ogg',
			'sound/items/handling/armor_rustle/riot_armor/suitstep2.ogg',
			)
		if(SFX_SWING_HIT)
			soundin = pick(
				'sound/items/weapons/genhit1.ogg',
				'sound/items/weapons/genhit2.ogg',
				'sound/items/weapons/genhit3.ogg',
				)
		if(SFX_HISS)
			soundin = pick(
				'sound/mobs/non-humanoids/hiss/hiss1.ogg',
				'sound/mobs/non-humanoids/hiss/hiss2.ogg',
				'sound/mobs/non-humanoids/hiss/hiss3.ogg',
				'sound/mobs/non-humanoids/hiss/hiss4.ogg',
				)
		if(SFX_PAGE_TURN)
			soundin = pick(
				'sound/effects/page_turn/pageturn1.ogg',
				'sound/effects/page_turn/pageturn2.ogg',
				'sound/effects/page_turn/pageturn3.ogg',
				)
		if(SFX_RICOCHET)
			soundin = pick(
				'sound/items/weapons/effects/ric1.ogg',
				'sound/items/weapons/effects/ric2.ogg',
				'sound/items/weapons/effects/ric3.ogg',
				'sound/items/weapons/effects/ric4.ogg',
				'sound/items/weapons/effects/ric5.ogg',
				)
		if(SFX_TERMINAL_TYPE)
			soundin = pick(list(
				'sound/machines/terminal/terminal_button01.ogg',
				'sound/machines/terminal/terminal_button02.ogg',
				'sound/machines/terminal/terminal_button03.ogg',
				'sound/machines/terminal/terminal_button04.ogg',
				'sound/machines/terminal/terminal_button05.ogg',
				'sound/machines/terminal/terminal_button06.ogg',
				'sound/machines/terminal/terminal_button07.ogg',
				'sound/machines/terminal/terminal_button08.ogg',
			))
		if(SFX_DESECRATION)
			soundin = pick(
				'sound/effects/desecration/desecration-01.ogg',
				'sound/effects/desecration/desecration-02.ogg',
				'sound/effects/desecration/desecration-03.ogg',
				)
		if(SFX_IM_HERE)
			soundin = pick(
				'sound/effects/hallucinations/im_here1.ogg',
				'sound/effects/hallucinations/im_here2.ogg',
				)
		if(SFX_CAN_OPEN)
			soundin = pick(
				'sound/items/can/can_open1.ogg',
				'sound/items/can/can_open2.ogg',
				'sound/items/can/can_open3.ogg',
				)
		if(SFX_BULLET_MISS)
			soundin = pick(
				'sound/items/weapons/bulletflyby.ogg',
				'sound/items/weapons/bulletflyby2.ogg',
				'sound/items/weapons/bulletflyby3.ogg',
				)
		if(SFX_REVOLVER_SPIN)
			soundin = pick(
				'sound/items/weapons/gun/revolver/spin1.ogg',
				'sound/items/weapons/gun/revolver/spin2.ogg',
				'sound/items/weapons/gun/revolver/spin3.ogg',
				)
		if(SFX_LAW)
			soundin = pick(list(
				'sound/mobs/non-humanoids/beepsky/creep.ogg',
				'sound/mobs/non-humanoids/beepsky/god.ogg',
				'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
				'sound/mobs/non-humanoids/beepsky/insult.ogg',
				'sound/mobs/non-humanoids/beepsky/radio.ogg',
				'sound/mobs/non-humanoids/beepsky/secureday.ogg',
			))
		if(SFX_HONKBOT_E)
			soundin = pick(list(
				'sound/effects/pray.ogg',
				'sound/mobs/non-humanoids/frog/reee.ogg',
				'sound/items/airhorn/AirHorn.ogg',
				'sound/items/airhorn/AirHorn2.ogg',
				'sound/items/bikehorn.ogg',
				'sound/items/WEEOO1.ogg',
				'sound/machines/buzz/buzz-sigh.ogg',
				'sound/machines/ping.ogg',
				'sound/effects/magic/Fireball.ogg',
				'sound/misc/sadtrombone.ogg',
				'sound/mobs/non-humanoids/beepsky/creep.ogg',
				'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
				'sound/mobs/non-humanoids/hiss/hiss1.ogg',
				'sound/items/weapons/bladeslice.ogg',
				'sound/items/weapons/flashbang.ogg',
			))
		if(SFX_GOOSE)
			soundin = pick(
				'sound/mobs/non-humanoids/goose/goose1.ogg',
				'sound/mobs/non-humanoids/goose/goose2.ogg',
				'sound/mobs/non-humanoids/goose/goose3.ogg',
				'sound/mobs/non-humanoids/goose/goose4.ogg',
				)
		if(SFX_WARPSPEED)
			soundin = 'sound/runtime/hyperspace/hyperspace_begin.ogg'
		if(SFX_SM_CALM)
			soundin = pick(list(
				'sound/machines/sm/accent/normal/1.ogg',
				'sound/machines/sm/accent/normal/2.ogg',
				'sound/machines/sm/accent/normal/3.ogg',
				'sound/machines/sm/accent/normal/4.ogg',
				'sound/machines/sm/accent/normal/5.ogg',
				'sound/machines/sm/accent/normal/6.ogg',
				'sound/machines/sm/accent/normal/7.ogg',
				'sound/machines/sm/accent/normal/8.ogg',
				'sound/machines/sm/accent/normal/9.ogg',
				'sound/machines/sm/accent/normal/10.ogg',
				'sound/machines/sm/accent/normal/11.ogg',
				'sound/machines/sm/accent/normal/12.ogg',
				'sound/machines/sm/accent/normal/13.ogg',
				'sound/machines/sm/accent/normal/14.ogg',
				'sound/machines/sm/accent/normal/15.ogg',
				'sound/machines/sm/accent/normal/16.ogg',
				'sound/machines/sm/accent/normal/17.ogg',
				'sound/machines/sm/accent/normal/18.ogg',
				'sound/machines/sm/accent/normal/19.ogg',
				'sound/machines/sm/accent/normal/20.ogg',
				'sound/machines/sm/accent/normal/21.ogg',
				'sound/machines/sm/accent/normal/22.ogg',
				'sound/machines/sm/accent/normal/23.ogg',
				'sound/machines/sm/accent/normal/24.ogg',
				'sound/machines/sm/accent/normal/25.ogg',
				'sound/machines/sm/accent/normal/26.ogg',
				'sound/machines/sm/accent/normal/27.ogg',
				'sound/machines/sm/accent/normal/28.ogg',
				'sound/machines/sm/accent/normal/29.ogg',
				'sound/machines/sm/accent/normal/30.ogg',
				'sound/machines/sm/accent/normal/31.ogg',
				'sound/machines/sm/accent/normal/32.ogg',
				'sound/machines/sm/accent/normal/33.ogg',
			))
		if(SFX_SM_DELAM)
			soundin = pick(list(
				'sound/machines/sm/accent/delam/1.ogg',
				'sound/machines/sm/accent/delam/2.ogg',
				'sound/machines/sm/accent/delam/3.ogg',
				'sound/machines/sm/accent/delam/4.ogg',
				'sound/machines/sm/accent/delam/5.ogg',
				'sound/machines/sm/accent/delam/6.ogg',
				'sound/machines/sm/accent/delam/7.ogg',
				'sound/machines/sm/accent/delam/8.ogg',
				'sound/machines/sm/accent/delam/9.ogg',
				'sound/machines/sm/accent/delam/10.ogg',
				'sound/machines/sm/accent/delam/11.ogg',
				'sound/machines/sm/accent/delam/12.ogg',
				'sound/machines/sm/accent/delam/13.ogg',
				'sound/machines/sm/accent/delam/14.ogg',
				'sound/machines/sm/accent/delam/15.ogg',
				'sound/machines/sm/accent/delam/16.ogg',
				'sound/machines/sm/accent/delam/17.ogg',
				'sound/machines/sm/accent/delam/18.ogg',
				'sound/machines/sm/accent/delam/19.ogg',
				'sound/machines/sm/accent/delam/20.ogg',
				'sound/machines/sm/accent/delam/21.ogg',
				'sound/machines/sm/accent/delam/22.ogg',
				'sound/machines/sm/accent/delam/23.ogg',
				'sound/machines/sm/accent/delam/24.ogg',
				'sound/machines/sm/accent/delam/25.ogg',
				'sound/machines/sm/accent/delam/26.ogg',
				'sound/machines/sm/accent/delam/27.ogg',
				'sound/machines/sm/accent/delam/28.ogg',
				'sound/machines/sm/accent/delam/29.ogg',
				'sound/machines/sm/accent/delam/30.ogg',
				'sound/machines/sm/accent/delam/31.ogg',
				'sound/machines/sm/accent/delam/32.ogg',
				'sound/machines/sm/accent/delam/33.ogg',
			))
		if(SFX_HYPERTORUS_CALM)
			soundin = pick(list(
				'sound/machines/sm/accent/normal/1.ogg',
				'sound/machines/sm/accent/normal/2.ogg',
				'sound/machines/sm/accent/normal/3.ogg',
				'sound/machines/sm/accent/normal/4.ogg',
				'sound/machines/sm/accent/normal/5.ogg',
				'sound/machines/sm/accent/normal/6.ogg',
				'sound/machines/sm/accent/normal/7.ogg',
				'sound/machines/sm/accent/normal/8.ogg',
				'sound/machines/sm/accent/normal/9.ogg',
				'sound/machines/sm/accent/normal/10.ogg',
				'sound/machines/sm/accent/normal/11.ogg',
				'sound/machines/sm/accent/normal/12.ogg',
				'sound/machines/sm/accent/normal/13.ogg',
				'sound/machines/sm/accent/normal/14.ogg',
				'sound/machines/sm/accent/normal/15.ogg',
				'sound/machines/sm/accent/normal/16.ogg',
				'sound/machines/sm/accent/normal/17.ogg',
				'sound/machines/sm/accent/normal/18.ogg',
				'sound/machines/sm/accent/normal/19.ogg',
				'sound/machines/sm/accent/normal/20.ogg',
				'sound/machines/sm/accent/normal/21.ogg',
				'sound/machines/sm/accent/normal/22.ogg',
				'sound/machines/sm/accent/normal/23.ogg',
				'sound/machines/sm/accent/normal/24.ogg',
				'sound/machines/sm/accent/normal/25.ogg',
				'sound/machines/sm/accent/normal/26.ogg',
				'sound/machines/sm/accent/normal/27.ogg',
				'sound/machines/sm/accent/normal/28.ogg',
				'sound/machines/sm/accent/normal/29.ogg',
				'sound/machines/sm/accent/normal/30.ogg',
				'sound/machines/sm/accent/normal/31.ogg',
				'sound/machines/sm/accent/normal/32.ogg',
				'sound/machines/sm/accent/normal/33.ogg',
			))
		if(SFX_HYPERTORUS_MELTING)
			soundin = pick(list(
				'sound/machines/sm/accent/delam/1.ogg',
				'sound/machines/sm/accent/delam/2.ogg',
				'sound/machines/sm/accent/delam/3.ogg',
				'sound/machines/sm/accent/delam/4.ogg',
				'sound/machines/sm/accent/delam/5.ogg',
				'sound/machines/sm/accent/delam/6.ogg',
				'sound/machines/sm/accent/delam/7.ogg',
				'sound/machines/sm/accent/delam/8.ogg',
				'sound/machines/sm/accent/delam/9.ogg',
				'sound/machines/sm/accent/delam/10.ogg',
				'sound/machines/sm/accent/delam/11.ogg',
				'sound/machines/sm/accent/delam/12.ogg',
				'sound/machines/sm/accent/delam/13.ogg',
				'sound/machines/sm/accent/delam/14.ogg',
				'sound/machines/sm/accent/delam/15.ogg',
				'sound/machines/sm/accent/delam/16.ogg',
				'sound/machines/sm/accent/delam/17.ogg',
				'sound/machines/sm/accent/delam/18.ogg',
				'sound/machines/sm/accent/delam/19.ogg',
				'sound/machines/sm/accent/delam/20.ogg',
				'sound/machines/sm/accent/delam/21.ogg',
				'sound/machines/sm/accent/delam/22.ogg',
				'sound/machines/sm/accent/delam/23.ogg',
				'sound/machines/sm/accent/delam/24.ogg',
				'sound/machines/sm/accent/delam/25.ogg',
				'sound/machines/sm/accent/delam/26.ogg',
				'sound/machines/sm/accent/delam/27.ogg',
				'sound/machines/sm/accent/delam/28.ogg',
				'sound/machines/sm/accent/delam/29.ogg',
				'sound/machines/sm/accent/delam/30.ogg',
				'sound/machines/sm/accent/delam/31.ogg',
				'sound/machines/sm/accent/delam/32.ogg',
				'sound/machines/sm/accent/delam/33.ogg',
			))
		if(SFX_CRUNCHY_BUSH_WHACK)
			soundin = pick(
				'sound/effects/bush/crunchybushwhack1.ogg',
				'sound/effects/bush/crunchybushwhack2.ogg',
				'sound/effects/bush/crunchybushwhack3.ogg',
				)
		if(SFX_TREE_CHOP)
			soundin = pick(
				'sound/effects/treechop/treechop1.ogg',
				'sound/effects/treechop/treechop2.ogg',
				'sound/effects/treechop/treechop3.ogg',
				)
		if(SFX_ROCK_TAP)
			soundin = pick(
				'sound/effects/rock/rocktap1.ogg',
				'sound/effects/rock/rocktap2.ogg',
				'sound/effects/rock/rocktap3.ogg',
				)
		if(SFX_SEAR)
			soundin = 'sound/items/weapons/sear.ogg'
		if(SFX_REEL)
			soundin = pick(
				'sound/items/reel/reel1.ogg',
				'sound/items/reel/reel2.ogg',
				'sound/items/reel/reel3.ogg',
				'sound/items/reel/reel4.ogg',
				'sound/items/reel/reel5.ogg',
			)
		if(SFX_RATTLE)
			soundin = pick(
				'sound/items/rattle/rattle1.ogg',
				'sound/items/rattle/rattle2.ogg',
				'sound/items/rattle/rattle3.ogg',
			)
		if(SFX_PORTAL_CLOSE)
			soundin = 'sound/effects/portal/portal_close.ogg'
		if(SFX_PORTAL_ENTER)
			soundin = 'sound/effects/portal/portal_travel.ogg'
		if(SFX_PORTAL_CREATED)
			soundin = pick(
				'sound/effects/portal/portal_open_1.ogg',
				'sound/effects/portal/portal_open_2.ogg',
				'sound/effects/portal/portal_open_3.ogg',
			)
		if(SFX_SCREECH)
			soundin = pick(
				'sound/mobs/non-humanoids/monkey/monkey_screech_1.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_2.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_3.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_4.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_5.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_6.ogg',
				'sound/mobs/non-humanoids/monkey/monkey_screech_7.ogg',
			)
		if(SFX_TOOL_SWITCH)
			soundin = 'sound/items/tools/tool_switch.ogg'
		if(SFX_KEYBOARD_CLICKS)
			soundin = pick(
				'sound/machines/computer/keyboard_clicks_1.ogg',
				'sound/machines/computer/keyboard_clicks_2.ogg',
				'sound/machines/computer/keyboard_clicks_3.ogg',
				'sound/machines/computer/keyboard_clicks_4.ogg',
				'sound/machines/computer/keyboard_clicks_5.ogg',
				'sound/machines/computer/keyboard_clicks_6.ogg',
				'sound/machines/computer/keyboard_clicks_7.ogg',
			)
		if(SFX_STONE_DROP)
			soundin = pick(
				'sound/items/stones/stone_drop1.ogg',
				'sound/items/stones/stone_drop2.ogg',
				'sound/items/stones/stone_drop3.ogg',
			)
		if(SFX_STONE_PICKUP)
			soundin = pick(
				'sound/items/stones/stone_pick_up1.ogg',
				'sound/items/stones/stone_pick_up2.ogg',
			)
		if(SFX_MUFFLED_SPEECH)
			soundin = pick(
				'sound/effects/muffspeech/muffspeech1.ogg',
				'sound/effects/muffspeech/muffspeech2.ogg',
				'sound/effects/muffspeech/muffspeech3.ogg',
				'sound/effects/muffspeech/muffspeech4.ogg',
				'sound/effects/muffspeech/muffspeech5.ogg',
				'sound/effects/muffspeech/muffspeech6.ogg',
				'sound/effects/muffspeech/muffspeech7.ogg',
				'sound/effects/muffspeech/muffspeech8.ogg',
				'sound/effects/muffspeech/muffspeech9.ogg',
			)
		if(SFX_DEFAULT_FISH_SLAP)
			soundin = 'sound/mobs/non-humanoids/fish/fish_slap1.ogg'
		if(SFX_ALT_FISH_SLAP)
			soundin = 'sound/mobs/non-humanoids/fish/fish_slap2.ogg'
		if(SFX_FISH_PICKUP)
			soundin = pick(
				'sound/mobs/non-humanoids/fish/fish_pickup1.ogg',
				'sound/mobs/non-humanoids/fish/fish_pickup2.ogg',
			)
		if(SFX_LIQUID_POUR)
			soundin = pick(
				'sound/effects/liquid_pour/liquid_pour1.ogg',
				'sound/effects/liquid_pour/liquid_pour2.ogg',
				'sound/effects/liquid_pour/liquid_pour3.ogg',
			)
		if(SFX_SNORE_FEMALE)
			soundin = pick_weight(list(
				'sound/mobs/humanoids/human/snore/snore_female1.ogg' = 33,
				'sound/mobs/humanoids/human/snore/snore_female2.ogg' = 33,
				'sound/mobs/humanoids/human/snore/snore_female3.ogg' = 33,
				'sound/mobs/humanoids/human/snore/snore_mimimi1.ogg' = 1,
			))
		if(SFX_SNORE_MALE)
			soundin = pick_weight(list(
				'sound/mobs/humanoids/human/snore/snore_male1.ogg' = 20,
				'sound/mobs/humanoids/human/snore/snore_male2.ogg' = 20,
				'sound/mobs/humanoids/human/snore/snore_male3.ogg' = 20,
				'sound/mobs/humanoids/human/snore/snore_male4.ogg' = 20,
				'sound/mobs/humanoids/human/snore/snore_male5.ogg' = 20,
				'sound/mobs/humanoids/human/snore/snore_mimimi2.ogg' = 1,
			))
		if(SFX_CAT_MEOW)
			soundin = pick_weight(list(
				'sound/mobs/non-humanoids/cat/cat_meow1.ogg' = 33,
				'sound/mobs/non-humanoids/cat/cat_meow2.ogg' = 33,
				'sound/mobs/non-humanoids/cat/cat_meow3.ogg' = 33,
				'sound/mobs/non-humanoids/cat/oranges_meow1.ogg' = 1,
			))
		if(SFX_CAT_PURR)
			soundin = pick(
				'sound/mobs/non-humanoids/cat/cat_purr1.ogg',
				'sound/mobs/non-humanoids/cat/cat_purr2.ogg',
				'sound/mobs/non-humanoids/cat/cat_purr3.ogg',
				'sound/mobs/non-humanoids/cat/cat_purr4.ogg',
			)
		if(SFX_DEFAULT_LIQUID_SLOSH)
			soundin = pick(
				'sound/items/handling/reagent_containers/default/default_liquid_slosh1.ogg',
				'sound/items/handling/reagent_containers/default/default_liquid_slosh2.ogg',
				'sound/items/handling/reagent_containers/default/default_liquid_slosh3.ogg',
				'sound/items/handling/reagent_containers/default/default_liquid_slosh4.ogg',
				'sound/items/handling/reagent_containers/default/default_liquid_slosh5.ogg',
			)
		if(SFX_PLASTIC_BOTTLE_LIQUID_SLOSH)
			soundin = pick(
				'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh1.ogg',
				'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh2.ogg',
			)
		if(SFX_PLATE_ARMOR_RUSTLE)
			soundin = pick_weight(list(
				'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle1.ogg' = 8, //longest sound is rarer.
				'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle2.ogg' = 23,
				'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle3.ogg' = 23,
				'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle4.ogg' = 23,
				'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle5.ogg' = 23,
			))
		if(SFX_PIG_OINK)
			soundin = pick(
				'sound/mobs/non-humanoids/pig/pig1.ogg',
				'sound/mobs/non-humanoids/pig/pig2.ogg',
			)
		if(SFX_VISOR_DOWN)
			soundin = pick(
				'sound/items/handling/helmet/visor_down1.ogg',
				'sound/items/handling/helmet/visor_down2.ogg',
				'sound/items/handling/helmet/visor_down3.ogg',
			)
		if(SFX_VISOR_UP)
			soundin = pick(
				'sound/items/handling/helmet/visor_up1.ogg',
				'sound/items/handling/helmet/visor_up2.ogg',
			)
		if(SFX_GROWL)
			soundin = pick(
				'sound/mobs/non-humanoids/dog/growl1.ogg',
				'sound/mobs/non-humanoids/dog/growl2.ogg',
			)
		if(SFX_GROWL)
			soundin = pick(
				'sound/effects/wounds/sizzle1.ogg',
				'sound/effects/wounds/sizzle2.ogg',
			)
		if(SFX_POLAROID)
			soundin = pick(
				'sound/items/polaroid/polaroid1.ogg',
				'sound/items/polaroid/polaroid2.ogg',
			)
		if(SFX_HALLUCINATION_TURN_AROUND)
			soundin = pick(
				'sound/effects/hallucinations/turn_around1.ogg',
				'sound/effects/hallucinations/turn_around2.ogg',
			)
		if(SFX_HALLUCINATION_I_SEE_YOU)
			soundin = pick(
				'sound/effects/hallucinations/i_see_you1.ogg',
				'sound/effects/hallucinations/i_see_you2.ogg',
			)
		if(SFX_LOW_HISS)
			soundin = pick(
				'sound/mobs/non-humanoids/hiss/lowHiss2.ogg',
				'sound/mobs/non-humanoids/hiss/lowHiss3.ogg',
				'sound/mobs/non-humanoids/hiss/lowHiss4.ogg',
			)
		if(SFX_HALLUCINATION_I_M_HERE)
			soundin = pick(
				'sound/effects/hallucinations/im_here1.ogg',
				'sound/effects/hallucinations/im_here2.ogg',
			)
		if(SFX_HALLUCINATION_OVER_HERE)
			soundin = pick(
				'sound/effects/hallucinations/over_here2.ogg',
				'sound/effects/hallucinations/over_here3.ogg',
			)
		if(SFX_INDUSTRIAL_SCAN)
			soundin = pick(
				'sound/effects/industrial_scan/industrial_scan1.ogg',
				'sound/effects/industrial_scan/industrial_scan2.ogg',
				'sound/effects/industrial_scan/industrial_scan3.ogg',
			)
		if(SFX_MALE_SIGH)
			soundin = pick(
				'sound/mobs/humanoids/human/sigh/male_sigh1.ogg',
				'sound/mobs/humanoids/human/sigh/male_sigh2.ogg',
				'sound/mobs/humanoids/human/sigh/male_sigh3.ogg',
			)
		if(SFX_FEMALE_SIGH)
			soundin = pick(
				'sound/mobs/humanoids/human/sigh/female_sigh1.ogg',
				'sound/mobs/humanoids/human/sigh/female_sigh2.ogg',
				'sound/mobs/humanoids/human/sigh/female_sigh3.ogg',
			)
	return soundin
