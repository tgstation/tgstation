/atom/movable/screen/robot
	icon = 'icons/hud/screen_cyborg.dmi'

/atom/movable/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/atom/movable/screen/robot/Click()
	if(isobserver(usr))
		return 1

/atom/movable/screen/robot/module/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	if(R.model.type != /obj/item/robot_model)
		R.hud_used.toggle_show_robot_modules()
		return 1
	R.pick_model()

/atom/movable/screen/robot/module1
	name = "module1"
	icon_state = "inv1"

/atom/movable/screen/robot/module1/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(1)

/atom/movable/screen/robot/module2
	name = "module2"
	icon_state = "inv2"

/atom/movable/screen/robot/module2/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(2)

/atom/movable/screen/robot/module3
	name = "module3"
	icon_state = "inv3"

/atom/movable/screen/robot/module3/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(3)

/atom/movable/screen/robot/radio
	name = "radio"
	icon_state = "radio"

/atom/movable/screen/robot/radio/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.radio.interact(R)

/atom/movable/screen/robot/store
	name = "store"
	icon_state = "store"

/atom/movable/screen/robot/store/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.uneq_active()

/datum/hud/robot
	ui_style = 'icons/hud/screen_cyborg.dmi'

/datum/hud/robot/New(mob/owner)
	..()
	// i, Robit
	var/mob/living/silicon/robot/robit = mymob
	var/atom/movable/screen/using

// Language
	using = new/atom/movable/screen/language_menu(null, src)
	using.screen_loc = ui_borg_language_menu
	static_inventory += using

// Navigation
	using = new /atom/movable/screen/navigate(null, src)
	using.screen_loc = ui_borg_navigate_menu
	static_inventory += using

// Z-level floor change
	using = new /atom/movable/screen/floor_menu(null, src)
	using.screen_loc = ui_borg_floor_menu
	static_inventory += using

//Radio
	using = new /atom/movable/screen/robot/radio(null, src)
	using.screen_loc = ui_borg_radio
	static_inventory += using

//Module select
	if(!robit.inv1)
		robit.inv1 = new /atom/movable/screen/robot/module1(null, src)
	robit.inv1.screen_loc = ui_inv1
	static_inventory += robit.inv1

	if(!robit.inv2)
		robit.inv2 = new /atom/movable/screen/robot/module2(null, src)
	robit.inv2.screen_loc = ui_inv2
	static_inventory += robit.inv2

	if(!robit.inv3)
		robit.inv3 = new /atom/movable/screen/robot/module3(null, src)
	robit.inv3.screen_loc = ui_inv3
	static_inventory += robit.inv3

//End of module select
	using = new /atom/movable/screen/robot/lamp(null, src)
	using.screen_loc = ui_borg_lamp
	static_inventory += using
	robit.lampButton = using
	var/atom/movable/screen/robot/lamp/lampscreen = using
	lampscreen.robot = robit

//Photography stuff
	using = new /atom/movable/screen/ai/image_take(null, src)
	using.screen_loc = ui_borg_camera
	static_inventory += using

//Borg Integrated Tablet
	using = new /atom/movable/screen/robot/modpc(null, src)
	using.screen_loc = ui_borg_tablet
	static_inventory += using
	robit.interfaceButton = using
	if(robit.modularInterface)
		// Just trust me
		robit.modularInterface.vis_flags |= VIS_INHERIT_PLANE
		using.vis_contents += robit.modularInterface
	var/atom/movable/screen/robot/modpc/tabletbutton = using
	tabletbutton.robot = robit

//Alerts
	using = new /atom/movable/screen/robot/alerts(null, src)
	using.screen_loc = ui_borg_alerts
	static_inventory += using

	//Combat Mode
	action_intent = new /atom/movable/screen/combattoggle/robot(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

//Health
	healths = new /atom/movable/screen/healths/robot(null, src)
	infodisplay += healths

//Installed Module
	robit.hands = new /atom/movable/screen/robot/module(null, src)
	robit.hands.screen_loc = ui_borg_module
	static_inventory += robit.hands

//Store
	module_store_icon = new /atom/movable/screen/robot/store(null, src)
	module_store_icon.screen_loc = ui_borg_store

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = 'icons/hud/screen_cyborg.dmi'
	pull_icon.screen_loc = ui_borg_pull
	pull_icon.update_appearance()
	hotkeybuttons += pull_icon


	zone_select = new /atom/movable/screen/zone_sel/robot(null, src)
	zone_select.update_appearance()
	static_inventory += zone_select


/datum/hud/proc/toggle_show_robot_modules()
	if(!iscyborg(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	R.shown_robot_modules = !R.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display(mob/viewer)
	if(!iscyborg(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	var/mob/screenmob = viewer || R

	if(!R.model)
		return

	if(!R.client)
		return

	if(!R.shown_robot_modules || !screenmob.hud_used.hud_shown)
		//Modules display is hidden
		screenmob.client.screen -= module_store_icon //"store" icon

		for(var/atom/A in R.model.get_inactive_modules())
			//Module is not currently active
			screenmob.client.screen -= A
		R.shown_robot_modules = 0
		screenmob.client.screen -= R.robot_modules_background
		return

	//Modules display is shown
	screenmob.client.screen += module_store_icon //"store" icon

	if(!R.model.modules)
		to_chat(usr, span_warning("Selected model has no modules to select!"))
		return

	if(!R.robot_modules_background)
		return

	var/list/usable_modules = R.model.get_usable_modules()

	var/display_rows = max(CEILING(length(usable_modules) / 8, 1),1)
	R.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
	screenmob.client.screen += R.robot_modules_background

	for(var/i in 1 to length(usable_modules))
		var/atom/movable/A = usable_modules[i]
		if(A in R.held_items)
			//Module is currently active
			continue

		// Arrange in a grid x=-4 to 3 and y=1 to display_rows
		var/x = (i - 1) % 8 - 4
		var/y = floor((i - 1) / 8) + 1

		screenmob.client.screen += A
		if(x < 0)
			A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
		else
			A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
		SET_PLANE_IMPLICIT(A, ABOVE_HUD_PLANE)


/datum/hud/robot/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/silicon/robot/R = mymob

	var/mob/screenmob = viewer || R

	if(screenmob.hud_used)
		if(screenmob.hud_used.hud_shown)
			for(var/i in 1 to R.held_items.len)
				var/obj/item/I = R.held_items[i]
				if(I)
					switch(i)
						if(BORG_CHOOSE_MODULE_ONE)
							I.screen_loc = ui_inv1
						if(BORG_CHOOSE_MODULE_TWO)
							I.screen_loc = ui_inv2
						if(BORG_CHOOSE_MODULE_THREE)
							I.screen_loc = ui_inv3
						else
							return
					screenmob.client.screen += I
		else
			for(var/obj/item/I in R.held_items)
				screenmob.client.screen -= I

/atom/movable/screen/robot/lamp
	name = "headlamp"
	icon_state = "lamp_off"
	base_icon_state = "lamp"
	var/mob/living/silicon/robot/robot

/atom/movable/screen/robot/lamp/Click()
	. = ..()
	if(.)
		return
	robot?.toggle_headlamp()
	update_appearance()

/atom/movable/screen/robot/lamp/update_icon_state()
	icon_state = "[base_icon_state]_[robot?.lamp_enabled ? "on" : "off"]"
	return ..()

/atom/movable/screen/robot/lamp/Destroy()
	if(robot)
		robot.lampButton = null
		robot = null
	return ..()

/atom/movable/screen/robot/modpc
	name = "Modular Interface"
	icon_state = "template"
	var/mob/living/silicon/robot/robot

/atom/movable/screen/robot/modpc/Click()
	. = ..()
	if(.)
		return
	robot.modularInterface?.interact(robot)

/atom/movable/screen/robot/modpc/Destroy()
	if(robot)
		robot.interfaceButton = null
		robot = null
	return ..()

/atom/movable/screen/robot/alerts
	name = "Alert Panel"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "alerts"

/atom/movable/screen/robot/alerts/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/borgo = usr
	borgo.alert_control.ui_interact(borgo)
