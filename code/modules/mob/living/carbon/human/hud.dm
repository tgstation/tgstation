/datum/hud/proc/human_hud(var/ui_style='icons/mob/screen1_old.dmi')

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new /obj/screen()
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	using = new /obj/screen()
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.hotkeybuttons += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "center"
	inv_box.screen_loc = ui_iclothing
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_oclothing
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.dir = WEST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.dir = EAST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	src.adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	src.adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	inv_box.layer = 19
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = 19
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.layer = 19
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.layer = 19
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.dir = 8 //The sprite at dir=8 has the background whereas the others don't.
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	inv_box.layer = 19
	src.adding += inv_box

	using = new /obj/screen()
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	src.hotkeybuttons += using

	using = new /obj/screen()
	using.name = "other"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_inventory
	using.layer = 20
	src.adding += using

	using = new /obj/screen()
	using.name = "equip"
	using.icon = ui_style
	using.icon_state = "act_equip"
	using.screen_loc = ui_equip
	using.layer = 20
	src.adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "ears"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_ears
	inv_box.slot_id = slot_ears
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	inv_box.layer = 19
	src.adding += inv_box

	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw
	src.hotkeybuttons += mymob.throw_icon

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = ui_style
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.pressure = new /obj/screen()
	mymob.pressure.icon = ui_style
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "pressure"
	mymob.pressure.screen_loc = ui_pressure

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = ui_style
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = new /obj/screen()
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = new /obj/screen()
	mymob.fire.icon = ui_style
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon = ui_style
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = new /obj/screen()
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.nutrition_icon = new /obj/screen()
	mymob.nutrition_icon.icon = ui_style
	mymob.nutrition_icon.icon_state = "nutrition0"
	mymob.nutrition_icon.name = "nutrition"
	mymob.nutrition_icon.screen_loc = ui_nutrition

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = ui_style
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.mouse_opacity = 0
	mymob.blind.layer = 0

	mymob.damageoverlay = new /obj/screen()
	mymob.damageoverlay.icon = 'icons/mob/screen1_full.dmi'
	mymob.damageoverlay.icon_state = "oxydamageoverlay0"
	mymob.damageoverlay.name = "dmg"
	mymob.damageoverlay.screen_loc = "1,1"
	mymob.damageoverlay.mouse_opacity = 0
	mymob.damageoverlay.layer = 17

	mymob.flash = new /obj/screen()
	mymob.flash.icon = ui_style
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.nutrition_icon, mymob.pullin, mymob.blind, mymob.flash, mymob.damageoverlay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	inventory_shown = 0;

	return


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += src.hud_used.hotkeybuttons
		src.hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= src.hud_used.hotkeybuttons
		src.hud_used.hotkey_ui_hidden = 1



/*

Radar-related things

*/

/mob/living/carbon/human/proc/close_radar()
	radar_open = 0
	for(var/obj/screen/x in client.screen)
		if( (x.name == "radar" && x.icon == 'icons/misc/radar.dmi') || (x in radar_blips) )
			client.screen -= x
			del(x)

	place_radar_closed()

/mob/living/carbon/human/proc/place_radar_closed()
	var/obj/screen/closedradar = new()
	closedradar.icon = 'icons/misc/radar.dmi'
	closedradar.icon_state = "radarclosed"
	closedradar.screen_loc = "WEST,NORTH-1"
	closedradar.name = "radar closed"
	client.screen += closedradar

/mob/living/carbon/human/proc/start_radar()

	for(var/obj/screen/x in client.screen)
		if(x.name == "radar closed" && x.icon == 'icons/misc/radar.dmi')
			client.screen -= x
			del(x)

	var/obj/screen/cornerA = new()
	cornerA.icon = 'icons/misc/radar.dmi'
	cornerA.icon_state = "radar(1,1)"
	cornerA.screen_loc = "WEST,NORTH-2"
	cornerA.name = "radar"

	var/obj/screen/cornerB = new()
	cornerB.icon = 'icons/misc/radar.dmi'
	cornerB.icon_state = "radar(2,1)"
	cornerB.screen_loc = "WEST+1,NORTH-2"
	cornerB.name = "radar"

	var/obj/screen/cornerC = new()
	cornerC.icon = 'icons/misc/radar.dmi'
	cornerC.icon_state = "radar(1,2)"
	cornerC.screen_loc = "WEST,NORTH-1"
	cornerC.name = "radar"

	var/obj/screen/cornerD = new()
	cornerD.icon = 'icons/misc/radar.dmi'
	cornerD.icon_state = "radar(2,2)"
	cornerD.screen_loc = "WEST+1,NORTH-1"
	cornerD.name = "radar"

	client.screen += cornerA
	client.screen += cornerB
	client.screen += cornerC
	client.screen += cornerD

	radar_open = 1

	while(radar_open && (RADAR in augmentations))
		update_radar()
		sleep(6)

/mob/living/carbon/human/proc/update_radar()

	if(!client) return
	var/list/found_targets = list()

	var/max_dist = 29 // 29 tiles is the max distance

	// If the mob is inside a turf, set the center to the object they're in
	var/atom/distance_ref = src
	if(!isturf(src.loc))
		distance_ref = loc

	// Clear the radar_blips cache
	for(var/x in radar_blips)
		client.screen -= x
		del(x)
	radar_blips = list()

	var/starting_px = 3
	var/starting_py = 3

	for(var/mob/living/M in orange(max_dist, distance_ref))
		if(M.stat == 2) continue
		found_targets.Add(M)

	for(var/obj/effect/critter/C in orange(max_dist, distance_ref))
		if(!C.alive) continue
		found_targets.Add(C)

	for(var/obj/mecha/M in orange(max_dist, distance_ref))
		if(!M.occupant) continue
		found_targets.Add(M)

	for(var/obj/structure/closet/C in orange(max_dist, distance_ref))
		for(var/mob/living/M in C.contents)
			if(M.stat == 2) continue
			found_targets.Add(M)

	// Loop through all living mobs in a range.
	for(var/atom/A in found_targets)

		var/a_x = A.x
		var/a_y = A.y

		if(!isturf(A.loc))
			a_x = A.loc.x
			a_y = A.loc.y

		var/blip_x = max_dist + (-( distance_ref.x-a_x ) ) + starting_px
		var/blip_y = max_dist + (-( distance_ref.y-a_y ) ) + starting_py
		var/obj/screen/blip = new()
		blip.icon = 'icons/misc/radar.dmi'
		blip.name = "Blip"
		blip.layer = 21
		blip.screen_loc = "WEST:[blip_x-1],NORTH-2:[blip_y-1]" // offset -1 because the center of the blip is not at the bottomleft corner (14)

		if(istype(A, /mob/living))
			var/mob/living/M = A
			if(ishuman(M))
				if(M:wear_id)
					var/job = M:wear_id:GetJobName()
					if(job == "Security Officer")
						blip.icon_state = "secblip"
						blip.name = "Security Officer"
					else if(job == "Captain" || job == "Research Director" || job == "Chief Engineer" || job == "Chief Medical Officer" || job == "Head of Security" || job == "Head of Personnel")
						blip.icon_state = "headblip"
						blip.name = "Station Head"
					else
						blip.icon_state = "civblip"
						blip.name = "Civilian"
				else
					blip.icon_state = "civblip"
					blip.name = "Civilian"

			else if(issilicon(M))
				blip.icon_state = "roboblip"
				blip.name = "Robotic Organism"

			else
				blip.icon_state = "unknownblip"
				blip.name = "Unknown Organism"

		else if(istype(A, /obj/effect/critter))
			blip.icon_state = "unknownblip"
			blip.name = "Unknown Organism"

		else if(istype(A, /obj/mecha))
			blip.icon_state = "roboblip"
			blip.name = "Robotic Organism"

		radar_blips.Add(blip)
		client.screen += blip


/mob/living/carbon/human/update_action_buttons()
	var/num = 1
	if(!src.hud_used) return
	if(!src.client) return

	if(!hud_used.hud_shown)	//Hud toggled to minimal
		return

	src.client.screen -= src.hud_used.item_action_list
	hud_used.item_action_list = list()

	for(var/obj/item/I in src)
		if(I.icon_action_button)
			var/obj/screen/item_action/A = new(src.hud_used)
			A.icon = 'icons/mob/screen1_action.dmi'
			A.icon_state = I.icon_action_button
			if(I.action_button_name)
				A.name = I.action_button_name
			else
				A.name = "Use [I.name]"
			A.owner = I
			hud_used.item_action_list += A
			switch(num)
				if(1)
					A.screen_loc = ui_action_slot1
				if(2)
					A.screen_loc = ui_action_slot2
				if(3)
					A.screen_loc = ui_action_slot3
				if(4)
					A.screen_loc = ui_action_slot4
				if(5)
					A.screen_loc = ui_action_slot5
					break //5 slots available, so no more can be added.
			num++

	src.client.screen += src.hud_used.item_action_list