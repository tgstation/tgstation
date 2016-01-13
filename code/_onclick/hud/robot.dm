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
	R.radio_menu()

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


/datum/hud/proc/robot_hud()
	adding = list()
	other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen/robot/radio()
	using.screen_loc = ui_borg_radio
	adding += using

//Module select

	var/mob/living/silicon/robot/mymobR = mymob

	using = new /obj/screen/robot/module1()
	using.screen_loc = ui_inv1
	adding += using
	mymobR.inv1 = using

	using = new /obj/screen/robot/module2()
	using.screen_loc = ui_inv2
	adding += using
	mymobR.inv2 = using

	using = new /obj/screen/robot/module3()
	using.screen_loc = ui_inv3
	adding += using
	mymobR.inv3 = using

//End of module select

//Photography stuff

	using = new /obj/screen/ai/image_take()
	using.screen_loc = ui_borg_camera
	adding += using

	using = new /obj/screen/ai/image_view()
	using.screen_loc = ui_borg_album
	adding += using

//Sec/Med HUDs
	using = new /obj/screen/ai/sensors()
	using.screen_loc = ui_borg_sensor
	adding += using

//Headlamp control
	using = new /obj/screen/robot/lamp()
	using.screen_loc = ui_borg_lamp
	adding += using
	mymobR.lamp_button = using

//Intent
	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_borg_intents
	adding += using
	action_intent = using

//Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = new /obj/screen/robot/module()
	mymob.hands.screen_loc = ui_borg_module

//Store
	mymob.throw_icon = new /obj/screen/robot/store()
	mymob.throw_icon.screen_loc = ui_borg_store

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_gen.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = list()

	mymob.client.screen += list(mymob.zone_sel, mymob.hands, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other
	mymob.client.screen += mymob.client.void

	return


/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	if(r.client)
		if(r.shown_robot_modules)
			//Modules display is shown
			r.client.screen += r.throw_icon	//"store" icon

			if(!r.module)
				usr << "<span class='danger'>No module selected</span>"
				return

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
			r.client.screen -= r.throw_icon	//"store" icon

			for(var/atom/A in r.module.get_inactive_modules())
				//Module is not currently active
				r.client.screen -= A
			r.shown_robot_modules = 0
			r.client.screen -= r.robot_modules_background