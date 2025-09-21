/**
# sound_effect datum
* use for when you need multiple sound files to play at random in a playsound
* see var documentation below
* initialized and added to sfx_datum_by_key in /datum/controller/subsystem/sounds/init_sound_keys()
*/
/datum/sound_effect
	/// sfx key define with which we are associated with, see code\__DEFINES\sound.dm
	var/key
	/// list of paths to our files, use the /assoc subtype if your paths are weighted
	var/list/file_paths

/datum/sound_effect/proc/return_sfx()
	return pick(file_paths)

/datum/sound_effect/shatter
	key = SFX_SHATTER
	file_paths = list(
		'sound/effects/glass/glassbr1.ogg',
		'sound/effects/glass/glassbr2.ogg',
		'sound/effects/glass/glassbr3.ogg',
	)

/datum/sound_effect/explosion
	key = SFX_EXPLOSION
	file_paths = list(
		'sound/effects/explosion/explosion1.ogg',
		'sound/effects/explosion/explosion2.ogg',
	)

/datum/sound_effect/explosion_creaking
	key = SFX_EXPLOSION_CREAKING
	file_paths = list(
		'sound/effects/explosion/explosioncreak1.ogg',
		'sound/effects/explosion/explosioncreak2.ogg',
	)

/datum/sound_effect/hull_creaking
	key = SFX_HULL_CREAKING
	file_paths = list(
		'sound/effects/creak/creak1.ogg',
		'sound/effects/creak/creak2.ogg',
		'sound/effects/creak/creak3.ogg',
	)

/datum/sound_effect/sparks
	key = SFX_SPARKS
	file_paths = list(
		'sound/effects/sparks/sparks1.ogg',
		'sound/effects/sparks/sparks2.ogg',
		'sound/effects/sparks/sparks3.ogg',
		'sound/effects/sparks/sparks4.ogg',
	)

/datum/sound_effect/rustle
	key = SFX_RUSTLE
	file_paths = list(
		'sound/effects/rustle/rustle1.ogg',
		'sound/effects/rustle/rustle2.ogg',
		'sound/effects/rustle/rustle3.ogg',
		'sound/effects/rustle/rustle4.ogg',
		'sound/effects/rustle/rustle5.ogg',
	)

/datum/sound_effect/bodyfall
	key = SFX_BODYFALL
	file_paths = list(
		'sound/effects/bodyfall/bodyfall1.ogg',
		'sound/effects/bodyfall/bodyfall2.ogg',
		'sound/effects/bodyfall/bodyfall3.ogg',
		'sound/effects/bodyfall/bodyfall4.ogg',
	)

/datum/sound_effect/punch
	key = SFX_PUNCH
	file_paths = list(
		'sound/items/weapons/punch1.ogg',
		'sound/items/weapons/punch2.ogg',
		'sound/items/weapons/punch3.ogg',
		'sound/items/weapons/punch4.ogg',
	)

/datum/sound_effect/clown_step
	key = SFX_CLOWN_STEP
	file_paths = list(
		'sound/effects/footstep/clownstep1.ogg',
		'sound/effects/footstep/clownstep2.ogg',
	)

/datum/sound_effect/suit_step
	key = SFX_SUIT_STEP
	file_paths = list(
		'sound/items/handling/armor_rustle/riot_armor/suitstep1.ogg',
		'sound/items/handling/armor_rustle/riot_armor/suitstep2.ogg',
	)

/datum/sound_effect/swing_hit
	key = SFX_SWING_HIT
	file_paths = list(
		'sound/items/weapons/genhit1.ogg',
		'sound/items/weapons/genhit2.ogg',
		'sound/items/weapons/genhit3.ogg',
	)

/datum/sound_effect/hiss
	key = SFX_HISS
	file_paths = list(
		'sound/mobs/non-humanoids/hiss/hiss1.ogg',
		'sound/mobs/non-humanoids/hiss/hiss2.ogg',
		'sound/mobs/non-humanoids/hiss/hiss3.ogg',
		'sound/mobs/non-humanoids/hiss/hiss4.ogg',
	)

/datum/sound_effect/page_turn
	key = SFX_PAGE_TURN
	file_paths = list(
		'sound/effects/page_turn/pageturn1.ogg',
		'sound/effects/page_turn/pageturn2.ogg',
		'sound/effects/page_turn/pageturn3.ogg',
	)

/datum/sound_effect/ricochet
	key = SFX_RICOCHET
	file_paths = list(
		'sound/items/weapons/effects/ric1.ogg',
		'sound/items/weapons/effects/ric2.ogg',
		'sound/items/weapons/effects/ric3.ogg',
		'sound/items/weapons/effects/ric4.ogg',
		'sound/items/weapons/effects/ric5.ogg',
	)

/datum/sound_effect/terminal_type
	key = SFX_TERMINAL_TYPE
	file_paths = list(
		'sound/machines/terminal/terminal_button01.ogg',
		'sound/machines/terminal/terminal_button02.ogg',
		'sound/machines/terminal/terminal_button03.ogg',
		'sound/machines/terminal/terminal_button04.ogg',
		'sound/machines/terminal/terminal_button05.ogg',
		'sound/machines/terminal/terminal_button06.ogg',
		'sound/machines/terminal/terminal_button07.ogg',
		'sound/machines/terminal/terminal_button08.ogg',
	)

/datum/sound_effect/desecration
	key = SFX_DESECRATION
	file_paths = list(
		'sound/effects/desecration/desecration-01.ogg',
		'sound/effects/desecration/desecration-02.ogg',
		'sound/effects/desecration/desecration-03.ogg',
	)

/datum/sound_effect/im_here
	key = SFX_IM_HERE
	file_paths = list(
		'sound/effects/hallucinations/im_here1.ogg',
		'sound/effects/hallucinations/im_here2.ogg',
	)

/datum/sound_effect/can_open
	key = SFX_CAN_OPEN
	file_paths = list(
		'sound/items/can/can_open1.ogg',
		'sound/items/can/can_open2.ogg',
		'sound/items/can/can_open3.ogg',
	)

/datum/sound_effect/bullet_miss
	key = SFX_BULLET_MISS
	file_paths = list(
		'sound/items/weapons/bulletflyby.ogg',
		'sound/items/weapons/bulletflyby2.ogg',
		'sound/items/weapons/bulletflyby3.ogg',
	)

/datum/sound_effect/revolver_spin
	key = SFX_REVOLVER_SPIN
	file_paths = list(
		'sound/items/weapons/gun/revolver/spin1.ogg',
		'sound/items/weapons/gun/revolver/spin2.ogg',
		'sound/items/weapons/gun/revolver/spin3.ogg',
	)

/datum/sound_effect/law
	key = SFX_LAW
	file_paths = list(
		'sound/mobs/non-humanoids/beepsky/creep.ogg',
		'sound/mobs/non-humanoids/beepsky/god.ogg',
		'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
		'sound/mobs/non-humanoids/beepsky/insult.ogg',
		'sound/mobs/non-humanoids/beepsky/radio.ogg',
		'sound/mobs/non-humanoids/beepsky/secureday.ogg',
	)

/datum/sound_effect/honkbot_e
	key = SFX_HONKBOT_E
	file_paths = list(
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
	)

/datum/sound_effect/goose
	key = SFX_GOOSE
	file_paths = list(
		'sound/mobs/non-humanoids/goose/goose1.ogg',
		'sound/mobs/non-humanoids/goose/goose2.ogg',
		'sound/mobs/non-humanoids/goose/goose3.ogg',
		'sound/mobs/non-humanoids/goose/goose4.ogg',
	)

/datum/sound_effect/warpspeed
	key = SFX_WARPSPEED
	file_paths = list('sound/runtime/hyperspace/hyperspace_begin.ogg')

/datum/sound_effect/sm_calm
	key = SFX_SM_CALM
	file_paths = list(
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

/datum/sound_effect/sm_delam
	key = SFX_SM_DELAM
	file_paths = list(
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

/datum/sound_effect/hypertorus_calm
	key = SFX_HYPERTORUS_CALM
	file_paths = list(
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

/datum/sound_effect/hypertorus_melting
	key = SFX_HYPERTORUS_MELTING
	file_paths = list(
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

/datum/sound_effect/crunchy_bush_whack
	key = SFX_CRUNCHY_BUSH_WHACK
	file_paths = list(
		'sound/effects/bush/crunchybushwhack1.ogg',
		'sound/effects/bush/crunchybushwhack2.ogg',
		'sound/effects/bush/crunchybushwhack3.ogg',
	)

/datum/sound_effect/tree_chop
	key = SFX_TREE_CHOP
	file_paths = list(
		'sound/effects/treechop/treechop1.ogg',
		'sound/effects/treechop/treechop2.ogg',
		'sound/effects/treechop/treechop3.ogg',
	)

/datum/sound_effect/rock_tap
	key = SFX_ROCK_TAP
	file_paths = list(
		'sound/effects/rock/rocktap1.ogg',
		'sound/effects/rock/rocktap2.ogg',
		'sound/effects/rock/rocktap3.ogg',
	)

/datum/sound_effect/sear
	key = SFX_SEAR
	file_paths = list('sound/items/weapons/sear.ogg')

/datum/sound_effect/reel
	key = SFX_REEL
	file_paths = list(
		'sound/items/reel/reel1.ogg',
		'sound/items/reel/reel2.ogg',
		'sound/items/reel/reel3.ogg',
		'sound/items/reel/reel4.ogg',
		'sound/items/reel/reel5.ogg',
	)

/datum/sound_effect/rattle
	key = SFX_RATTLE
	file_paths = list(
		'sound/items/rattle/rattle1.ogg',
		'sound/items/rattle/rattle2.ogg',
		'sound/items/rattle/rattle3.ogg',
	)

/datum/sound_effect/portal_close
	key = SFX_PORTAL_CLOSE
	file_paths = list('sound/effects/portal/portal_close.ogg')

/datum/sound_effect/portal_enter
	key = SFX_PORTAL_ENTER
	file_paths = list('sound/effects/portal/portal_travel.ogg')

/datum/sound_effect/portal_created
	key = SFX_PORTAL_CREATED
	file_paths = list(
		'sound/effects/portal/portal_open_1.ogg',
		'sound/effects/portal/portal_open_2.ogg',
		'sound/effects/portal/portal_open_3.ogg',
	)

/datum/sound_effect/screech
	key = SFX_SCREECH
	file_paths = list(
		'sound/mobs/non-humanoids/monkey/monkey_screech_1.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_2.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_3.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_4.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_5.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_6.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_7.ogg',
	)

/datum/sound_effect/tool_switch
	key = SFX_TOOL_SWITCH
	file_paths = list('sound/items/tools/tool_switch.ogg')

/datum/sound_effect/keyboard_clicks
	key = SFX_KEYBOARD_CLICKS
	file_paths = list(
		'sound/machines/computer/keyboard_clicks_1.ogg',
		'sound/machines/computer/keyboard_clicks_2.ogg',
		'sound/machines/computer/keyboard_clicks_3.ogg',
		'sound/machines/computer/keyboard_clicks_4.ogg',
		'sound/machines/computer/keyboard_clicks_5.ogg',
		'sound/machines/computer/keyboard_clicks_6.ogg',
		'sound/machines/computer/keyboard_clicks_7.ogg',
	)

/datum/sound_effect/stone_drop
	key = SFX_STONE_DROP
	file_paths = list(
		'sound/items/stones/stone_drop1.ogg',
		'sound/items/stones/stone_drop2.ogg',
		'sound/items/stones/stone_drop3.ogg',
	)

/datum/sound_effect/stone_pickup
	key = SFX_STONE_PICKUP
	file_paths = list(
		'sound/items/stones/stone_pick_up1.ogg',
		'sound/items/stones/stone_pick_up2.ogg',
	)

/datum/sound_effect/muffled_speech
	key = SFX_MUFFLED_SPEECH
	file_paths = list(
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

/datum/sound_effect/default_fish_slap
	key = SFX_DEFAULT_FISH_SLAP
	file_paths = list('sound/mobs/non-humanoids/fish/fish_slap1.ogg')

/datum/sound_effect/alt_fish_slap
	key = SFX_ALT_FISH_SLAP
	file_paths = list('sound/mobs/non-humanoids/fish/fish_slap2.ogg')

/datum/sound_effect/fish_pickup
	key = SFX_FISH_PICKUP
	file_paths = list(
		'sound/mobs/non-humanoids/fish/fish_pickup1.ogg',
		'sound/mobs/non-humanoids/fish/fish_pickup2.ogg',
	)

/datum/sound_effect/liquid_pour
	key = SFX_LIQUID_POUR
	file_paths = list(
		'sound/effects/liquid_pour/liquid_pour1.ogg',
		'sound/effects/liquid_pour/liquid_pour2.ogg',
		'sound/effects/liquid_pour/liquid_pour3.ogg',
	)
/datum/sound_effect/cat_purr
	key = SFX_CAT_PURR
	file_paths = list(
		'sound/mobs/non-humanoids/cat/cat_purr1.ogg',
		'sound/mobs/non-humanoids/cat/cat_purr2.ogg',
		'sound/mobs/non-humanoids/cat/cat_purr3.ogg',
		'sound/mobs/non-humanoids/cat/cat_purr4.ogg',
	)

/datum/sound_effect/default_liquid_slosh
	key = SFX_DEFAULT_LIQUID_SLOSH
	file_paths = list(
		'sound/items/handling/reagent_containers/default/default_liquid_slosh1.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh2.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh3.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh4.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh5.ogg',
	)

/datum/sound_effect/plastic_bottle_liquid_slosh
	key = SFX_PLASTIC_BOTTLE_LIQUID_SLOSH
	file_paths = list(
		'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh1.ogg',
		'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh2.ogg',
	)

/datum/sound_effect/pig_oink
	key = SFX_PIG_OINK
	file_paths = list(
		'sound/mobs/non-humanoids/pig/pig1.ogg',
		'sound/mobs/non-humanoids/pig/pig2.ogg',
	)

/datum/sound_effect/visor_down
	key = SFX_VISOR_DOWN
	file_paths = list(
		'sound/items/handling/helmet/visor_down1.ogg',
		'sound/items/handling/helmet/visor_down2.ogg',
		'sound/items/handling/helmet/visor_down3.ogg',
	)

/datum/sound_effect/visor_up
	key = SFX_VISOR_UP
	file_paths = list(
		'sound/items/handling/helmet/visor_up1.ogg',
		'sound/items/handling/helmet/visor_up2.ogg',
	)

/datum/sound_effect/growl
	key = SFX_GROWL
	file_paths = list(
		'sound/mobs/non-humanoids/dog/growl1.ogg',
		'sound/mobs/non-humanoids/dog/growl2.ogg',
	)

/datum/sound_effect/sizzle
	key = SFX_SIZZLE
	file_paths = list(
		'sound/effects/wounds/sizzle1.ogg',
		'sound/effects/wounds/sizzle2.ogg',
	)

/datum/sound_effect/polaroid
	key = SFX_POLAROID
	file_paths = list(
		'sound/items/polaroid/polaroid1.ogg',
		'sound/items/polaroid/polaroid2.ogg',
	)

/datum/sound_effect/hallucination_turn_around
	key = SFX_HALLUCINATION_TURN_AROUND
	file_paths = list(
		'sound/effects/hallucinations/turn_around1.ogg',
		'sound/effects/hallucinations/turn_around2.ogg',
	)

/datum/sound_effect/hallucination_i_see_you
	key = SFX_HALLUCINATION_I_SEE_YOU
	file_paths = list(
		'sound/effects/hallucinations/i_see_you1.ogg',
		'sound/effects/hallucinations/i_see_you2.ogg',
	)

/datum/sound_effect/low_hiss
	key = SFX_LOW_HISS
	file_paths = list(
		'sound/mobs/non-humanoids/hiss/lowHiss2.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss3.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss4.ogg',
	)

/datum/sound_effect/hallucination_i_m_here
	key = SFX_HALLUCINATION_I_M_HERE
	file_paths = list(
		'sound/effects/hallucinations/im_here1.ogg',
		'sound/effects/hallucinations/im_here2.ogg',
	)

/datum/sound_effect/hallucination_over_here
	key = SFX_HALLUCINATION_OVER_HERE
	file_paths = list(
		'sound/effects/hallucinations/over_here2.ogg',
		'sound/effects/hallucinations/over_here3.ogg',
	)

/datum/sound_effect/industrial_scan
	key = SFX_INDUSTRIAL_SCAN
	file_paths = list(
		'sound/effects/industrial_scan/industrial_scan1.ogg',
		'sound/effects/industrial_scan/industrial_scan2.ogg',
		'sound/effects/industrial_scan/industrial_scan3.ogg',
	)

/datum/sound_effect/male_sigh
	key = SFX_MALE_SIGH
	file_paths = list(
		'sound/mobs/humanoids/human/sigh/male_sigh1.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh2.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh3.ogg',
	)

/datum/sound_effect/female_sigh
	key = SFX_FEMALE_SIGH
	file_paths = list(
		'sound/mobs/humanoids/human/sigh/female_sigh1.ogg',
		'sound/mobs/humanoids/human/sigh/female_sigh2.ogg',
		'sound/mobs/humanoids/human/sigh/female_sigh3.ogg',
	)

/datum/sound_effect/writing_pen
	key = SFX_WRITING_PEN
	file_paths = list(
		'sound/effects/writing_pen/writing_pen1.ogg',
		'sound/effects/writing_pen/writing_pen2.ogg',
		'sound/effects/writing_pen/writing_pen3.ogg',
		'sound/effects/writing_pen/writing_pen4.ogg',
		'sound/effects/writing_pen/writing_pen5.ogg',
		'sound/effects/writing_pen/writing_pen6.ogg',
		'sound/effects/writing_pen/writing_pen7.ogg',
	)

/datum/sound_effect/clown_car_load
	key = SFX_CLOWN_CAR_LOAD
	file_paths = list(
		'sound/vehicles/clown_car/clowncar_load1.ogg',
		'sound/vehicles/clown_car/clowncar_load2.ogg',
	)

/datum/sound_effect/seatbelt_buckle
	key = SFX_SEATBELT_BUCKLE
	file_paths = list(
		'sound/machines/buckle/buckle1.ogg',
		'sound/machines/buckle/buckle2.ogg',
		'sound/machines/buckle/buckle3.ogg',
	)

/datum/sound_effect/seatbelt_unbuckle
	key = SFX_SEATBELT_UNBUCKLE
	file_paths = list(
		'sound/machines/buckle/unbuckle1.ogg',
		'sound/machines/buckle/unbuckle2.ogg',
		'sound/machines/buckle/unbuckle3.ogg',
	)

/datum/sound_effect/headset_equip
	key = SFX_HEADSET_EQUIP
	file_paths = list(
		'sound/items/equip/headset_equip1.ogg',
		'sound/items/equip/headset_equip2.ogg',
	)

/datum/sound_effect/headset_pickup
	key = SFX_HEADSET_PICKUP
	file_paths = list(
		'sound/items/handling/headset/headset_pickup1.ogg',
		'sound/items/handling/headset/headset_pickup2.ogg',
		'sound/items/handling/headset/headset_pickup3.ogg',
	)

/datum/sound_effect/bandage_begin
	key = SFX_BANDAGE_BEGIN
	file_paths = list(
		'sound/items/gauze/bandage_begin1.ogg',
		'sound/items/gauze/bandage_begin2.ogg',
		'sound/items/gauze/bandage_begin3.ogg',
		'sound/items/gauze/bandage_begin4.ogg',
	)

/datum/sound_effect/bandage_end
	key = SFX_BANDAGE_END
	file_paths = list(
		'sound/items/gauze/bandage_end1.ogg',
		'sound/items/gauze/bandage_end2.ogg',
		'sound/items/gauze/bandage_end3.ogg',
		'sound/items/gauze/bandage_end4.ogg',
	)

// Old cloth sounds are named cloth_...1.ogg, I wanted to keep them so these new ones go further down the line.
/datum/sound_effect/cloth_drop
	key = SFX_CLOTH_DROP
	file_paths = list(
		'sound/items/handling/cloth/cloth_drop2.ogg',
		'sound/items/handling/cloth/cloth_drop3.ogg',
		'sound/items/handling/cloth/cloth_drop4.ogg',
		'sound/items/handling/cloth/cloth_drop5.ogg',
	)

/datum/sound_effect/cloth_pickup
	key = SFX_CLOTH_PICKUP
	file_paths = list(
		'sound/items/handling/cloth/cloth_pickup2.ogg',
		'sound/items/handling/cloth/cloth_pickup3.ogg',
		'sound/items/handling/cloth/cloth_pickup4.ogg',
		'sound/items/handling/cloth/cloth_pickup5.ogg',
	)

/datum/sound_effect/suture_begin
	key = SFX_SUTURE_BEGIN
	file_paths = list('sound/items/suture/suture_begin1.ogg')

/datum/sound_effect/suture_continuous
	key = SFX_SUTURE_CONTINUOUS
	file_paths = list(
		'sound/items/suture/suture_continuous1.ogg',
		'sound/items/suture/suture_continuous2.ogg',
		'sound/items/suture/suture_continuous3.ogg',
	)

/datum/sound_effect/suture_end
	key = SFX_SUTURE_END
	file_paths = list(
		'sound/items/suture/suture_end1.ogg',
		'sound/items/suture/suture_end2.ogg',
		'sound/items/suture/suture_end3.ogg',
	)

/datum/sound_effect/suture_pickup
	key = SFX_SUTURE_PICKUP
	file_paths = list(
		'sound/items/handling/suture/needle_pickup1.ogg',
		'sound/items/handling/suture/needle_pickup2.ogg',
	)

/datum/sound_effect/suture_drop
	key = SFX_SUTURE_DROP
	file_paths = list(
		'sound/items/handling/suture/needle_drop1.ogg',
		'sound/items/handling/suture/needle_drop2.ogg',
		'sound/items/handling/suture/needle_drop3.ogg',
	)

/datum/sound_effect/regen_mesh_begin
	key = SFX_REGEN_MESH_BEGIN
	file_paths = list(
		'sound/items/regenerative_mesh/regen_mesh_begin1.ogg',
		'sound/items/regenerative_mesh/regen_mesh_begin2.ogg',
		'sound/items/regenerative_mesh/regen_mesh_begin3.ogg',
		'sound/items/regenerative_mesh/regen_mesh_begin4.ogg',
	)

/datum/sound_effect/regen_mesh_continuous
	key = SFX_REGEN_MESH_CONTINUOUS
	file_paths = list(
		'sound/items/regenerative_mesh/regen_mesh_continuous1.ogg',
		'sound/items/regenerative_mesh/regen_mesh_continuous2.ogg',
		'sound/items/regenerative_mesh/regen_mesh_continuous3.ogg',
		'sound/items/regenerative_mesh/regen_mesh_continuous4.ogg',
		'sound/items/regenerative_mesh/regen_mesh_continuous5.ogg',
	)

/datum/sound_effect/regen_mesh_end
	key = SFX_REGEN_MESH_END
	file_paths = list(
		'sound/items/regenerative_mesh/regen_mesh_end1.ogg',
		'sound/items/regenerative_mesh/regen_mesh_end2.ogg',
	)

/datum/sound_effect/regen_mesh_pickup
	key = SFX_REGEN_MESH_PICKUP
	file_paths = list(
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup1.ogg',
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup2.ogg',
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup3.ogg',
	)

/datum/sound_effect/regen_mesh_drop
	key = SFX_REGEN_MESH_DROP
	file_paths = list('sound/items/regenerative_mesh/regen_mesh_drop1.ogg')

/datum/sound_effect/cig_pack_drop
	key = SFX_CIG_PACK_DROP
	file_paths = list(
		'sound/items/cigs/cig_pack_drop1.ogg',
		'sound/items/cigs/cig_pack_drop2.ogg',
	)

/datum/sound_effect/cig_pack_insert
	key = SFX_CIG_PACK_INSERT
	file_paths = list(
		'sound/items/cigs/cig_pack_insert1.ogg',
		'sound/items/cigs/cig_pack_insert2.ogg',
		'sound/items/cigs/cig_pack_insert3.ogg',
		'sound/items/cigs/cig_pack_insert4.ogg',
	)

/datum/sound_effect/cig_pack_pickup
	key = SFX_CIG_PACK_PICKUP
	file_paths = list(
		'sound/items/cigs/cig_pack_pickup1.ogg',
		'sound/items/cigs/cig_pack_pickup2.ogg',
		'sound/items/cigs/cig_pack_pickup3.ogg',
	)

/datum/sound_effect/cig_pack_rustle
	key = SFX_CIG_PACK_RUSTLE
	file_paths = list(
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup1.ogg',
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup2.ogg',
		'sound/items/handling/regenerative_mesh/regen_mesh_pickup3.ogg',
	)

/datum/sound_effect/cig_pack_throw_drop
	key = SFX_CIG_PACK_THROW_DROP
	file_paths = list('sound/items/cigs/cig_pack_throw_drop1.ogg')

/datum/sound_effect/roro_warble
	key = SFX_RORO_WARBLE
	file_paths = list(
		'sound/mobs/non-humanoids/roro/roro_warble.ogg')
