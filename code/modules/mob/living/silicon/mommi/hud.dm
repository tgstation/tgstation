// Process the MoMMI's visual HuD
/datum/hud/proc/mommi_hud()
	// Typecast the mymob to a MoMMI type
	var/mob/living/silicon/robot/mommi/M=mymob
	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	// Radio
	using = new /obj/screen()	// Set using to a new object
	using.name = "radio"		// Name it
	using.dir = SOUTHWEST		// Set its direction
	using.icon = 'icons/mob/screen1_robot.dmi'	// Pick the base icon
	using.icon_state = "radio"	// Pick the icon state
	using.screen_loc = ui_movi	// Set the location
	using.layer = 20			// Set the z layer
	src.adding += using			// Place using in our adding list

	// Module select
	using = new /obj/screen()	// Set using to a new object
	using.name = INV_SLOT_TOOL
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv2
	using.layer = 20
	src.adding += using			// Place using in our adding list
	M.inv_tool = using			// Save this using as our MoMMI's inv_sight

	using = new /obj/screen()
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_inv1
	using.layer = 20
	src.adding += using
	M.inv_sight = using
	// End of module select

	// Head
	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.dir = NORTH
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	src.adding += inv_box


	// Intent
	using = new /obj/screen()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	// Cell
	mymob:cells = new /obj/screen()
	mymob:cells.icon = 'icons/mob/screen1_robot.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

	// Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

	// Installed Module
	mymob.hands = new /obj/screen()
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module

	// Module Panel
	using = new /obj/screen()
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = 19
	src.adding += using

	// Store
	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

	// Temp
	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	// Oxygen
	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	// Fire
	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	// Pulling
	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	// Blindness overlay
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	// Getting flashed overlay
	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen1_robot.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	// Zone
	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	// Reset the client's screen
	mymob.client.screen = null
	// Add everything to their screen
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

	return
