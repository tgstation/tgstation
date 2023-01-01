/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
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

/obj/structure/displaycase/handle_atom_del(atom/A)
	if(A == electronics)
		electronics = null
	if(A == showpiece)
		showpiece = null
		update_appearance()
	return ..()

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
	showpiece = null
	update_appearance()

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		dump()
		if(!disassembled)
			new /obj/item/shard(drop_location())
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
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

/obj/structure/displaycase/attackby(obj/item/tool, mob/living/user, params)
	if(tool.GetID() && !broken)
		if(allowed(user))
			to_chat(user, span_notice("You [open ? "close":"open"] [src]."))
			toggle_lock(user)
		else
			to_chat(user, span_alert("Access denied."))
	else if(tool.tool_behaviour == TOOL_WELDER && !user.combat_mode && !broken)
		if(atom_integrity < max_integrity)
			if(!tool.tool_start_check(user, amount=5))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(tool.use_tool(src, user, 40, amount=5, volume=50))
				atom_integrity = max_integrity
				update_appearance()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return
	else if(!alert && tool.tool_behaviour == TOOL_CROWBAR) //Only applies to the lab cage and player made display cases
		if(broken)
			if(showpiece)
				to_chat(user, span_warning("Remove the displayed object first!"))
			else
				to_chat(user, span_notice("You remove the destroyed case."))
				qdel(src)
		else
			to_chat(user, span_notice("You start to [open ? "close":"open"] [src]..."))
			if(tool.use_tool(src, user, 20))
				to_chat(user, span_notice("You [open ? "close":"open"] [src]."))
				toggle_lock(user)
	else if(open && !showpiece)
		insert_showpiece(tool, user)
		return TRUE //cancel the attack chain, wether we successfully placed an item or not
	else if(glass_fix && broken && istype(tool, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass_sheet = tool
		if(glass_sheet.get_amount() < 2)
			to_chat(user, span_warning("You need two glass sheets to fix the case!"))
			return
		to_chat(user, span_notice("You start fixing [src]..."))
		if(do_after(user, 20, target = src))
			glass_sheet.use(2)
			broken = FALSE
			atom_integrity = max_integrity
			update_appearance()
	else
		return ..()

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
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH) //The player can only deconstruct the wooden frame
		to_chat(user, span_notice("You start disassembling [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src), 5)
			qdel(src)

	else if(istype(I, /obj/item/electronics/airlock))
		to_chat(user, span_notice("You start installing the electronics into [src]..."))
		I.play_tool_sound(src)
		if(do_after(user, 30, target = src) && user.transferItemToLoc(I,src))
			electronics = I
			to_chat(user, span_notice("You install the airlock electronics."))

	else if(istype(I, /obj/item/stock_parts/card_reader))
		var/obj/item/stock_parts/card_reader/C = I
		to_chat(user, span_notice("You start adding [C] to [src]..."))
		if(do_after(user, 20, target = src))
			var/obj/structure/displaycase/forsale/sale = new(src.loc)
			if(electronics)
				electronics.forceMove(sale)
				sale.electronics = electronics
				if(electronics.one_access)
					sale.req_one_access = electronics.accesses
				else
					sale.req_access = electronics.accesses
			qdel(src)
			qdel(C)

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, span_warning("You need ten glass sheets to do this!"))
			return
		to_chat(user, span_notice("You start adding [G] to [src]..."))
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/noalert/display = new(src.loc)
			if(electronics)
				electronics.forceMove(display)
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.accesses
				else
					display.req_access = electronics.accesses
			qdel(src)
	else
		return ..()

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

/obj/structure/displaycase/trophy/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/key/displaycase))
		toggle_historian_mode(user)
		return
	return ..()

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
	playsound(src, 'sound/machines/twobeep.ogg', vary = 50)
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

/obj/structure/displaycase/trophy/ui_act(action, params)
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
				var/new_trophy_message = tgui_input_text(usr, "Let's make history!", "Trophy Message", trophy_message, MAX_PLAQUE_LEN)
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
	name = "display case key"
	desc = "The key to the curator's display cases."

/obj/item/showpiece_dummy
	name = "holographic replica"

/obj/item/showpiece_dummy/Initialize(mapload, path)
	. = ..()
	var/obj/item/item_path = path
	name = initial(item_path.name)
	desc = initial(item_path.desc)
	icon = initial(item_path.icon)
	icon_state = initial(item_path.icon_state)

/obj/structure/displaycase/forsale
	name = "vend-a-tray"
	icon_state = "laserbox"
	custom_glass_overlay = TRUE
	desc = "A display case with an ID-card swiper. Use your ID to purchase the contents."
	density = FALSE
	max_integrity = 100
	req_access = null
	alert = FALSE //No, we're not calling the fire department because someone stole your cookie.
	glass_fix = FALSE //Fixable with tools instead.
	pass_flags = PASSTABLE ///Can be placed and moved onto a table.
	autoexamine_while_closed = FALSE
	///The price of the item being sold. Altered by grab intent ID use.
	var/sale_price = 20
	///The Account which will receive payment for purchases. Set by the first ID to swipe the tray.
	var/datum/bank_account/payments_acc = null

/obj/structure/displaycase/forsale/update_icon_state()
	icon_state = "[initial(icon_state)][broken ? "_broken" : (open ? "_open" : (!showpiece ? "_empty" : null))]"
	return ..()

/obj/structure/displaycase/forsale/update_overlays()
	. = ..()
	if(!broken && !open)
		. += "[initial(icon_state)]_overlay"

/obj/structure/displaycase/forsale/insert_showpiece(obj/item/new_showpiece, mob/user)
	if(..())
		return TRUE
	update_static_data_for_all_viewers()

/obj/structure/displaycase/forsale/dump()
	..()
	update_static_data_for_all_viewers()

/obj/structure/displaycase/forsale/toggle_lock()
	..()
	SStgui.update_uis(src)

/obj/structure/displaycase/forsale/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vendatray", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/displaycase/forsale/ui_data(mob/user)
	var/list/data = list()
	data["owner_name"] = payments_acc ? payments_acc.account_holder : null
	data["product_name"] = showpiece ?capitalize(format_text(showpiece.name)) : null
	data["registered"] = payments_acc ? TRUE : FALSE
	data["product_cost"] = sale_price
	data["tray_open"] = open
	return data

/obj/structure/displaycase/forsale/ui_static_data(mob/user)
	var/list/data = list()
	data["product_icon"] = showpiece ? icon2base64(getFlatIcon(showpiece, no_anim=TRUE)) : null
	return data

/obj/structure/displaycase/forsale/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/obj/item/card/id/potential_acc
	if(isliving(usr))
		var/mob/living/L = usr
		potential_acc = L.get_idcard(hand_first = TRUE)
	switch(action)
		if("Buy")
			if(!showpiece)
				to_chat(usr, span_notice("There's nothing for sale."))
				return TRUE
			if(broken)
				to_chat(usr, span_notice("[src] appears to be broken."))
				return TRUE
			if(!payments_acc)
				to_chat(usr, span_notice("[src] hasn't been registered yet."))
				return TRUE
			if(!usr.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
				return TRUE
			if(!potential_acc)
				to_chat(usr, span_notice("No ID card detected."))
				return
			var/datum/bank_account/account = potential_acc.registered_account
			if(!account)
				to_chat(usr, span_notice("[potential_acc] has no account registered!"))
				return
			if(!account.has_money(sale_price))
				to_chat(usr, span_notice("You do not possess the funds to purchase this."))
				return TRUE
			else
				account.adjust_money(-sale_price, "Display Case: [capitalize(showpiece.name)]")
				if(payments_acc)
					payments_acc.adjust_money(sale_price, "Display Case: [capitalize(showpiece.name)]")
				usr.put_in_hands(showpiece)
				to_chat(usr, span_notice("You purchase [showpiece] for [sale_price] credits."))
				playsound(src, 'sound/effects/cashregister.ogg', 40, TRUE)
				flick("[initial(icon_state)]_vend", src)
				showpiece = null
				update_appearance()
				update_static_data_for_all_viewers()
				return TRUE
		if("Open")
			if(!payments_acc)
				to_chat(usr, span_notice("[src] hasn't been registered yet."))
				return TRUE
			if(!potential_acc || !potential_acc.registered_account)
				return
			if(!check_access(potential_acc))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
				return
			toggle_lock()
		if("Register")
			if(payments_acc)
				return
			if(!potential_acc || !potential_acc.registered_account)
				return
			if(!check_access(potential_acc))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
				return
			payments_acc = potential_acc.registered_account
			playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		if("Adjust")
			if(!check_access(potential_acc) || potential_acc.registered_account != payments_acc)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
				return

			var/new_price_input = tgui_input_number(usr, "Sale price for this vend-a-tray", "New Price", 10, 1000)
			if(!new_price_input || QDELETED(usr) || QDELETED(src))
				return
			if(payments_acc != potential_acc.registered_account)
				to_chat(usr, span_warning("[src] rejects your new price."))
				return
			if(!usr.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
				to_chat(usr, span_warning("You need to get closer!"))
				return
			sale_price = new_price_input
			to_chat(usr, span_notice("The cost is now set to [sale_price]."))
			SStgui.update_uis(src)
			return TRUE
	. = TRUE

/obj/structure/displaycase/forsale/attackby(obj/item/I, mob/living/user, params)
	if(isidcard(I))
		//Card Registration
		var/obj/item/card/id/potential_acc = I
		if(!potential_acc.registered_account)
			to_chat(user, span_warning("This ID card has no account registered!"))
			return
		if(payments_acc == potential_acc.registered_account)
			toggle_lock()
			return
	if(istype(I, /obj/item/modular_computer))
		return TRUE
	SStgui.update_uis(src)
	return ..()

/obj/structure/displaycase/forsale/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(atom_integrity <= (integrity_failure * max_integrity))
		to_chat(user, span_notice("You start recalibrating [src]'s hover field..."))
		if(do_after(user, 20, target = src))
			broken = FALSE
			atom_integrity = max_integrity
			update_appearance()
		return TRUE

/obj/structure/displaycase/forsale/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(open && !user.combat_mode)
		if(anchored)
			to_chat(user, span_notice("You start unsecuring [src]..."))
		else
			to_chat(user, span_notice("You start securing [src]..."))
		if(I.use_tool(src, user, 16, volume=50))
			if(QDELETED(I))
				return
			if(anchored)
				to_chat(user, span_notice("You unsecure [src]."))
			else
				to_chat(user, span_notice("You secure [src]."))
			set_anchored(!anchored)
			return TRUE
	else if(!open && !user.combat_mode)
		to_chat(user, span_notice("[src] must be open to move it."))
		return

/obj/structure/displaycase/forsale/emag_act(mob/user)
	. = ..()
	payments_acc = null
	req_access = list()
	to_chat(user, span_warning("[src]'s card reader fizzles and smokes, and the account owner is reset."))

/obj/structure/displaycase/forsale/examine(mob/user)
	. = ..()
	if(showpiece && !open)
		. += span_notice("[showpiece] is for sale for [sale_price] credits.")
	if(broken)
		. += span_notice("[src] is sparking and the hover field generator seems to be overloaded. Use a multitool to fix it.")

/obj/structure/displaycase/forsale/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = TRUE
		playsound(src, SFX_SHATTER, 70, TRUE)
		update_appearance()
		trigger_alarm() //In case it's given an alarm anyway.

/obj/structure/displaycase/forsale/kitchen
	desc = "A display case with an ID-card swiper. Use your ID to purchase the contents. Meant for the bartender and chef."
	req_one_access = list(ACCESS_KITCHEN, ACCESS_BAR)
