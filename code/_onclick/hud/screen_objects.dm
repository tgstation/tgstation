/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/hud/screen_gen.dmi'
	// NOTE: screen objects do NOT change their plane to match the z layer of their owner
	// You shouldn't need this, but if you ever do and it's widespread, reconsider what you're doing.
	plane = HUD_PLANE
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	appearance_flags = APPEARANCE_UI
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_CHECKS
	/// A reference to the object in the slot. Grabs or items, generally, but any datum will do.
	var/datum/weakref/master_ref = null
	/// A reference to the owner HUD, if any.
	VAR_PRIVATE/datum/hud/hud = null
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE

	/// If FALSE, this will not be cleared when calling /client/clear_screen()
	var/clear_with_screen = TRUE
	/// If TRUE, clicking the screen element will fall through and perform a default "Click" call
	/// Obviously this requires your Click override, if any, to call parent on their own.
	/// This is set to FALSE to default to dissade you from doing this.
	/// Generally we don't want default Click stuff, which results in bugs like using Telekinesis on a screen element
	/// or trying to point your gun at your screen.
	var/default_click = FALSE

/atom/movable/screen/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(isnull(hud_owner)) //some screens set their hud owners on /new, this prevents overriding them with null post atoms init
		return
	set_new_hud(hud_owner)

/atom/movable/screen/Destroy()
	master_ref = null
	hud = null
	return ..()

/atom/movable/screen/Click(location, control, params)
	if(flags_1 & INITIALIZED_1)
		SEND_SIGNAL(src, COMSIG_SCREEN_ELEMENT_CLICK, location, control, params, usr)
	if(default_click)
		return ..()

///Screen elements are always on top of the players screen and don't move so yes they are adjacent
/atom/movable/screen/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return TRUE

/atom/movable/screen/examine(mob/user)
	return list()

/atom/movable/screen/orbit()
	return

/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return

///setter used to set our new hud
/atom/movable/screen/proc/set_new_hud(datum/hud/hud_owner)
	if(hud)
		UnregisterSignal(hud, COMSIG_QDELETING)
	if(isnull(hud_owner))
		hud = null
		return
	hud = hud_owner
	RegisterSignal(hud, COMSIG_QDELETING, PROC_REF(on_hud_delete))

/// Returns the mob this is being displayed to, if any
/atom/movable/screen/proc/get_mob()
	return hud?.mymob

/atom/movable/screen/proc/on_hud_delete(datum/source)
	SIGNAL_HANDLER

	set_new_hud(hud_owner = null)

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/swap_hand
	plane = HUD_PLANE
	name = "swap hand"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated)
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/atom/movable/screen/navigate
	name = "navigate"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "navigate"
	screen_loc = ui_navigate_menu
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/navigate/Click()
	if(!isliving(usr))
		return TRUE
	var/mob/living/navigator = usr
	navigator.navigate()

/atom/movable/screen/craft
	name = "crafting menu"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/area_creator
	name = "create new area"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/area_creator/Click()
	if(usr.incapacitated || (isobserver(usr) && !isAdminGhostAI(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, span_warning("There is already a defined structure here."))
		return TRUE
	create_area(usr)

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/language_menu/Click()
	usr.get_language_holder().open_language_menu(usr)

/atom/movable/screen/inventory
	/// The identifier for the slot. It has nothing to do with ID cards.
	var/slot_id
	/// Icon when empty. For now used only by humans.
	var/icon_empty
	/// Icon when contains an item. For now used only by humans.
	var/icon_full
	/// The overlay when hovering over with an item in your hand
	var/image/object_overlay
	plane = HUD_PLANE

/atom/movable/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(INCAPACITATED_IGNORING(usr, INCAPABLE_STASIS))
		return TRUE
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id, params))
		usr.update_held_items()
	return TRUE

/atom/movable/screen/inventory/MouseEntered(location, control, params)
	. = ..()
	add_overlays()

/atom/movable/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlay)
	QDEL_NULL(object_overlay)

/atom/movable/screen/inventory/update_icon_state()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud?.mymob && slot_id && icon_full)
		icon_state = hud.mymob.get_item_by_slot(slot_id) ? icon_full : icon_empty
	return ..()

/atom/movable/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	if(!user || !slot_id)
		return

	var/obj/item/holding = user.get_active_held_item()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!holding.mob_can_equip(user, slot_id, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		item_overlay.color = COLOR_RED
	else
		item_overlay.color = "#00ff00"

	cut_overlay(object_overlay)
	object_overlay = item_overlay
	add_overlay(object_overlay)

/atom/movable/screen/inventory/hand
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/hud/screen_gen.dmi', "blocked")
	var/held_index = 0
	interaction_flags_atom = NONE //so dragging objects into hands icon don't skip adjacency & other checks

/atom/movable/screen/inventory/hand/update_overlays()
	. = ..()

	if(!handcuff_overlay)
		var/state = IS_RIGHT_INDEX(held_index) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/hud/screen_gen.dmi', state)

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				. += blocked_overlay

	if(held_index == hud.mymob.active_hand_index)
		. += IS_LEFT_INDEX(held_index) ? "lhandactive" : "rhandactive"

/atom/movable/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE
	if(world.time <= user.next_move)
		return TRUE
	if(user.incapacitated)
		return TRUE
	if (ismecha(user.loc)) // stops inventory actions in a mech
		return TRUE

	if(user.active_hand_index == held_index)
		var/obj/item/I = user.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		user.swap_hand(held_index)
	return TRUE

/atom/movable/screen/close
	name = "close"
	plane = ABOVE_HUD_PLANE
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "storage_close"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/close/Initialize(mapload, datum/hud/hud_owner, new_master)
	. = ..()
	master_ref = WEAKREF(new_master)

/atom/movable/screen/close/Click()
	var/datum/storage/storage = master_ref?.resolve()
	if(!storage)
		return
	storage.hide_contents(usr)
	return TRUE

/atom/movable/screen/drop
	name = "drop"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "act_drop"
	plane = HUD_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/atom/movable/screen/combattoggle
	name = "toggle combat mode"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "combat_off"
	screen_loc = ui_combat_toggle
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/combattoggle/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance()

/atom/movable/screen/combattoggle/Click()
	if(isliving(usr))
		var/mob/living/owner = usr
		owner.set_combat_mode(!owner.combat_mode, FALSE)
		update_appearance()

/atom/movable/screen/combattoggle/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user) || !user.client)
		return ..()
	icon_state = user.combat_mode ? "combat" : "combat_off" //Treats the combat_mode
	return ..()

//Version of the combat toggle with the flashy overlay
/atom/movable/screen/combattoggle/flashy
	///Mut appearance for flashy border
	var/mutable_appearance/flashy

/atom/movable/screen/combattoggle/flashy/update_overlays()
	. = ..()
	var/mob/living/user = hud?.mymob
	if(!istype(user) || !user.client)
		return

	if(!user.combat_mode)
		return

	if(!flashy)
		flashy = mutable_appearance('icons/hud/screen_gen.dmi', "togglefull_flash")
		flashy.color = "#C62727"
	. += flashy

/atom/movable/screen/combattoggle/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/atom/movable/screen/floor_changer
	name = "change floor"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "floor_change"
	screen_loc = ui_above_intent
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/vertical = FALSE

/atom/movable/screen/floor_changer/Click(location,control,params)
	var/list/modifiers = params2list(params)

	var/mouse_position

	if(vertical)
		mouse_position = text2num(LAZYACCESS(modifiers, ICON_Y))
	else
		mouse_position = text2num(LAZYACCESS(modifiers, ICON_X))

	if(mouse_position > 16)
		usr.up()
		return

	usr.down()
	return

/atom/movable/screen/floor_changer/vertical
	icon_state = "floor_change_v"
	vertical = TRUE

/atom/movable/screen/spacesuit
	name = "Space suit cell status"
	icon_state = "spacesuit_0"
	screen_loc = ui_spacesuit

/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "running"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/mov_intent/Click()
	toggle(usr)

/atom/movable/screen/mov_intent/update_icon_state()
	if(!hud || !hud.mymob || !isliving(hud.mymob))
		return
	var/mob/living/living_hud_owner = hud.mymob
	switch(living_hud_owner.move_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"
	return ..()

/atom/movable/screen/mov_intent/proc/toggle(mob/living/user)
	if(!istype(user))
		return
	user.toggle_move_intent()

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "pull"
	base_icon_state = "pull"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon_state()
	icon_state = "[base_icon_state][hud?.mymob?.pulling ? null : 0]"
	return ..()

/atom/movable/screen/resist
	name = "resist"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "act_resist"
	base_icon_state = "act_resist"
	plane = HUD_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/resist/Click()
	flick("[base_icon_state]_on", src)
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/rest
	name = "rest"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "act_rest"
	base_icon_state = "act_rest"
	plane = HUD_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.toggle_resting()

/atom/movable/screen/rest/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return ..()
	icon_state = "[base_icon_state][user.resting ? "_on" : null]"
	return ..()

/atom/movable/screen/sleep
	name = "sleep"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "act_sleep"
	base_icon_state = "act_sleep"
	plane = HUD_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/sleep/Click()
	if(!isliving(usr) || HAS_TRAIT(usr, TRAIT_KNOCKEDOUT))
		return
	if(usr.client?.prefs.read_preference(/datum/preference/toggle/remove_double_click))
		var/tgui_answer = tgui_alert(usr, "You sure you want to sleep for a while?", "Sleeping", list("Yes", "No"))
		if(tgui_answer == "Yes" && !HAS_TRAIT(usr, TRAIT_KNOCKEDOUT))
			var/mob/living/L = usr
			L.SetSleeping(400)
	else
		flick("[base_icon_state]_flick", src)

/atom/movable/screen/sleep/DblClick(location, control, params)
	if(!isliving(usr) || usr.client?.prefs.read_preference(/datum/preference/toggle/remove_double_click))
		return
	if(isliving(usr))
		var/mob/living/L = usr
		L.SetSleeping(400)

/atom/movable/screen/storage
	name = "storage"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "storage_cell"
	plane = HUD_PLANE

/atom/movable/screen/storage/Initialize(mapload, datum/hud/hud_owner, new_master)
	. = ..()
	master_ref = WEAKREF(new_master)

/atom/movable/screen/storage/Click(location, control, params)
	var/datum/storage/storage_master = master_ref?.resolve()
	if(!istype(storage_master))
		return FALSE

	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated)
		return TRUE
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	var/obj/item/inserted = usr.get_active_held_item()
	if(inserted)
		storage_master.attempt_insert(inserted, usr)

	return TRUE

/atom/movable/screen/storage/cell

/atom/movable/screen/storage/cell/mouse_drop_receive(atom/target, mob/living/user, params)
	var/datum/storage/storage = master_ref?.resolve()

	if (isnull(storage) || !istype(user) || storage != user.active_storage)
		return

	if (!user.can_perform_action(storage.parent, FORBID_TELEKINESIS_REACH))
		return

	if (target.loc != storage.real_location)
		return

	/// Due to items in storage ignoring transparency for click hitboxes, this only can happen if we drag onto a free cell - aka after all current contents
	storage.real_location.contents -= target
	storage.real_location.contents += target
	storage.refresh_views()

/atom/movable/screen/storage/corner
	icon_state = "storage_corner_topleft"

/atom/movable/screen/storage/corner/top_right
	icon_state = "storage_corner_topright"

/atom/movable/screen/storage/corner/bottom_left
	icon_state = "storage_corner_bottomleft"

/atom/movable/screen/storage/corner/bottom_right
	icon_state = "storage_corner_bottomright"

/atom/movable/screen/storage/rowjoin
	name = "storage"
	icon_state = "storage_rowjoin_left"
	alpha = 0

/atom/movable/screen/storage/rowjoin/right
	icon_state = "storage_rowjoin_right"

/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "act_throw"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/throw_catch/Click()
	if(isliving(usr))
		var/mob/living/user = usr
		user.toggle_throw_mode()

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/overlay_icon = 'icons/hud/screen_gen.dmi'
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/choice = get_zone_at(icon_x, icon_y)
	if (!choice)
		return 1

	return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	// Don't need to account for turf cause we're on the hud babyyy
	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/hud/screen_gen.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(17 to 22)
					return BODY_ZONE_L_LEG
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_CHEST
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_EYES
				return BODY_ZONE_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user, should_log = TRUE)
	if(user != hud?.mymob)
		return

	if(choice != hud.mymob.zone_selected)
		if(should_log)
			hud.mymob.log_manual_zone_selected_update("screen_hud", new_target = choice)
		hud.mymob.zone_selected = choice
		update_appearance()
		SEND_SIGNAL(user, COMSIG_MOB_SELECTED_ZONE_SET, choice)

	return TRUE

/atom/movable/screen/zone_sel/update_overlays()
	. = ..()
	if(!hud?.mymob)
		return
	. += mutable_appearance(overlay_icon, "[hud.mymob.zone_selected]")

/atom/movable/screen/zone_sel/alien
	icon = 'icons/hud/screen_alien.dmi'
	overlay_icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/zone_sel/robot
	icon = 'icons/hud/screen_cyborg.dmi'

/atom/movable/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/damageoverlay
	icon = 'icons/hud/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/atom/movable/screen/healths/alien
	icon = 'icons/hud/screen_alien.dmi'
	screen_loc = ui_alien_health

/atom/movable/screen/healths/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/blob/overmind
	name = "overmind health"
	icon = 'icons/hud/blob.dmi'
	icon_state = "corehealth"
	screen_loc = ui_blobbernaut_overmind_health

/atom/movable/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/hud/guardian.dmi'
	icon_state = "base"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions/backgrounds.dmi'
	icon_state = "bg_revenant"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/healthdoll/Click()
	if (iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.check_self_for_injuries()

/atom/movable/screen/healthdoll/living
	icon_state = "fullhealth0"
	screen_loc = ui_living_healthdoll
	var/filtered = FALSE //so we don't repeatedly create the mask of the mob every update

/atom/movable/screen/healthdoll/human
	/// Tracks components of our doll, each limb is a separate atom in our vis_contents
	VAR_PRIVATE/list/atom/movable/screen/limbs
	/// Lazylist, tracks all body zones that are wounded currently
	/// Used so we can sync animations should the list be updated
	VAR_PRIVATE/list/animated_zones

/atom/movable/screen/healthdoll/human/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	limbs = list()
	for(var/i in GLOB.all_body_zones)
		var/atom/movable/screen/healthdoll_limb/limb = new(src, null)
		// layer chest above other limbs, it's the center after all
		limb.layer = i == BODY_ZONE_CHEST ? layer + 0.05 : layer
		limbs[i] = limb
		// why viscontents? why not overlays? - because i want to animate filters
		vis_contents += limb
	update_appearance()

/atom/movable/screen/healthdoll/human/Destroy()
	QDEL_LIST_ASSOC_VAL(limbs)
	vis_contents.Cut()
	return ..()

/atom/movable/screen/healthdoll/human/update_icon_state()
	. = ..()
	var/mob/living/carbon/human/owner = hud?.mymob
	if(isnull(owner))
		return
	if(owner.stat == DEAD)
		for(var/limb in limbs)
			limbs[limb].icon_state = "[limb]DEAD"
		return

	var/list/current_animated = LAZYLISTDUPLICATE(animated_zones)

	for(var/obj/item/bodypart/body_part as anything in owner.bodyparts)
		var/icon_key = 0
		var/part_zone = body_part.body_zone

		var/list/overridable_key = list(icon_key)
		if(body_part.bodypart_disabled)
			icon_key = 7
		else if(owner.stat == DEAD)
			icon_key = "DEAD"
		else if(SEND_SIGNAL(body_part, COMSIG_BODYPART_UPDATING_HEALTH_HUD, owner, overridable_key) & OVERRIDE_BODYPART_HEALTH_HUD)
			icon_key = overridable_key[1] // thanks i hate it
		else if(!owner.has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy))
			var/damage = body_part.get_damage() / body_part.max_damage
			// calculate what icon state (1-5, or 0 if undamaged) to use based on damage
			icon_key = clamp(ceil(damage * 5), 0, 5)

		if(length(body_part.wounds))
			LAZYSET(animated_zones, part_zone, TRUE)
		else
			LAZYREMOVE(animated_zones, part_zone)
		limbs[part_zone].icon_state = "[part_zone][icon_key]"
	// handle leftovers
	for(var/missing_zone in owner.get_missing_limbs())
		limbs[missing_zone].icon_state = "[missing_zone]6"
		LAZYREMOVE(animated_zones, missing_zone)
	// time to re-sync animations, something changed
	if(animated_zones ~! current_animated)
		for(var/animated_zone in animated_zones)
			var/atom/wounded_zone = limbs[animated_zone]
			var/existing_filter = wounded_zone.get_filter("wound_outline")
			if(existing_filter)
				animate(existing_filter) // stop animation so we can resync
			else
				wounded_zone.add_filter("wound_outline", 1, list("type" = "outline", "color" = "#FF0033", "alpha" = 0, "size" = 1.2))
				existing_filter = wounded_zone.get_filter("wound_outline")
			animate(existing_filter, alpha = 200, time = 1.5 SECONDS, loop = -1)
			animate(alpha = 0, time = 1.5 SECONDS)
		if(LAZYLEN(current_animated)) // avoid null - list() runtimes please
			for(var/lost_zone in current_animated - animated_zones)
				limbs[lost_zone].remove_filter("wound_outline")

// Basically just holds an icon we can put a filter on
/atom/movable/screen/healthdoll_limb
	screen_loc = ui_living_healthdoll
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = ui_mood
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/splash
	icon = 'icons/blanks/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	plane = SPLASHSCREEN_PLANE
	var/client/holder

INITIALIZE_IMMEDIATE(/atom/movable/screen/splash)

/atom/movable/screen/splash/Initialize(mapload, datum/hud/hud_owner, client/C, visible, use_previous_title)
	. = ..()
	if(!istype(C))
		return

	holder = C

	if(!visible)
		alpha = 0

	if(!use_previous_title)
		if(SStitle.icon)
			icon = SStitle.icon
	else
		if(!SStitle.previous_icon)
			return INITIALIZE_HINT_QDEL
		icon = SStitle.previous_icon

	holder.screen += src

/atom/movable/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/atom/movable/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()


/atom/movable/screen/component_button
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/atom/movable/screen/parent

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/parent)
	. = ..()
	src.parent = parent

/atom/movable/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)

/atom/movable/screen/combo
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_combo
	plane = ABOVE_HUD_PLANE
	var/timerid

/atom/movable/screen/combo/proc/clear_streak()
	animate(src, alpha = 0, 2 SECONDS, SINE_EASING)
	timerid = addtimer(CALLBACK(src, PROC_REF(reset_icons)), 2 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

/atom/movable/screen/combo/proc/reset_icons()
	cut_overlays()
	icon_state = ""

/atom/movable/screen/combo/update_icon_state(streak = "", time = 2 SECONDS)
	reset_icons()
	if(timerid)
		deltimer(timerid)
	alpha = 255
	if(!streak)
		return ..()
	timerid = addtimer(CALLBACK(src, PROC_REF(clear_streak)), time, TIMER_UNIQUE | TIMER_STOPPABLE)
	icon_state = "combo"
	for(var/i = 1; i <= length(streak); ++i)
		var/intent_text = copytext(streak, i, i + 1)
		var/image/intent_icon = image(icon,src,"combo_[intent_text]")
		intent_icon.pixel_w = 16 * (i - 1) - 8 * length(streak)
		add_overlay(intent_icon)
	return ..()

/atom/movable/screen/stamina
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina

#define HUNGER_STATE_FAT 5
#define HUNGER_STATE_FULL 4
#define HUNGER_STATE_FINE 3
#define HUNGER_STATE_HUNGRY 2
#define HUNGER_STATE_VERY_HUNGRY 1
#define HUNGER_STATE_STARVING 0

/atom/movable/screen/hunger
	name = "hunger"
	icon_state = "hungerbar"
	screen_loc = ui_hunger
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// What state of hunger are we in?
	VAR_PRIVATE/state
	/// What was the last fullness we recorded?
	VAR_PRIVATE/fullness
	/// What food icon do we show by the bar
	var/food_icon = 'icons/obj/food/burgerbread.dmi'
	/// What food icon state do we show by the bar
	var/food_icon_state = "hburger"
	/// The image shown by the bar.
	VAR_PRIVATE/image/food_image
	/// The actual bar
	VAR_PRIVATE/atom/movable/screen/hunger_bar/hunger_bar

/atom/movable/screen/hunger/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/hungry = hud_owner?.mymob
	if(!istype(hungry))
		return

	if(!ishuman(hungry) || CONFIG_GET(flag/disable_human_mood))
		screen_loc = ui_mood // Slot in where mood normally is if mood is disabled

	// Burger next to the bar
	food_image = image(icon = food_icon, icon_state = food_icon_state, pixel_x = -5)
	food_image.plane = plane
	food_image.appearance_flags |= KEEP_APART // To be unaffected by filters applied to src
	food_image.add_filter("simple_outline", 2, outline_filter(1, COLOR_BLACK, OUTLINE_SHARP))
	underlays += food_image // To be below filters applied to src

	// The actual bar
	hunger_bar = new(src, null)
	vis_contents += hunger_bar

	update_hunger_bar(instant = TRUE)

/atom/movable/screen/hunger/proc/update_hunger_state()
	var/mob/living/hungry = hud?.mymob
	if(!istype(hungry))
		return

	if(HAS_TRAIT(hungry, TRAIT_NOHUNGER) || !hungry.get_organ_slot(ORGAN_SLOT_STOMACH))
		fullness = NUTRITION_LEVEL_FED
		state = HUNGER_STATE_FINE
		return
	if(HAS_TRAIT(hungry, TRAIT_FAT))
		fullness = NUTRITION_LEVEL_FAT
		state = HUNGER_STATE_FAT
		return

	if(HAS_TRAIT(hungry, TRAIT_GLUTTON))
		fullness = NUTRITION_LEVEL_VERY_HUNGRY
		state = HUNGER_STATE_HUNGRY // Can't get enough
		return

	fullness = round(hungry.get_fullness(only_consumable = TRUE), 0.05)
	switch(fullness)
		if(1 + NUTRITION_LEVEL_FULL to INFINITY)
			state = HUNGER_STATE_FULL
		if(1 + NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			state = HUNGER_STATE_FINE
		if(1 + NUTRITION_LEVEL_VERY_HUNGRY to NUTRITION_LEVEL_HUNGRY)
			state = HUNGER_STATE_FINE
		if(1 + NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_VERY_HUNGRY)
			state = HUNGER_STATE_HUNGRY
		if(0 to NUTRITION_LEVEL_STARVING)
			state = HUNGER_STATE_STARVING

/atom/movable/screen/hunger/update_appearance(updates)
	update_hunger_bar()
	return ..()

/// Updates the hunger bar's appearance.
/// If `instant` is TRUE, the bar will update immediately rather than animating.
/atom/movable/screen/hunger/proc/update_hunger_bar(instant = FALSE)
	var/old_state = state
	var/old_fullness = fullness
	update_hunger_state()
	if(old_state != state || old_fullness != fullness)
		// Fades out if we ARE "fine" AND if our stomach has no food digesting
		var/mob/living/hungry = hud?.mymob
		if(alpha == 255 && (state == HUNGER_STATE_FINE && abs(fullness - hungry.nutrition) < 1))
			if(instant)
				alpha = 0
			else
				animate(src, alpha = 0, time = 1 SECONDS)
		// Fades in if we WERE "fine" OR if our stomach has food digesting
		else if(alpha == 0 && (state != HUNGER_STATE_FINE || abs(fullness - hungry.nutrition) >= 1))
			if(instant)
				alpha = 255
			else
				animate(src, alpha = 255, time = 1 SECONDS)

	if(old_state != state)
		// Update filter around the bar
		if(state == HUNGER_STATE_STARVING)
			if(!get_filter("hunger_outline"))
				add_filter("hunger_outline", 1, list("type" = "outline", "color" = "#FF0033", "alpha" = 0, "size" = 2))
				animate(get_filter("hunger_outline"), alpha = 200, time = 1.5 SECONDS, loop = -1)
				animate(alpha = 0, time = 1.5 SECONDS)

		else if(old_state == HUNGER_STATE_STARVING)
			remove_filter("hunger_outline")

		// Update color of the food
		if((state == HUNGER_STATE_FAT) != (old_state == HUNGER_STATE_FAT))
			underlays -= food_image
			food_image.color = state == HUNGER_STATE_FAT ? COLOR_DARK : null
			underlays += food_image

	// Update hunger bar
	if(old_fullness != fullness)
		// instant if invisible OR if instant is set
		hunger_bar.update_fullness(fullness, alpha == 0 || instant)

/atom/movable/screen/hunger_bar
	icon_state = "hungerbar_bar"
	screen_loc = ui_hunger
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	/// Mask
	VAR_PRIVATE/static/icon/bar_mask
	/// Gradient used to color the bar
	VAR_PRIVATE/static/list/hunger_gradient = list(
		0.0, "#FF0000",
		0.2, "#FF8000",
		0.4, "#f0f000",
		0.6, "#00FF00",
		0.8, "#46daff",
		1.0, "#2A72AA",
		1.2, "#494949",
	)
	/// Offset of the mask
	VAR_PRIVATE/bar_offset
	/// Last "fullness" value (rounded) we used to update the bar
	VAR_PRIVATE/last_fullness_band = -1

/atom/movable/screen/hunger_bar/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/atom/movable/movable_loc = ismovable(loc) ? loc : null
	screen_loc = movable_loc?.screen_loc
	bar_mask ||= icon(icon, "hungerbar_mask")

/atom/movable/screen/hunger_bar/proc/update_fullness(new_fullness, instant)
	new_fullness = round(new_fullness / NUTRITION_LEVEL_FULL, 0.05)
	if(new_fullness == last_fullness_band)
		return
	last_fullness_band = new_fullness
	// Update color
	var/new_color = gradient(hunger_gradient, clamp(new_fullness, 0, 1.2))
	if(instant)
		color = new_color
	else
		animate(src, color = new_color, 0.5 SECONDS)
	// Update mask
	var/old_bar_offset = bar_offset
	bar_offset = clamp(-20 + (20 * new_fullness), -20, 0)
	if(old_bar_offset != bar_offset)
		if(instant || isnull(old_bar_offset))
			add_filter("hunger_bar_mask", 1, alpha_mask_filter(0, bar_offset, bar_mask))
		else
			transition_filter("hunger_bar_mask", alpha_mask_filter(0, bar_offset), 0.5 SECONDS)

#undef HUNGER_STATE_FAT
#undef HUNGER_STATE_FINE
#undef HUNGER_STATE_FULL
#undef HUNGER_STATE_HUNGRY
#undef HUNGER_STATE_STARVING
#undef HUNGER_STATE_VERY_HUNGRY

#define FORMAT_BLOOD_LEVEL_HUD_MAPTEXT(value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#FFDDDD'>[round(value,1)]</font></div>")

/**
 * Blood Level HUD
 *
 * Automatically registers to the mob's life and updates its maptext depending on the
 * mob's blood. Used for mobs that
 * 1- Should always know how much blood they have
 * 2- Have their blood level changing every life tick (which is why we don't manually call updates).
 */
/atom/movable/screen/blood_level
	name = "Blood Level"
	icon_state = "blood_display"
	screen_loc = ui_blooddisplay

/atom/movable/screen/blood_level/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(isnull(hud_owner))
		return INITIALIZE_HINT_QDEL
	RegisterSignal(hud_owner.mymob, COMSIG_LIVING_LIFE, PROC_REF(on_mob_life))

/atom/movable/screen/blood_level/proc/on_mob_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(!isliving(source))
		return
	maptext = FORMAT_BLOOD_LEVEL_HUD_MAPTEXT(source.blood_volume)

#undef FORMAT_BLOOD_LEVEL_HUD_MAPTEXT

#define FORMAT_XENOBIO_HUD_MAPTEXT(text_to_use) MAPTEXT_SPESSFONT("<span style='color: [COLOR_WHITE]; text-align: center; line-height: 1.9; '>[text_to_use]</span>")
#define POTION_DROP_SPEED 5 DECISECONDS

/// Used to show how many monkeys & slimes are in the console
/atom/movable/screen/xenobio_console
	name = "Monkey/Slime Storage"
	icon_state = "xenobio_console"
	screen_loc = ui_xenobiodisplay
	var/atom/movable/screen/xenobio_potion/potion_hud
	var/atom/movable/screen/xenobio_potion/potion_launcher

/atom/movable/screen/xenobio_console/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	potion_hud = new()
	potion_hud.layer = layer-1
	vis_contents += potion_hud
	potion_launcher = new()
	potion_launcher.layer = layer-2
	vis_contents += potion_launcher

/// Called by the console any time we update the monkeys, slimes, or max slimes
/atom/movable/screen/xenobio_console/proc/on_update_hud(slimes, monkeys, max_slimes)
	maptext = FORMAT_XENOBIO_HUD_MAPTEXT("[monkeys]\n[slimes]/[max_slimes]")
	maptext_x = 5
	maptext_y = 2

/// Called by the console any time we update the potion
/atom/movable/screen/xenobio_console/proc/update_potion(obj/item/slimepotion/slime/potion)
	if(isnull(potion))
		potion_hud.eject_pot()
		flick("xenobio_potion_launch", potion_launcher)
	else if(potion_hud.stored_potion)
		potion_hud.swap_pot(potion)
	else
		potion_hud.add_pot(potion)

/atom/movable/screen/xenobio_console/Destroy()
	vis_contents -= potion_hud
	QDEL_NULL(potion_hud)
	vis_contents -= potion_launcher
	QDEL_NULL(potion_launcher)
	return ..()

/atom/movable/screen/xenobio_potion
	name = "Monkey/Slime Storage"
	screen_loc = ui_xenobiodisplay
	/// If we have a potion stored or not
	var/stored_potion = FALSE

/// Visually ejects the current potion
/atom/movable/screen/xenobio_potion/proc/eject_pot(obj/item/slimepotion/slime/potion)
	animate(src, 2 DECISECONDS, pixel_y = 280)
	stored_potion = FALSE

/// Visually add the current potion
/atom/movable/screen/xenobio_potion/proc/add_pot(obj/item/slimepotion/slime/potion)
	stored_potion = TRUE
	icon = potion.icon
	icon_state = potion.icon_state
	pixel_y = 280
	pixel_x = -8
	add_filter("potion_outline", 1, outline_filter(1, "#eeeeee", OUTLINE_SQUARE))
	add_filter("potion_glow", 2, drop_shadow_filter(0.1, 0.1, 2, 0, "#eeeeee"))
	transform.Scale(0.8, 0.8)
	animate(src, POTION_DROP_SPEED, easing = BOUNCE_EASING, pixel_y = 19)

/// Swap out our current potion for a new one
/atom/movable/screen/xenobio_potion/proc/swap_pot(obj/item/slimepotion/slime/potion)
	addtimer(CALLBACK(src, PROC_REF(swap_pot_icon), potion), POTION_DROP_SPEED, TIMER_CLIENT_TIME)
	animate(src, POTION_DROP_SPEED, easing = BACK_EASING, pixel_x = -50)

/// Swaps the potion icon & name. Made for use w/ addtimer() so as to not disrupt the animation chain
/atom/movable/screen/xenobio_potion/proc/swap_pot_icon(obj/item/pot)
	name = pot.name
	icon_state = pot.icon_state
	animate(src, POTION_DROP_SPEED, easing = BACK_EASING, pixel_x = -8)

#undef FORMAT_XENOBIO_HUD_MAPTEXT
#undef POTION_DROP_SPEED
