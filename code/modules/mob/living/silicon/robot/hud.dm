/datum/hud/proc/robot_hud()
	adding = list()
	other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = 20
	adding += using

//Module select

	using = new /obj/screen()
	using.name = "module1"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = 20
	adding += using
	mymob:inv1 = using

	using = new /obj/screen()
	using.name = "module2"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = 20
	adding += using
	mymob:inv2 = using

	using = new /obj/screen()
	using.name = "module3"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = 20
	adding += using
	mymob:inv3 = using

//End of module select

//Intent
	using = new /obj/screen()
	using.name = "act_intent"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = 20
	adding += using
	action_intent = using

//Cell
	mymob:cells = new /obj/screen()
	mymob:cells.icon = 'icons/mob/screen_cyborg.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

//Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = new /obj/screen()
	mymob.hands.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module

//Module Panel
	using = new /obj/screen()
	using.name = "panel"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = 19
	adding += using

//Store
	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

//Temp
	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp


	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other

	return
