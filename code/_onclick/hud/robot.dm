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
			A.layer = 20

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