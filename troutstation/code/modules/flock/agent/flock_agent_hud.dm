/datum/hud/flock_agent
	ui_style = 'troutstation/icons/hud/screen_flock.dmi'

	/// Used to toggle eat mode (consuming internal storage)
	var/atom/movable/screen/eat
	/// Internal storage
	var/atom/movable/screen/inventory/flock_internal/internal
	/// Resource display
	var/atom/movable/screen/flock_resources_display/resources

/datum/hud/flock_agent/New(mob/living/owner)
	..()
	var/atom/movable/screen/inventory/inv_box
	var/atom/movable/screen/using

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_flock_pull
	static_inventory += pull_icon

	build_hand_slots()

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_swaphand_position(owner, 1)
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.icon = ui_style
	using.icon_state = "act_swap"
	using.screen_loc = ui_swaphand_position(owner, 2)
	static_inventory += using

	action_intent = new /atom/movable/screen/combattoggle/flock(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_movi
	static_inventory += action_intent

	floor_change = new /atom/movable/screen/floor_changer/vertical(null, src)
	floor_change.icon = ui_style
	floor_change.screen_loc = ui_flock_floor_changer
	static_inventory += floor_change

	throw_icon = new /atom/movable/screen/throw_catch(null, src)
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_flock_throw
	static_inventory += throw_icon

	resist_icon = new /atom/movable/screen/resist(null, src)
	resist_icon.icon = ui_style
	resist_icon.screen_loc = ui_flock_resist
	hotkeybuttons += resist_icon

	using = new /atom/movable/screen/area_creator(null, src)
	using.icon = ui_style
	using.screen_loc = ui_flock_building
	static_inventory += using

	using = new /atom/movable/screen/language_menu(null, src)
	using.icon = ui_style
	using.screen_loc = ui_flock_language
	static_inventory += using

	using = new /atom/movable/screen/navigate(null, src)
	using.icon = ui_style
	using.screen_loc = ui_flock_navigate
	static_inventory += using

	// crafting component sets up its own screen object, check flock agent mob

	zone_select = new /atom/movable/screen/zone_sel(null, src)
	zone_select.icon = ui_style
	zone_select.update_appearance()
	static_inventory += zone_select

	internal = new /atom/movable/screen/inventory/flock_internal(null, src)
	internal.name = "internal storage"
	internal.icon = ui_style
	internal.icon_state = "internal"
	internal.screen_loc = ui_flock_storage
	internal.slot_id = ITEM_SLOT_DEX_STORAGE
	static_inventory += internal

	// snowflake screen bits
	eat = new /atom/movable/screen/eat(null, src)
	static_inventory += eat

	resources = new /atom/movable/screen/flock_resources_display(null, src)
	static_inventory += resources

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "hat"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_flock_head
	inv_box.slot_id = ITEM_SLOT_HEAD
	static_inventory += inv_box

	stamina = new /atom/movable/screen/stamina(null, src)
	infodisplay += stamina

	healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += healthdoll

	mymob.canon_client?.clear_screen()

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

/datum/hud/flock_agent/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/basic/flock/agent/flockmob = mymob
	var/mob/screenmob = viewer || flockmob

	if(screenmob.hud_used && screenmob.hud_used.hud_shown)
		for(var/obj/item/item in flockmob.held_items)
			item.screen_loc = ui_hand_position(flockmob.get_held_index_of_item(item))
			screenmob.client.screen += item
		if(!isnull(flockmob.internal_storage))
			flockmob.internal_storage.screen_loc = ui_flock_storage
			screenmob.client.screen += flockmob.internal_storage
		if(!isnull(flockmob.head))
			flockmob.head.screen_loc = ui_flock_head
			screenmob.client.screen += flockmob.head
	else
		for(var/obj/item/item in flockmob.held_items)
			item.screen_loc = null
			screenmob.client.screen -= item
		if(flockmob.internal_storage)
			flockmob.internal_storage.screen_loc = null
			screenmob.client.screen -= flockmob.internal_storage
		if(flockmob.head)
			flockmob.head.screen_loc = null
			screenmob.client.screen -= flockmob.head

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
