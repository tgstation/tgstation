/datum/hud/proc/robot_hud()
	adding = list()
	other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.icon = 'icons/mob/screen_cyborg.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_borg_radio
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
	using.screen_loc = ui_borg_intents
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
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen_cyborg.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = null

	mymob.client.screen += list(mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other

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