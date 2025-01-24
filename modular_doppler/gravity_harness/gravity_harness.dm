#define MODE_GRAVOFF "Off"
#define MODE_ANTIGRAVITY "Anti-Gravity Field"
#define MODE_EXTRAGRAVITY "Extra-Gravity Field"
#define GRAVITY_FIELD_COST STANDARD_CELL_CHARGE * 0.005
#define OFF_STATE "gravityharness-off"
#define ANTIGRAVITY_STATE "gravityharness-anti"
#define EXTRAGRAVITY_STATE "gravityharness-extra"

/obj/item/gravity_harness
	icon = 'modular_doppler/gravity_harness/icons/gravity_harness_backpacks.dmi'
	worn_icon = 'modular_doppler/gravity_harness/icons/gravity_harness_back.dmi'
	name = "gravity suspension harness"
	desc = "A bootleg derivative of common Skrellian construction equipment, manufactured and heavily used by Deep Spacer tribes, this harness employs suspensor tech to either nullify or magnify gravity around the wearer."
	slot_flags = ITEM_SLOT_BACK
	icon_state = "gravityharness-off"
	worn_icon_state = "gravityharness-off"
	actions_types = list(/datum/action/item_action/toggle_mode)
	w_class = WEIGHT_CLASS_HUGE
	/// The current operating mode
	var/mode = MODE_GRAVOFF
	/// The cell that the harness is currently using
	var/obj/item/stock_parts/power_store/cell/current_cell
	/// If the cell cover is open or not
	var/cell_cover_open = FALSE
	/// If it's manipulating gravity at all.
	var/gravity_on = FALSE
	/// Defines sound to be played upon mode switching
	var/modeswitch_sound = 'sound/effects/pop.ogg'
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7

/obj/item/gravity_harness/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_BACK)
	if(ispath(current_cell))
		current_cell = new current_cell(src)
		current_cell.moveToNullspace() // so it doesn't appear in storage
	create_storage(max_specific_storage = max_w_class, max_total_storage = max_combined_w_class, max_slots = max_items)

/obj/item/gravity_harness/Destroy()
	if(isatom(current_cell))
		QDEL_NULL(current_cell)

	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gravity_harness/equipped(mob/living/user, slot, current_mode)
	. = ..()
	if(slot & ITEM_SLOT_BACK)
		START_PROCESSING(SSobj, src)
		RegisterSignal(user, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

	if(!slot == ITEM_SLOT_BACK)
		mode = MODE_GRAVOFF

/// This cycles the harness's current mode to the next one, likely using the action button. Goes from Off to Anti to Extra, always.
/obj/item/gravity_harness/proc/toggle_mode(mob/user, voluntary)

	if(!istype(user) || user.incapacitated)
		return FALSE

	if(!gravity_on && (!current_cell || current_cell.charge < GRAVITY_FIELD_COST))
		if(user)
			to_chat(user, span_warning("The gravitic engine on [src] has no charge."))

		return FALSE

	switch(mode)
		if(MODE_GRAVOFF)
			change_mode(MODE_ANTIGRAVITY)

		if(MODE_ANTIGRAVITY)
			change_mode(MODE_EXTRAGRAVITY)

		if(MODE_EXTRAGRAVITY)
			change_mode(MODE_GRAVOFF)

	playsound(src, modeswitch_sound, 50, TRUE)

///Changes the mode to `target_mode`, returns `FALSE` if the mode cannot be changed
/obj/item/gravity_harness/proc/change_mode(target_mode)
	if(!target_mode)
		return FALSE

	var/mob/living/user = loc
	if(!istype(user))
		mode = MODE_GRAVOFF
		icon_state = OFF_STATE
		worn_icon_state = OFF_STATE
		gravity_on = FALSE
		update_item_action_buttons()
		update_appearance()
		return FALSE

	gravity_on = FALSE
	user.RemoveElement(/datum/element/forced_gravity, 0)
	REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, CLOTHING_TRAIT)

	var/datum/quirk/spacer_born/spacer = user.get_quirk(/datum/quirk/spacer_born)
	switch(target_mode)
		if(MODE_ANTIGRAVITY)
			mode = MODE_ANTIGRAVITY

			if(user.has_gravity())
				new /obj/effect/temp_visual/mook_dust(get_turf(src))

			user.AddElement(/datum/element/forced_gravity, 0)
			playsound(src, 'sound/effects/gravhit.ogg', 50)
			to_chat(user, span_notice("[src] releases a metallic hum, projecting a local anti-gravity field."))
			gravity_on = TRUE
			icon_state = ANTIGRAVITY_STATE
			worn_icon_state = ANTIGRAVITY_STATE

			//are we a spacer? if so, let the quirk know we're back in low gravity conditions
			if (!isnull(spacer))
				spacer.in_space(user)

		if(MODE_EXTRAGRAVITY)
			mode = MODE_EXTRAGRAVITY

			if(!user.has_gravity())
				new /obj/effect/temp_visual/mook_dust/robot(get_turf(src))

			ADD_TRAIT(user, TRAIT_NEGATES_GRAVITY, CLOTHING_TRAIT)
			playsound(src, 'modular_doppler/big_borg_lmao/sounds/robot_sit.ogg', 25)
			to_chat(user, span_notice("[src] shudders and hisses, projecting a local extra-gravity field."))
			gravity_on = TRUE
			icon_state = EXTRAGRAVITY_STATE
			worn_icon_state = EXTRAGRAVITY_STATE

			//are we a spacer? if so, let the quirk know we're in extremely uncomfortable extragrav
			if (!isnull(spacer))
				spacer.on_planet(user)

		if(MODE_GRAVOFF)
			if(!user.has_gravity() && mode != MODE_GRAVOFF)
				new /obj/effect/temp_visual/mook_dust/robot(get_turf(src))
				playsound(src, 'modular_doppler/big_borg_lmao/sounds/robot_sit.ogg', 25)
				to_chat(user, span_notice("[src] lets out a soft whine as your suspension field dissipates, gravity around you normalizing."))
				mode = MODE_GRAVOFF

			else
				if(user.has_gravity() && mode != MODE_GRAVOFF)
					new /obj/effect/temp_visual/mook_dust(get_turf(src))
					playsound(src, 'sound/effects/gravhit.ogg', 50)
					to_chat(user, span_notice("[src] lets out a soft whine as your suspension field dissipates, gravity around you normalizing."))
					mode = MODE_GRAVOFF

			icon_state = OFF_STATE
			worn_icon_state = OFF_STATE

			//are we a spacer? if so, make the quirk assert the correct condition based on where we are
			if (!isnull(spacer))
				spacer.check_z(user)

		else
			return FALSE

	update_item_action_buttons()
	update_appearance()

	return TRUE

/obj/item/gravity_harness/dropped(mob/user)
	. = ..()
	change_mode(MODE_GRAVOFF)
	user.RemoveElement(/datum/element/forced_gravity, 0)
	REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, CLOTHING_TRAIT)
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(user, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/obj/item/gravity_harness/attack_self(mob/user)
	toggle_mode(user, TRUE)

/// This outputs the harness's current mode and cell charge to your status tab, so you don't need to examine it every time.
/obj/item/gravity_harness/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Personal Gravitational Field: [mode]"
	items += "Cell Charge: [current_cell ? "[round(current_cell.percent(), 0.1)]%" : "No Cell!"]"

/obj/item/gravity_harness/process(seconds_per_tick)
	var/mob/living/carbon/human/user = loc
	if(!user || !ishuman(user) || user.back != src)
		if(mode != MODE_GRAVOFF)
			change_mode(MODE_GRAVOFF)

		return

	// Do nothing if the harness isn't emitting gravity of any kind.area
	if(!gravity_on)
		return

	// If we got here, the gravity field is on. If there's no cell, turn that shit off
	if(!current_cell)
		change_mode(MODE_GRAVOFF)
		return

	// cell.use will return FALSE if charge is lower than GRAVITY_FIELD_COST
	if(!current_cell.use(GRAVITY_FIELD_COST))
		to_chat(user, span_warning("The gravitic engine cuts off as [current_cell] runs out of charge."))
		change_mode(MODE_GRAVOFF)

/obj/item/gravity_harness/get_cell()
	if(cell_cover_open)
		return current_cell

// Show the status of the harness and cell
/obj/item/gravity_harness/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += "The gravity harness is [gravity_on ? "on" : "off"] and the field is set to [mode]"
		. += "The power meter shows [current_cell ? "<b>[round(current_cell.percent(), 0.1)]%</b> charge remaining." : "[span_warning("\"MISSING CELL\"")]"]"

		if(cell_cover_open)
			. += "The cell cover is open, exposing the battery."
			if(!current_cell)
				. += span_warning("The cell slot is empty, showing bare connectors.")
			else
				. += "\The [current_cell] is firmly in place."

	return .

/obj/item/gravity_harness/screwdriver_act(mob/living/user, obj/item/screwdriver)
	balloon_alert(user, "[cell_cover_open ? "closing" : "opening"] cover...")
	screwdriver.play_tool_sound(src, 100)

	if(!screwdriver.use_tool(src, user, 1 SECONDS))
		balloon_alert(user, "interrupted!")
		return FALSE

	screwdriver.play_tool_sound(src, 100)
	balloon_alert(user, "cover [cell_cover_open ? "closed" : "opened"]")
	cell_cover_open = !cell_cover_open
	return TRUE

/obj/item/gravity_harness/attack_hand(mob/user, list/modifiers)
	if(!cell_cover_open || loc != user)
		return ..()

	if(!current_cell)
		balloon_alert(user, "no cell!")
		return

	balloon_alert(user, "removing cell...")
	if(!do_after(user, 1.5 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return

	change_mode(MODE_GRAVOFF)
	balloon_alert(user, "cell removed")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(!user.put_in_hands(current_cell))
		current_cell.forceMove(drop_location())

	current_cell = FALSE
	return

/obj/item/gravity_harness/emp_act(severity)
	. = ..()
	if(current_cell)
		current_cell.emp_act(severity)
		change_mode(MODE_GRAVOFF)

/obj/item/gravity_harness/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stock_parts/power_store/cell))
		return ..()

	if(!cell_cover_open)
		balloon_alert(user, "open the cell cover first!")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING

	if(current_cell)
		balloon_alert(user, "cell already installed!")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING

	/// Shadow realm? I'm sending you to Lake City, FL!
	tool.moveToNullspace()
	current_cell = tool
	balloon_alert(user, "cell installed")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	return ITEM_INTERACT_SUCCESS

/obj/item/gravity_harness/with_cell
	current_cell = /obj/item/stock_parts/power_store/cell/high

#undef MODE_GRAVOFF
#undef MODE_ANTIGRAVITY
#undef MODE_EXTRAGRAVITY
#undef GRAVITY_FIELD_COST
#undef OFF_STATE
#undef ANTIGRAVITY_STATE
#undef EXTRAGRAVITY_STATE
