/obj/screen/robot/mommi
	icon = 'icons/mob/screen_cyborg.dmi'

/obj/screen/robot/mommi/module
	name = "mommi module"
	icon_state = "nomod"

/obj/screen/robot/module/Click()
	var/mob/living/silicon/robot/R = usr
	if(R.module)
		R.hud_used.toggle_show_robot_modules()
		return 1
	R.pick_module()

/obj/screen/robot/mommi/module1
	name = "module1"
	icon_state = "inv1"

/obj/screen/robot/mommi/module1/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(1)
/*
/obj/screen/robot/mommi/module2
	name = "module2"
	icon_state = "inv2"

/obj/screen/robot/mommi/module2/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(2)

/obj/screen/robot/mommi/module3
	name = "module3"
	icon_state = "inv3"

/obj/screen/robot/mommi/module3/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(3)
*/

/obj/screen/robot/mommi/radio
	name = "radio"
	icon_state = "radio"

/obj/screen/robot/mommi/radio/Click()
	var/mob/living/silicon/robot/mommi/M = usr
	M.radio_menu()

/obj/screen/robot/mommi/store
	name = "store"
	icon_state = "store"

/obj/screen/robot/mommi/store/Click()
	var/mob/living/silicon/robot/mommi/M = usr
	M.uneq_active()


/datum/hud/proc/mommi_hud()
	adding = list()
	other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen/robot/mommi/radio()
	using.screen_loc = ui_borg_radio
	adding += using

//Module select

	var/mob/living/silicon/robot/mommi/mymobR = mymob

	using = new /obj/screen/robot/module1()
	using.screen_loc = ui_inv1
	adding += using
	mymobR.inv1 = using
/*
	using = new /obj/screen/robot/module2()
	using.screen_loc = ui_inv2
	adding += using
	mymobR.inv2 = using

	using = new /obj/screen/robot/module3()
	using.screen_loc = ui_inv3
	adding += using
	mymobR.inv3 = using
*/
//End of module select

//Photography stuff
/*
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
*/

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
	mymob.hands = new /obj/screen/robot/mommi/module()
	mymob.hands.screen_loc = ui_borg_module

//Store
	mymob.throw_icon = new /obj/screen/robot/mommi/store()
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

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_gen.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = null

	mymob.client.screen += list(mymob.zone_sel, mymob.hands, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other

	return

