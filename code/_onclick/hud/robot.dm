<<<<<<< HEAD
/obj/screen/robot
	icon = 'icons/mob/screen_cyborg.dmi'

/obj/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/obj/screen/robot/module/Click()
	var/mob/living/silicon/robot/R = usr
	if(R.module)
		R.hud_used.toggle_show_robot_modules()
		return 1
	R.pick_module()

/obj/screen/robot/module1
	name = "module1"
	icon_state = "inv1"

/obj/screen/robot/module1/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(1)

/obj/screen/robot/module2
	name = "module2"
	icon_state = "inv2"

/obj/screen/robot/module2/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(2)

/obj/screen/robot/module3
	name = "module3"
	icon_state = "inv3"

/obj/screen/robot/module3/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(3)

/obj/screen/robot/radio
	name = "radio"
	icon_state = "radio"

/obj/screen/robot/radio/Click()
	var/mob/living/silicon/robot/R = usr
	R.radio.interact(R)

/obj/screen/robot/store
	name = "store"
	icon_state = "store"

/obj/screen/robot/store/Click()
	var/mob/living/silicon/robot/R = usr
	R.uneq_active()

/obj/screen/robot/lamp
	name = "headlamp"
	icon_state = "lamp0"

/obj/screen/robot/lamp/Click()
	var/mob/living/silicon/robot/R = usr
	R.control_headlamp()

/obj/screen/robot/thrusters
	name = "ion thrusters"
	icon_state = "ionpulse0"

/obj/screen/robot/thrusters/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_ionpulse()

/datum/hud/robot/New(mob/owner)
	..()
	var/mob/living/silicon/robot/mymobR = mymob
	var/obj/screen/using

//Radio
	using = new /obj/screen/robot/radio()
	using.screen_loc = ui_borg_radio
	static_inventory += using

//Module select
	using = new /obj/screen/robot/module1()
	using.screen_loc = ui_inv1
	static_inventory += using
	mymobR.inv1 = using

	using = new /obj/screen/robot/module2()
	using.screen_loc = ui_inv2
	static_inventory += using
	mymobR.inv2 = using

	using = new /obj/screen/robot/module3()
	using.screen_loc = ui_inv3
	static_inventory += using
	mymobR.inv3 = using

//End of module select

//Photography stuff
	using = new /obj/screen/ai/image_take()
	using.screen_loc = ui_borg_camera
	static_inventory += using

	using = new /obj/screen/ai/image_view()
	using.screen_loc = ui_borg_album
	static_inventory += using

//Sec/Med HUDs
	using = new /obj/screen/ai/sensors()
	using.screen_loc = ui_borg_sensor
	static_inventory += using

//Headlamp control
	using = new /obj/screen/robot/lamp()
	using.screen_loc = ui_borg_lamp
	static_inventory += using
	mymobR.lamp_button = using

//Thrusters
	using = new /obj/screen/robot/thrusters()
	using.screen_loc = ui_borg_thrusters
	static_inventory += using
	mymobR.thruster_button = using

//Intent
	using = new /obj/screen/act_intent/robot()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

//Health
	healths = new /obj/screen/healths/robot()
	infodisplay += healths

//Installed Module
	mymob.hands = new /obj/screen/robot/module()
	mymob.hands.screen_loc = ui_borg_module
	static_inventory += mymob.hands

//Store
	module_store_icon = new /obj/screen/robot/store()
	module_store_icon.screen_loc = ui_borg_store

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_cyborg.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_borg_pull
	hotkeybuttons += pull_icon


	zone_select = new /obj/screen/zone_sel/robot()
	zone_select.update_icon(mymob)
	static_inventory += zone_select


/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	if(!r.client)
		return

	if(!r.module)
		return

	if(r.shown_robot_modules && hud_shown)
		//Modules display is shown
		r.client.screen += module_store_icon	//"store" icon

		if(!r.module.modules)
			usr << "<span class='danger'>Selected module has no modules to select</span>"
			return

		if(!r.robot_modules_background)
			return

		var/display_rows = Ceiling(length(r.module.get_inactive_modules()) / 8)
		r.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/atom/movable/A in r.module.get_inactive_modules())
			//Module is not currently active
			r.client.screen += A
			if(x < 0)
				A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
			else
				A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
			A.layer = ABOVE_HUD_LAYER

			x++
			if(x == 4)
				x = -4
				y++

	else
		//Modules display is hidden
		r.client.screen -= module_store_icon	//"store" icon

		for(var/atom/A in r.module.get_inactive_modules())
			//Module is not currently active
			r.client.screen -= A
		r.shown_robot_modules = 0
		r.client.screen -= r.robot_modules_background

/mob/living/silicon/robot/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/robot(src)


/datum/hud/robot/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/silicon/robot/R = mymob
	if(hud_shown)
		if(R.module_state_1)
			R.module_state_1.screen_loc = ui_inv1
			R.client.screen += R.module_state_1
		if(R.module_state_2)
			R.module_state_2.screen_loc = ui_inv2
			R.client.screen += R.module_state_2
		if(R.module_state_3)
			R.module_state_3.screen_loc = ui_inv3
			R.client.screen += R.module_state_3
	else
		if(R.module_state_1)
			R.module_state_1.screen_loc = null
		if(R.module_state_2)
			R.module_state_2.screen_loc = null
		if(R.module_state_3)
			R.module_state_3.screen_loc = null
=======
/datum/hud/proc/robot_hud()


	src.adding = list()
	src.other = list()

	var/obj/screen/using


//Radio
	using = getFromPool(/obj/screen)
	using.name = "radio"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using

//Module select

	using = getFromPool(/obj/screen)
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_borg_sight
	using.layer = 20
	src.adding += using
	mymob:sensor = using

	using = getFromPool(/obj/screen)
	using.name = "module1"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = 20
	src.adding += using
	mymob:inv1 = using

	using = getFromPool(/obj/screen)
	using.name = "module2"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = 20
	src.adding += using
	mymob:inv2 = using

	using = getFromPool(/obj/screen)
	using.name = "module3"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = 20
	src.adding += using
	mymob:inv3 = using

	using = getFromPool(/obj/screen)
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1.dmi'
	using.icon_state = "block"
	using.layer = 19
	src.adding += using
	mymob:robot_modules_background = using

//End of module select

//Intent
	using = getFromPool(/obj/screen)
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

//Cell
	mymob:cells = getFromPool(/obj/screen)
	mymob:cells.icon = 'icons/mob/screen1_robot.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

//Health
	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = getFromPool(/obj/screen)
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module

//Module Panel
	using = getFromPool(/obj/screen)
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = 19
	src.adding += using

//Store
	mymob.throw_icon = getFromPool(/obj/screen)
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

//Temp
	mymob.bodytemp = getFromPool(/obj/screen)
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp


	mymob.oxygen = getFromPool(/obj/screen)
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.fire = getFromPool(/obj/screen)
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
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

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.gun_setting_icon) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

	return

/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob) || !mymob.client) return

	var/mob/living/silicon/robot/r = mymob

	if(r.shown_robot_modules)
		//Modules display is shown

		if(!r.module)
			to_chat(usr, "<span class='danger'>No module selected</span>")
			return

		if(!r.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select</span>")
			return

		if(!r.robot_modules_background)
			return

		var/display_rows = round((r.module.modules.len) / 8) +1 //+1 because round() returns floor of number
		r.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
				A.layer = 20
				A.plane = PLANE_HUD

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		if(r.module)
			for(var/atom/A in r.module.modules)
				if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
					//Module is not currently active
					r.client.screen -= A
			r.shown_robot_modules = 0
			r.client.screen -= r.robot_modules_background
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
