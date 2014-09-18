/datum/hud/proc/robot_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using

//Module select

	using = new /obj/screen()
	using.name = "module1"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = 20
	src.adding += using
	mymob:inv1 = using

	using = new /obj/screen()
	using.name = "module2"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = 20
	src.adding += using
	mymob:inv2 = using

	using = new /obj/screen()
	using.name = "module3"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = 20
	src.adding += using
	mymob:inv3 = using

//End of module select

//Intent
	using = new /obj/screen()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

//Cell
	mymob:cells = new /obj/screen()
	mymob:cells.icon = 'icons/mob/screen1_robot.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

//Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = new /obj/screen()
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module

//Module Panel
	using = new /obj/screen()
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = 19
	src.adding += using

//Store
	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

//Temp
	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp


	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen1_robot.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)
	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.dir = 2
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = new /obj/screen/gun/item(null)
			if (mymob.client.target_can_click)
				mymob.item_use_icon.dir = 1
			src.adding += mymob.item_use_icon
			mymob.gun_move_icon = new /obj/screen/gun/move(null)
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.dir = 1
				mymob.gun_run_icon = new /obj/screen/gun/run(null)
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.dir = 1
				src.adding += mymob.gun_run_icon
			src.adding += mymob.gun_move_icon

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.blind, mymob.flash, mymob.gun_setting_icon) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

	return
