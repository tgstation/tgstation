GLOBAL_LIST_INIT(sfx_by_id, init_sfx())

/// Used to convert a SFX define into a .ogg so we can add some variance to sounds.
/// If soundin is already a .ogg, we simply return it
/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin

	var/datum/sfx/sfx = GLOB.sfx_by_id[soundin]
	return sfx?.get_random_sound() || soundin

/proc/init_sfx()
	var/list/sfx_by_id = list()
	for(var/sfx_subtype in subtypesof(/datum/sfx))
		var/datum/sfx/sfx = new sfx_subtype()
		if(isnull(sfx.id))
			stack_trace("SFX category [sfx_subtype]` has no `id` defined")
			continue

		if(length(sfx.sound_files) == 0)
			stack_trace("SFX category [sfx_subtype] has no `sound_files` associated")
			continue

		sfx_by_id[sfx.id] = sfx

	return sfx_by_id

/datum/sfx
	/// Used as key in `GLOB.sfx_by_id` list. Should not be null
	var/id
	/// List of available sound files for this sfx datum. Should not be null or empty
	var/list/sound_files = list()

/datum/sfx/proc/get_random_sound()
	if(length(sound_files) == 0)
		stack_trace("SFX category [type] has no sound files associated")
		return null

	return pick(sound_files)

/datum/sfx/shatter
	id = SFX_SHATTER
	sound_files = list('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')

/datum/sfx/explosion
	id = SFX_EXPLOSION
	sound_files = list('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')

/datum/sfx/explosion
	id = SFX_EXPLOSION
	sound_files = list('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')

/datum/sfx/explosion_creaking
	id = SFX_EXPLOSION_CREAKING
	sound_files = list('sound/effects/explosioncreak1.ogg', 'sound/effects/explosioncreak2.ogg')

/datum/sfx/hull_creaking
	id = SFX_HULL_CREAKING
	sound_files = list('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')

/datum/sfx/sparks
	id = SFX_SPARKS
	sound_files = list(
		'sound/effects/sparks1.ogg',
		'sound/effects/sparks2.ogg',
		'sound/effects/sparks3.ogg',
		'sound/effects/sparks4.ogg'
	)

/datum/sfx/rustle
	id = SFX_RUSTLE
	sound_files = list(
		'sound/effects/rustle1.ogg',
		'sound/effects/rustle2.ogg',
		'sound/effects/rustle3.ogg',
		'sound/effects/rustle4.ogg',
		'sound/effects/rustle5.ogg'
	)

/datum/sfx/bodyfall
	id = SFX_BODYFALL
	sound_files = list(
		'sound/effects/bodyfall1.ogg',
		'sound/effects/bodyfall2.ogg',
		'sound/effects/bodyfall3.ogg',
		'sound/effects/bodyfall4.ogg'
	)

/datum/sfx/punch
	id = SFX_PUNCH
	sound_files = list(
		'sound/weapons/punch1.ogg',
		'sound/weapons/punch2.ogg',
		'sound/weapons/punch3.ogg',
		'sound/weapons/punch4.ogg'
	)

/datum/sfx/clown_step
	id = SFX_CLOWN_STEP
	sound_files = list('sound/effects/footstep/clownstep1.ogg','sound/effects/footstep/clownstep2.ogg')

/datum/sfx/suit_step
	id = SFX_SUIT_STEP
	sound_files = list('sound/effects/suitstep1.ogg','sound/effects/suitstep2.ogg')

/datum/sfx/swing_hit
	id = SFX_SWING_HIT
	sound_files = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')

/datum/sfx/hiss
	id = SFX_HISS
	sound_files = list(
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss4.ogg'
	)

/datum/sfx/page_turn
	id = SFX_PAGE_TURN
	sound_files = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')

/datum/sfx/ricochet
	id = SFX_RICOCHET
	sound_files = list(
		'sound/weapons/effects/ric1.ogg',
		'sound/weapons/effects/ric2.ogg',
		'sound/weapons/effects/ric3.ogg',
		'sound/weapons/effects/ric4.ogg',
		'sound/weapons/effects/ric5.ogg'
	)

/datum/sfx/terminal_type
	id = SFX_TERMINAL_TYPE
	sound_files = list(
		'sound/machines/terminal_button01.ogg',
		'sound/machines/terminal_button02.ogg',
		'sound/machines/terminal_button03.ogg',
		'sound/machines/terminal_button04.ogg',
		'sound/machines/terminal_button05.ogg',
		'sound/machines/terminal_button06.ogg',
		'sound/machines/terminal_button07.ogg',
		'sound/machines/terminal_button08.ogg',
	)

/datum/sfx/desecration
	id = SFX_DESECRATION
	sound_files = list('sound/misc/desecration-01.ogg', 'sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg')

/datum/sfx/im_here
	id = SFX_IM_HERE
	sound_files = list('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')

/datum/sfx/can_open
	id = SFX_CAN_OPEN
	sound_files = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')

/datum/sfx/bullet_miss
	id = SFX_BULLET_MISS
	sound_files = list('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg')

/datum/sfx/revolver_spin
	id = SFX_REVOLVER_SPIN
	sound_files = list(
		'sound/weapons/gun/revolver/spin1.ogg',
		'sound/weapons/gun/revolver/spin2.ogg',
		'sound/weapons/gun/revolver/spin3.ogg'
	)

/datum/sfx/law
	id = SFX_LAW
	sound_files = list(
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/god.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/beepsky/insult.ogg',
		'sound/voice/beepsky/radio.ogg',
		'sound/voice/beepsky/secureday.ogg',
	)

/datum/sfx/honkbot_e
	id = SFX_HONKBOT_E
	sound_files = list(
		'sound/effects/pray.ogg',
		'sound/effects/reee.ogg',
		'sound/items/AirHorn.ogg',
		'sound/items/AirHorn2.ogg',
		'sound/items/bikehorn.ogg',
		'sound/items/WEEOO1.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/ping.ogg',
		'sound/magic/Fireball.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/hiss1.ogg',
		'sound/weapons/bladeslice.ogg',
		'sound/weapons/flashbang.ogg',
	)

/datum/sfx/goose
	id = SFX_GOOSE
	sound_files = list('sound/creatures/goose1.ogg', 'sound/creatures/goose2.ogg', 'sound/creatures/goose3.ogg', 'sound/creatures/goose4.ogg')

/datum/sfx/warpspeed
	id = SFX_WARPSPEED
	sound_files = list('sound/runtime/hyperspace/hyperspace_begin.ogg')

/datum/sfx/sm_calm
	id = SFX_SM_CALM
	sound_files = list(
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
	)

/datum/sfx/sm_delam
	id = SFX_SM_DELAM
	sound_files = list(
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
	)

/datum/sfx/hypertorus_calm
	id = SFX_HYPERTORUS_CALM
	sound_files = list(
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
	)

/datum/sfx/hypertorus_melting
	id = SFX_HYPERTORUS_MELTING
	sound_files = list(
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
	)

/datum/sfx/crunchy_bush_whack
	id = SFX_CRUNCHY_BUSH_WHACK
	sound_files = list(
		'sound/effects/crunchybushwhack1.ogg',
		'sound/effects/crunchybushwhack2.ogg',
		'sound/effects/crunchybushwhack3.ogg'
	)

/datum/sfx/tree_chop
	id = SFX_TREE_CHOP
	sound_files = list('sound/effects/treechop1.ogg', 'sound/effects/treechop2.ogg', 'sound/effects/treechop3.ogg')

/datum/sfx/rock_tap
	id = SFX_ROCK_TAP
	sound_files = list('sound/effects/rocktap1.ogg', 'sound/effects/rocktap2.ogg', 'sound/effects/rocktap3.ogg')

/datum/sfx/sear
	id = SFX_SEAR
	sound_files = list('sound/weapons/sear.ogg')

/datum/sfx/reel
	id = SFX_REEL
	sound_files = list(
		'sound/items/reel1.ogg',
		'sound/items/reel2.ogg',
		'sound/items/reel3.ogg',
		'sound/items/reel4.ogg',
		'sound/items/reel5.ogg',
	)

/datum/sfx/rattle
	id = SFX_RATTLE
	sound_files = list(
		'sound/items/rattle1.ogg',
		'sound/items/rattle2.ogg',
		'sound/items/rattle3.ogg',
	)

/datum/sfx/portal_close
	id = SFX_PORTAL_CLOSE
	sound_files = list('sound/effects/portal_close.ogg')

/datum/sfx/portal_enter
	id = SFX_PORTAL_ENTER
	sound_files = list('sound/effects/portal_travel.ogg')

/datum/sfx/portal_created
	id = SFX_PORTAL_CREATED
	sound_files = list(
		'sound/effects/portal_open_1.ogg',
		'sound/effects/portal_open_2.ogg',
		'sound/effects/portal_open_3.ogg',
	)

/datum/sfx/screech
	id = SFX_SCREECH
	sound_files = list(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)
