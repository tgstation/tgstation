// Process the MoMMI's visual HuD
/datum/hud/proc/mommi_hud()
	// Typecast the mymob to a MoMMI type
	var/mob/living/silicon/robot/mommi/M=mymob
	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	// Radio
	using = getFromPool(/obj/screen)	// Set using to a new object
	using.name = "radio"		// Name it
	using.dir = SOUTHWEST		// Set its direction
	using.icon = 'icons/mob/screen1_robot.dmi'	// Pick the base icon
	using.icon_state = "radio"	// Pick the icon state
	using.screen_loc = ui_movi	// Set the location
	using.layer = 20			// Set the z layer
	src.adding += using			// Place using in our adding list

	// Module select
	using = getFromPool(/obj/screen)	// Set using to a new object
	using.name = INV_SLOT_TOOL
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv2
	using.layer = 20
	src.adding += using			// Place using in our adding list
	M.inv_tool = using			// Save this using as our MoMMI's inv_sight

	using = getFromPool(/obj/screen)
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_mommi_sight
	using.layer = 20
	src.adding += using
	M.sensor = using
	// End of module select

	// Head
	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "head"
	inv_box.dir = NORTH
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_mommi_hats
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	src.adding += inv_box


	// Intent
	using = getFromPool(/obj/screen)
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	// Cell
	mymob:cells = getFromPool(/obj/screen)
	mymob:cells.icon = 'icons/mob/screen1_robot.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

	// Health
	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

	// Installed Module
	mymob.hands = getFromPool(/obj/screen)
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_mommi_module

	// Module Panel
	using = getFromPool(/obj/screen)
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = 19
	src.adding += using

	//Robot Module Hud
	using = getFromPool(/obj/screen)
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1.dmi'
	using.icon_state = "block"
	using.layer = 19
	src.adding += using
	M.robot_modules_background = using

	// Store
	mymob.throw_icon = getFromPool(/obj/screen)
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_mommi_store

	// Temp
	mymob.bodytemp = getFromPool(/obj/screen)
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	// Oxygen
	mymob.oxygen = getFromPool(/obj/screen)
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	// Fire
	mymob.fire = getFromPool(/obj/screen)
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	// Pulling
	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	// Zone
	mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	// Reset the client's screen
	mymob.client.reset_screen()
	// Add everything to their screen
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
