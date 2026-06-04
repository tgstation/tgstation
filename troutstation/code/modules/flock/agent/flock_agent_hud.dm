/datum/hud/flock_agent
	ui_style = 'troutstation/icons/hud/screen_flock.dmi'
	default_inventory_slots = /datum/inventory_slot/flock_agent
	/// Used to toggle eat mode (consuming internal storage)
	var/atom/movable/screen/eat
	/// Internal storage
	var/atom/movable/screen/inventory/flock_internal/internal

/datum/hud/flock_agent/initialize_screen_objects()
	. = ..()
	var/atom/movable/screen/using
	add_screen_object(/atom/movable/screen/drop, HUD_MOB_DROP, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 1))
	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_2, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 2))
	using.icon_state = "act_swap"

	mymob.canon_client?.clear_screen()

	build_hand_slots()

	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_flock_pull)
	add_screen_object(/atom/movable/screen/combattoggle/flock, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style, ui_movi)
	add_screen_object(/atom/movable/screen/floor_changer/vertical, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_flock_floor_changer)
	add_screen_object(/atom/movable/screen/zone_sel, HUD_MOB_ZONE_SELECTOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/resist, HUD_MOB_RESIST, HUD_GROUP_HOTKEYS, ui_style, ui_flock_resist)
	add_screen_object(/atom/movable/screen/area_creator, HUD_MOB_AREA_CREATOR, HUD_GROUP_STATIC, ui_style, ui_flock_building)
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, HUD_GROUP_STATIC, ui_style, ui_flock_language)
	add_screen_object(/atom/movable/screen/memories, HUD_MOB_MEMORIES, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, HUD_GROUP_STATIC, ui_style, ui_flock_navigate)
	add_screen_object(/atom/movable/screen/throw_catch, HUD_MOB_THROW, HUD_GROUP_HOTKEYS, ui_style, ui_flock_throw)
	add_screen_object(/atom/movable/screen/healthdoll/living, HUD_MOB_HEALTHDOLL, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/stamina, HUD_MOB_STAMINA, HUD_GROUP_STATIC)
	// crafting component sets up its own screen object, check flock agent mob

	// snowflake screen bits
	eat = add_screen_object(/atom/movable/screen/eat, HUD_FLOCK_EAT, HUD_GROUP_STATIC)
	add_screen_object(/atom/movable/screen/flock_resources_display, HUD_FLOCK_RESOURCE_COUNT, HUD_GROUP_STATIC)

/datum/hud/flock_agent/create_inventory_slots()
	. = ..()
	// hacky "find the inventory slot I care about" logic
	// the internal storage slot needs to be handled specially for appearance updates
	for(var/atom/movable/screen/inventory/inv in screen_groups[HUD_GROUP_STATIC] + screen_groups[HUD_GROUP_TOGGLEABLE_INVENTORY])
		if(inv.slot_id && inv.slot_id == ITEM_SLOT_DEX_STORAGE)
			internal = inv

/datum/inventory_slot/flock_agent
	abstract_type = /datum/inventory_slot/flock_agent

/datum/inventory_slot/flock_agent/storage
	name = "internal storage"
	icon_state = "internal"
	screen_loc = ui_flock_storage
	slot_id = ITEM_SLOT_DEX_STORAGE
	screen_type = /atom/movable/screen/inventory/flock_internal

/datum/inventory_slot/flock_agent/hat
	name = "hat"
	icon_state = "head"
	screen_loc = ui_flock_head
	slot_id = ITEM_SLOT_HEAD

/atom/movable/screen/inventory/flock_internal
	/// Mut appearance for active animation
	var/mutable_appearance/active_animation

/atom/movable/screen/inventory/flock_internal/update_overlays()
	. = ..()
	var/mob/living/basic/flock/agent/user = hud?.mymob
	if(!istype(user) || !user.client)
		return

	if(!user.eat_mode)
		return

	if(!active_animation)
		active_animation = mutable_appearance('troutstation/icons/hud/screen_flock.dmi', "internal_active")
	. += active_animation

/atom/movable/screen/combattoggle/flock
	/// Mut appearance for flashy border
	var/mutable_appearance/flashy

/atom/movable/screen/combattoggle/flock/update_overlays()
	. = ..()
	var/mob/living/user = hud?.mymob
	if(!istype(user) || !user.client)
		return

	if(!user.combat_mode)
		return

	if(!flashy)
		flashy = mutable_appearance('troutstation/icons/hud/screen_flock.dmi', "combattoggle")
	. += flashy

/atom/movable/screen/eat
	name = "absorb contents"
	icon = 'troutstation/icons/hud/screen_flock.dmi'
	icon_state = "eat"
	screen_loc = ui_flock_eat
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/eat/Click()
	if(istype(usr, /mob/living/basic/flock/agent))
		var/mob/living/basic/flock/agent/user = usr
		user.toggle_eat_mode()

#define FORMAT_FLOCK_RESOURCES_HUD_MAPTEXT(value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:-1px; left:6px'><font color='#ade4d3'>[round(value,1)]</font></div>")

/atom/movable/screen/flock_resources_display
	name = "Resource Count"
	icon = 'troutstation/icons/hud/screen_flock.dmi'
	icon_state = "resource_count"
	screen_loc = ui_flock_resource_count_right

/atom/movable/screen/flock_resources_display/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(isnull(hud_owner))
		return INITIALIZE_HINT_QDEL
	RegisterSignal(hud_owner.mymob, COMSIG_FLOCK_RESOURCES_CHANGED, PROC_REF(on_resources_update))
	var/mob/living/basic/flock/agent/agent = hud_owner.mymob
	var/shown_resources = 0
	if(agent)
		shown_resources = agent.resources
	show_resource_count(shown_resources)

/atom/movable/screen/flock_resources_display/proc/on_resources_update(mob/living/basic/flock/agent/agent, new_resource_total, added_resources)
	SIGNAL_HANDLER
	show_resource_count(new_resource_total)

// /atom/movable/screen/flock_resources_display/proc/on_item_consumed(mob/living/basic/flock/agent/consumer, obj/item/consumed, new_resource_total)
// 	SIGNAL_HANDLER
// 	show_resource_count(new_resource_total)

/atom/movable/screen/flock_resources_display/proc/show_resource_count(new_resource_total)
	maptext = FORMAT_FLOCK_RESOURCES_HUD_MAPTEXT(new_resource_total)

#undef FORMAT_FLOCK_RESOURCES_HUD_MAPTEXT
