/datum/hud/proc/martian_hud(var/ui_style='icons/mob/screen1_old.dmi')

	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = getFromPool(/obj/screen)
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = getFromPool(/obj/screen,src)
	using.name = "help"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = 21
	src.adding += using
	help_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = getFromPool(/obj/screen,src)
	using.name = "disarm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = 21
	src.adding += using
	disarm_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = getFromPool(/obj/screen,src)
	using.name = "grab"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = 21
	src.adding += using
	grab_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = getFromPool(/obj/screen,src)
	using.name = "harm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = 21
	src.adding += using
	hurt_intent = using

//end intent small hud objects

	using = getFromPool(/obj/screen)
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	using = getFromPool(/obj/screen)
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.adding += using

	init_hand_icons(ui_style)

	#define ui_swaphand_martian1 "CENTER-1:16,SOUTH:5"
	#define ui_swaphand_martian2 "CENTER:16,SOUTH:5"

	using = getFromPool(/obj/screen/inventory)
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand_martian1
	using.layer = 19
	src.adding += using

	using = getFromPool(/obj/screen/inventory)
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand_martian2
	using.layer = 19
	src.adding += using

	#undef ui_swaphand_martian1
	#undef ui_swaphand_martian2

	using = getFromPool(/obj/screen)
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	src.adding += using

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_monkey_hat
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	src.adding += inv_box

	mymob.throw_icon = getFromPool(/obj/screen)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.oxygen = getFromPool(/obj/screen)
	mymob.oxygen.icon = ui_style
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.pressure = getFromPool(/obj/screen)
	mymob.pressure.icon = ui_style
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "pressure"
	mymob.pressure.screen_loc = ui_pressure

	mymob.toxin = getFromPool(/obj/screen)
	mymob.toxin.icon = ui_style
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = getFromPool(/obj/screen)
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = getFromPool(/obj/screen)
	mymob.fire.icon = ui_style
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = getFromPool(/obj/screen)
	mymob.bodytemp.icon = ui_style
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = ui_style
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	//Handle the gun settings buttons
	mymob.gun_setting_icon = getFromPool(/obj/screen/gun/mode)
	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.dir = 2
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = getFromPool(/obj/screen/gun/item)
			if (mymob.client.target_can_click)
				mymob.item_use_icon.dir = 1
			src.adding += mymob.item_use_icon
			mymob.gun_move_icon = getFromPool(/obj/screen/gun/move)
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.dir = 1
				mymob.gun_run_icon = getFromPool(/obj/screen/gun/run)
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.dir = 1
				src.adding += mymob.gun_run_icon
			src.adding += mymob.gun_move_icon

	mymob.client.reset_screen()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.pullin, mymob.gun_setting_icon)
	mymob.client.screen += src.adding + src.other
