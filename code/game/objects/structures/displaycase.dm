/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/structures.dmi'
	icon_state = "glassbox"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/structure_displaycase
	max_integrity = 200
	integrity_failure = 0.25
	///The showpiece item inside the case
	var/obj/item/showpiece = null
	///This allows for showpieces that can only hold items if they're the same istype as this.
	var/obj/item/showpiece_type = null
	///Is the displaycase hooked up to a burglar alarm?
	var/alert = TRUE
	///Is the displaycase open at the moment?
	var/open = FALSE
	///If we have a custom glass overlay to use.
	var/custom_glass_overlay = FALSE
	var/obj/item/electronics/airlock/electronics
	///Add type for items on display
	var/start_showpiece_type = null
	///Displaycase is fixed by glass
	var/glass_fix = TRUE
	///Represents a signel source of screaming when broken
	var/datum/alarm_handler/alarm_manager
	///Used for subtypes that have a UI in them. The examine on click while adjecent will not fire, as we already get a popup
	var/autoexamine_while_closed = TRUE

/datum/armor/structure_displaycase
	melee = 30
	bomb = 10
	fire = 70
	acid = 100

/obj/structure/displaycase/Initialize(mapload)
	. = ..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_appearance()
	alarm_manager = new(src)

/obj/structure/displaycase/vv_edit_var(vname, vval)
	. = ..()
	if(vname in list(NAMEOF(src, open), NAMEOF(src, showpiece), NAMEOF(src, custom_glass_overlay)))
		update_appearance()

/obj/structure/displaycase/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == electronics)
		electronics = null
	if(gone == showpiece)
		showpiece = null
		update_appearance()

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	QDEL_NULL(alarm_manager)
	return ..()

/obj/structure/displaycase/examine(mob/user)
	. = ..()
	if(alert)
		. += span_notice("Hooked up with an anti-theft system.")
	if(showpiece)
		. += span_notice("There's \a [showpiece] inside.")

///Removes the showpiece from the displaycase
/obj/structure/displaycase/proc/dump()
	if(QDELETED(showpiece))
		return
	showpiece.forceMove(drop_location())

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/displaycase/atom_deconstruct(disassembled = TRUE)
	dump()
	if(!disassembled)
		new /obj/item/shard(drop_location())
		trigger_alarm()

/obj/structure/displaycase/atom_break(damage_flag)
	. = ..()
	if(!broken)
		set_density(FALSE)
		broken = TRUE
		new /obj/item/shard(drop_location())
		playsound(src, SFX_SHATTER, 70, TRUE)
		update_appearance()
		trigger_alarm()

///Anti-theft alarm triggered when broken.
/obj/structure/displaycase/proc/trigger_alarm()
	if(!alert)
		return
	var/area/alarmed = get_area(src)
	alarmed.burglaralert(src)

	alarm_manager.send_alarm(ALARM_BURGLAR)
	addtimer(CALLBACK(alarm_manager, TYPE_PROC_REF(/datum/alarm_handler, clear_alarm), ALARM_BURGLAR), 1 MINUTES)

	playsound(src, 'sound/effects/alert.ogg', 50, TRUE)

/obj/structure/displaycase/update_overlays()
	. = ..()
	if(showpiece)
		var/mutable_appearance/showpiece_overlay = mutable_appearance(showpiece.icon, showpiece.icon_state)
		showpiece_overlay.copy_overlays(showpiece)
		showpiece_overlay.transform *= 0.6
		. += showpiece_overlay
	if(custom_glass_overlay)
		return
	if(broken)
		. += "[initial(icon_state)]_broken"
		return
	if(!open)
		. += "[initial(icon_state)]_closed"
		return

/obj/structure/displaycase/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.GetID() && !broken)
		if(!allowed(user))
			to_chat(user, span_alert("Access denied."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You [open ? "close":"open"] [src]."))
		toggle_lock(user)
		return ITEM_INTERACT_SUCCESS


	if(open && !showpiece)
		insert_showpiece(tool, user)
		return ITEM_INTERACT_SUCCESS //cancel the attack chain, whether we successfully placed an item or not

	if(glass_fix && broken && istype(tool, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass_sheet = tool
		if(glass_sheet.get_amount() < 2)
			to_chat(user, span_warning("You need two glass sheets to fix the case!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You start fixing [src]..."))
		if(!do_after(user, 2 SECONDS, target = src))
			return ITEM_INTERACT_BLOCKING

		glass_sheet.use(2)
		broken = FALSE
		atom_integrity = max_integrity
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/structure/displaycase/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode || broken)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=1))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(!tool.use_tool(src, user, 40, volume=50))
		return ITEM_INTERACT_BLOCKING

	atom_integrity = max_integrity
	update_appearance()
	to_chat(user, span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/displaycase/crowbar_act(mob/living/user, obj/item/tool)
	if(alert) //Only applies to the lab cage and player made display cases
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(broken)
		if(showpiece)
			to_chat(user, span_warning("Remove the displayed object first!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You remove the destroyed case."))
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	to_chat(user, span_notice("You start to [open ? "close":"open"] [src]..."))
	if(!tool.use_tool(src, user, 20))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You [open ? "close":"open"] [src]."))
	toggle_lock(user)
	return ITEM_INTERACT_SUCCESS


///Handles placing an item into the display case. Returns TRUE if the item failed to be placed inside the container, useful for descendants
/obj/structure/displaycase/proc/insert_showpiece(obj/item/new_showpiece, mob/user)
	if(showpiece_type && !istype(new_showpiece, showpiece_type))
		to_chat(user, span_notice("This doesn't belong in this kind of display."))
		return TRUE
	if(user.transferItemToLoc(new_showpiece, src))
		showpiece = new_showpiece
		to_chat(user, span_notice("You put [new_showpiece] on display."))
		update_appearance()

///Opens and closes the display case
/obj/structure/displaycase/proc/toggle_lock(mob/user)
	playsound(src, 'sound/machines/click.ogg', 20, TRUE)
	open = !open
	update_appearance()

/obj/structure/displaycase/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/displaycase/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (broken || open))
		to_chat(user, span_notice("You deactivate the hover field built into the case."))
		log_combat(user, src, "deactivates the hover field of")
		dump()
		add_fingerprint(user)
		return
	else
		//prevents remote "kicks" with TK
		if (!Adjacent(user))
			return
		if (!user.combat_mode)
			if(!open && !autoexamine_while_closed)
				return
			if(!user.is_blind())
				user.examinate(src)
			return
		user.visible_message(span_danger("[user] kicks the display case."), null, null, COMBAT_MESSAGE_RANGE)
		log_combat(user, src, "kicks")
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

/obj/structure/displaycase_chassis
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/structures.dmi'
	icon_state = "glassbox_chassis"
	resistance_flags = FLAMMABLE
	anchored = TRUE
	density = FALSE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 5)
	///The airlock electronics inserted into the chassis, to be moved to the finished product.
	var/obj/item/electronics/airlock/electronics

/obj/structure/displaycase_chassis/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/displaycase_chassis/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return .

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/electronics/airlock) && !electronics)
		context[SCREENTIP_CONTEXT_LMB] = "Add electronics"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stock_parts/card_reader))
		context[SCREENTIP_CONTEXT_LMB] = "Construct Vend-A-Tray"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stack/sheet/glass))
		context[SCREENTIP_CONTEXT_LMB] = "Finalize display case"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/displaycase_chassis/examine(mob/user)
	. = ..()
	if(!electronics)
		. += span_notice("You can attach [EXAMINE_HINT("airlock electronics")] to give it access restrictions.")
	. += span_notice("[src] can be finalized using [EXAMINE_HINT("10 glass sheets")], or turned into a Vend-A-Tray using a [EXAMINE_HINT("card reader")].")

/obj/structure/displaycase_chassis/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "disassembling...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 3 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
		if(electronics)
			electronics.forceMove(drop_location())
			electronics = null
		qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/displaycase_chassis/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/electronics/airlock))
		balloon_alert(user, "installing electronics...")
		if(!do_after(user, 3 SECONDS, target = src) || !user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING

		electronics = tool
		balloon_alert(user, "electronics installed")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass_sheets = tool
		if(glass_sheets.get_amount() < 10)
			balloon_alert(user, "need 10 sheets!")
			return ITEM_INTERACT_BLOCKING

		balloon_alert(user, "adding glass...")
		if(!do_after(user, 2 SECONDS, target = src))
			return ITEM_INTERACT_BLOCKING

		glass_sheets.use(10)
		make_final_result(display_type = /obj/structure/displaycase/noalert)
		return ITEM_INTERACT_SUCCESS

	return NONE

///Makes the final result of the chassis, then deletes itself.
/obj/structure/displaycase_chassis/proc/make_final_result(obj/structure/displaycase/display_type)
	var/obj/structure/displaycase/display = new display_type(loc)
	if(electronics)
		electronics.forceMove(display)
		display.electronics = electronics
		if(electronics.one_access)
			display.req_one_access = electronics.accesses
		else
			display.req_access = electronics.accesses
	qdel(src)

//The lab cage and captain's display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CENT_SPECOPS) //this was intentional, presumably to make it slightly harder for caps to grab their gun roundstart

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)

/obj/structure/displaycase/noalert
	alert = FALSE

/obj/structure/displaycase/trophy
	name = "trophy display case"
	desc = "Store your trophies of accomplishment in here, and they will stay forever."
	integrity_failure = 0
	req_access = list(ACCESS_LIBRARY)
	autoexamine_while_closed = FALSE
	///the key of the player who placed the item in the case
	var/placer_key = ""
	///is the trophy a hologram, not a real item placed by a player?
	var/holographic_showpiece = FALSE
	///are we about to edit
	var/historian_mode = FALSE
	///the trophy message
	var/trophy_message = ""

/obj/structure/displaycase/trophy/Initialize(mapload)
	. = ..()
	GLOB.trophy_cases += src

/obj/structure/displaycase/trophy/Destroy()
	GLOB.trophy_cases -= src
	return ..()

///Creates a showpiece dummy to display, using persistent data
/obj/structure/displaycase/trophy/proc/set_up_trophy(datum/trophy_data/chosen_trophy)
	showpiece = new /obj/item/showpiece_dummy(src, text2path(chosen_trophy.path))
	trophy_message = trim(chosen_trophy.message, MAX_PLAQUE_LEN)
	if(trophy_message == "")
		trophy_message = trim(showpiece.desc, MAX_PLAQUE_LEN)
	placer_key = trim(chosen_trophy.placer_key)
	holographic_showpiece = TRUE
	update_appearance()

/obj/structure/displaycase/trophy/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/key/displaycase))
		return ..()
	toggle_historian_mode(user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/displaycase/trophy/dump()
	if (showpiece)
		if(holographic_showpiece)
			visible_message(span_danger("[showpiece] fizzles and vanishes!"))
			do_sparks(number = 1, cardinal_only = FALSE, source = src)
			QDEL_NULL(showpiece)
			holographic_showpiece = FALSE
		else
			..()
		placer_key = ""
		trophy_message = null

/obj/structure/displaycase/trophy/insert_showpiece(obj/item/new_showpiece, mob/user)
	if(..())
		return TRUE
	if(showpiece == new_showpiece)
		placer_key = user.ckey

///Toggles the mode that shows the historian panel on the UI, enabling saving the looks and the trophy message of the current trophy
/obj/structure/displaycase/trophy/proc/toggle_historian_mode(mob/user)
	historian_mode = !historian_mode
	balloon_alert(user, "[historian_mode ? "enabled" : "disabled"] historian mode.")
	playsound(src, 'sound/machines/beep/twobeep.ogg', 10, vary = 50)
	SStgui.update_uis(src)

/obj/structure/displaycase/trophy/toggle_lock(mob/user)
	..()
	SStgui.close_uis(src)

/obj/structure/displaycase/trophy/ui_data(mob/user)
	var/list/data = list()
	data["historian_mode"] = historian_mode
	data["holographic_showpiece"] = holographic_showpiece
	data["max_length"] = MAX_PLAQUE_LEN
	data["has_showpiece"] = showpiece ? TRUE : FALSE
	if(showpiece)
		data["showpiece_name"] = capitalize(format_text(showpiece.name))
		data["showpiece_description"] = trophy_message ? format_text(trophy_message) : null
	return data

/obj/structure/displaycase/trophy/ui_static_data(mob/user)
	var/list/data = list()
	if(showpiece)
		data["showpiece_icon"] = icon2base64(getFlatIcon(showpiece, no_anim=TRUE))
	return data

/obj/structure/displaycase/trophy/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("insert_key")
			if(historian_mode)
				return
			var/obj/item/key/displaycase/trophy_key = usr.get_active_held_item()
			if(istype(trophy_key))
				toggle_historian_mode(usr)
				return TRUE
			return
		if("change_message")
			if(showpiece && !holographic_showpiece)
				var/new_trophy_message = tgui_input_text(usr, "Let's make history!", "Trophy Message", trophy_message, max_length = MAX_PLAQUE_LEN)
				if(!new_trophy_message)
					return
				trophy_message = new_trophy_message
				return TRUE
		if("lock")
			if(!historian_mode)
				return
			toggle_historian_mode(usr)
			return TRUE

/obj/structure/displaycase/trophy/ui_interact(mob/user, datum/tgui/ui)
	if(open)
		return
	if(isliving(usr))
		var/mob/living/living_usr = usr
		if(living_usr.combat_mode)
			return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Trophycase", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/key/displaycase
	name = "curator key"
	desc = "The key to the curator's display cases and arcade cabinets."

/obj/item/showpiece_dummy
	name = "holographic replica"

/obj/item/showpiece_dummy/Initialize(mapload, path)
	. = ..()
	var/obj/item/item_path = path
	name = initial(item_path.name)
	desc = initial(item_path.desc)
	icon = initial(item_path.icon)
	icon_state = initial(item_path.icon_state)
