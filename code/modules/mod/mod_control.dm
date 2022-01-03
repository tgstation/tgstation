/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/mod.dmi'
	icon_state = "standard-control"
	worn_icon = 'icons/mob/mod.dmi'

/obj/item/mod/control
	name = "MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered, back-mounted suit that protects against various environments."
	icon_state = "control"
	inhand_icon_state = "mod_control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 25, ACID = 25, WOUND = 10)
	actions_types = list(
		/datum/action/item_action/mod/deploy,
		/datum/action/item_action/mod/activate,
		/datum/action/item_action/mod/panel,
		/datum/action/item_action/mod/module,
		/datum/action/item_action/mod/deploy/ai,
		/datum/action/item_action/mod/activate/ai,
		/datum/action/item_action/mod/panel/ai,
		/datum/action/item_action/mod/module/ai,
	)
	resistance_flags = NONE
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	permeability_coefficient = 0.01
	siemens_coefficient = 0.5
	alternate_worn_layer = BODY_FRONT_LAYER
	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"
	/// Theme of the MOD TGUI
	var/ui_theme = "ntos"
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// Power usage of the MOD.
	var/cell_drain = DEFAULT_CELL_DRAIN
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD cell.
	var/obj/item/stock_parts/cell/cell
	/// MOD helmet.
	var/obj/item/clothing/head/mod/helmet
	/// MOD chestplate.
	var/obj/item/clothing/suit/mod/chestplate
	/// MOD gauntlets.
	var/obj/item/clothing/gloves/mod/gauntlets
	/// MOD boots.
	var/obj/item/clothing/shoes/mod/boots
	/// List of parts (helmet, chestplate, gauntlets, boots).
	var/list/mod_parts = list()
	/// Modules the MOD should spawn with.
	var/list/initial_modules = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// AI mob inhabiting the MOD.
	var/mob/living/silicon/ai/ai
	/// Delay between moves as AI.
	var/movedelay = 0
	/// Cooldown for AI moves.
	COOLDOWN_DECLARE(cooldown_mod_move)
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer

/obj/item/mod/control/Initialize(mapload, new_theme, new_skin)
	. = ..()
	if(new_theme)
		theme = new_theme
	theme = GLOB.mod_themes[theme]
	extended_desc = theme.extended_desc
	slowdown_inactive = theme.slowdown_inactive
	slowdown_active = theme.slowdown_active
	complexity_max = theme.complexity_max
	skin = new_skin || theme.default_skin
	ui_theme = theme.ui_theme
	cell_drain = theme.cell_drain
	initial_modules += theme.inbuilt_modules
	wires = new /datum/wires/mod(src)
	if(length(req_access))
		locked = TRUE
	if(ispath(cell))
		cell = new cell(src)
	helmet = new /obj/item/clothing/head/mod(src)
	helmet.mod = src
	mod_parts += helmet
	chestplate = new /obj/item/clothing/suit/mod(src)
	chestplate.mod = src
	chestplate.allowed = theme.allowed.Copy()
	mod_parts += chestplate
	gauntlets = new /obj/item/clothing/gloves/mod(src)
	gauntlets.mod = src
	mod_parts += gauntlets
	boots = new /obj/item/clothing/shoes/mod(src)
	boots.mod = src
	mod_parts += boots
	var/list/all_parts = mod_parts.Copy() + src
	for(var/obj/item/piece as anything in all_parts)
		piece.name = "[theme.name] [piece.name]"
		piece.desc = "[piece.desc] [theme.desc]"
		piece.armor = getArmor(arglist(theme.armor))
		piece.resistance_flags = theme.resistance_flags
		piece.heat_protection = NONE
		piece.cold_protection = NONE
		piece.max_heat_protection_temperature = theme.max_heat_protection_temperature
		piece.min_cold_protection_temperature = theme.min_cold_protection_temperature
		piece.permeability_coefficient = theme.permeability_coefficient
		piece.siemens_coefficient = theme.siemens_coefficient
		piece.icon_state = "[skin]-[initial(piece.icon_state)]"
	update_flags()
	update_speed()
	for(var/obj/item/mod/module/module as anything in initial_modules)
		module = new module(src)
		install(module)
	RegisterSignal(src, COMSIG_ATOM_EXITED, .proc/on_exit)
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, .proc/on_potion)
	movedelay = CONFIG_GET(number/movedelay/run_delay)

/obj/item/mod/control/Destroy()
	if(active)
		STOP_PROCESSING(SSobj, src)
	var/atom/deleting_atom
	if(!QDELETED(helmet))
		deleting_atom = helmet
		helmet.mod = null
		helmet = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(chestplate))
		deleting_atom = chestplate
		chestplate.mod = null
		chestplate = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(gauntlets))
		deleting_atom = gauntlets
		gauntlets.mod = null
		gauntlets = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(boots))
		deleting_atom = boots
		boots.mod = null
		boots = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	for(var/obj/item/mod/module/module as anything in modules)
		module.mod = null
		modules -= module
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	return ..()

/obj/item/mod/control/atom_destruction(damage_flag)
	for(var/obj/item/mod/module/module as anything in modules)
		for(var/obj/item/item in module)
			item.forceMove(drop_location())
	if(ai)
		ai.controlled_equipment = null
		ai.remote_control = null
		for(var/datum/action/action as anything in actions)
			if(action.owner == ai)
				action.Remove(ai)
		new /obj/item/mod/ai_minicard(drop_location(), ai)
	return ..()

/obj/item/mod/control/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("Cell power: [cell ? "[round(cell.percent(), 1)]%" : "No cell"].")
		. += span_notice("Selected module: [selected_module || "None"].")
	if(!open && !active)
		. += span_notice("You could put it on your <b>back</b> to turn it on.")
		. += span_notice("You could open the cover with a <b>screwdriver</b>.")
	else if(open)
		. += span_notice("You could close the cover with a <b>screwdriver</b>.")
		. += span_notice("You could use <b>modules</b> on it to install them.")
		. += span_notice("You could remove modules with a <b>crowbar</b>.")
		. += span_notice("You could update the access with an <b>ID</b>.")
		. += span_notice("You could access the wire panel with a <b>wire configuring tool</b>.")
		if(cell)
			. += span_notice("You could remove the cell with an <b>empty hand</b>.")
		else
			. += span_notice("You could use a <b>cell</b> on it to install one.")
		if(ai)
			. += span_notice("You could remove [ai] with an <b>intellicard</b>.")
		else
			. += span_notice("You could install an AI with an <b>intellicard</b>.")

/obj/item/mod/control/examine_more(mob/user)
	. = ..()
	. += extended_desc

/obj/item/mod/control/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if((!cell || !cell.charge) && active && !activating)
		power_off()
		return PROCESS_KILL
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1,20)
	cell.charge = max(0, cell.charge - (cell_drain + malfunctioning_charge_drain)*delta_time)
	update_cell_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && DT_PROB(5, delta_time))
			module.on_deactivation()
		module.on_process(delta_time)

/obj/item/mod/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		set_wearer(user)
	else if(wearer)
		unset_wearer()

/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(wearer)
		unset_wearer()

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	if(user != wearer)
		return ..()
	for(var/obj/item/part in mod_parts)
		if(part.loc != src)
			balloon_alert(user, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return FALSE

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(usr != wearer || !istype(over_object, /atom/movable/screen/inventory/hand))
		return ..()
	for(var/obj/item/part in mod_parts)
		if(part.loc != src)
			balloon_alert(wearer, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return
	if(!wearer.incapacitated())
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(usr)
			return ..()

/obj/item/mod/control/attack_hand(mob/user)
	if(seconds_electrified && cell?.charge)
		if(shock(user))
			return
	if(open && loc == user)
		if(!cell)
			balloon_alert(user, "no cell!")
			return
		balloon_alert(user, "removing cell...")
		if(!do_after(user, 1.5 SECONDS, target = src))
			balloon_alert(user, "interrupted!")
			return
		balloon_alert(user, "cell removed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		if(!user.put_in_hands(cell))
			cell.forceMove(drop_location())
		update_cell_alert()
		return
	return ..()

/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(..())
		return TRUE
	if(active || activating || ai_controller)
		balloon_alert(user, "deactivate suit first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	balloon_alert(user, "[open ? "closing" : "opening"] cover...")
	screwdriver.play_tool_sound(src, 100)
	if(screwdriver.use_tool(src, user, 1 SECONDS))
		if(active || activating)
			balloon_alert(user, "deactivate suit first!")
		screwdriver.play_tool_sound(src, 100)
		balloon_alert(user, "cover [open ? "closed" : "opened"]")
		open = !open
	else
		balloon_alert(user, "interrupted!")
	return TRUE

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!open)
		balloon_alert(user, "open the cover first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules += module
		var/obj/item/mod/module/module_to_remove = tgui_input_list(user, "Which module to remove?", "Module Removal", removable_modules)
		if(!module_to_remove?.mod)
			return FALSE
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		return TRUE
	balloon_alert(user, "no modules!")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/obj/item/mod/control/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			balloon_alert(user, "open the cover first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		install(attacking_item, user)
		return TRUE
	else if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(!open)
			balloon_alert(user, "open the cover first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		if(cell)
			balloon_alert(user, "cell already installed!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		attacking_item.forceMove(src)
		cell = attacking_item
		balloon_alert(user, "cell installed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		update_cell_alert()
		return TRUE
	else if(is_wire_tool(attacking_item) && open)
		wires.interact(user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/paint))
		if(active || activating)
			balloon_alert(user, "suit is active!")
		else if(paint(user, attacking_item))
			balloon_alert(user, "suit painted")
		else
			balloon_alert(user, "not painted!")
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(user, attacking_item)
		return TRUE
	return ..()

/obj/item/mod/control/get_cell()
	if(open)
		return cell

/obj/item/mod/control/GetAccess()
	if(ai_controller)
		return req_access.Copy()
	else
		return ..()

/obj/item/mod/control/emag_act(mob/user)
	locked = !locked
	balloon_alert(user, "[locked ? "locked" : "unlocked"]")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, span_notice("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!"))
	if(. & EMP_PROTECT_CONTENTS)
		return
	selected_module?.on_deactivation()
	wearer.apply_damage(10 / severity, BURN, spread_damage=TRUE)
	to_chat(wearer, span_danger("You feel [src] heat up from the EMP, burning you slightly."))
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")

/obj/item/mod/control/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	if(visuals_only)
		set_wearer(outfit_wearer) //we need to set wearer manually since it doesnt call equipped
	quick_activation()

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part in mod_parts)
		if(part.loc == src)
			continue
		conceal(null, part)
	return ..()

/obj/item/mod/control/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_icons = module.generate_worn_overlay(standing)
		if(!length(module_icons))
			continue
		. += module_icons

/obj/item/mod/control/proc/set_wearer(mob/user)
	wearer = user
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, .proc/on_exit)
	RegisterSignal(wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/on_borg_charge)
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, .proc/on_unequip)
	update_cell_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_PROCESS_BORGCHARGER_OCCUPANT))
	UnregisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP)
	wearer.clear_alert("mod_charge")
	wearer = null

/obj/item/mod/control/proc/on_unequip()
	SIGNAL_HANDLER

	for(var/obj/item/part in mod_parts)
		if(part.loc != src)
			return COMPONENT_ITEM_BLOCK_UNEQUIP

/obj/item/mod/control/proc/update_flags()
	var/list/used_skin = theme.skins[skin]
	for(var/obj/item/clothing/part as anything in mod_parts)
		var/used_category
		if(part == helmet)
			used_category = HELMET_FLAGS
			helmet.alternate_worn_layer = used_skin[HELMET_LAYER]
			helmet.alternate_layer = used_skin[HELMET_LAYER]
		if(part == chestplate)
			used_category = CHESTPLATE_FLAGS
		if(part == gauntlets)
			used_category = GAUNTLETS_FLAGS
		if(part == boots)
			used_category = BOOTS_FLAGS
		var/list/category = used_skin[used_category]
		part.clothing_flags = category[UNSEALED_CLOTHING] || NONE
		part.visor_flags = category[SEALED_CLOTHING] || NONE
		part.flags_inv = category[UNSEALED_INVISIBILITY] || NONE
		part.visor_flags_inv = category[SEALED_INVISIBILITY] || NONE
		part.flags_cover = category[UNSEALED_COVER] || NONE
		part.visor_flags_cover = category[SEALED_COVER] || NONE

/obj/item/mod/control/proc/quick_module(mob/user)
	if(!length(modules))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[module.name] = REF(module)
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locate(module_reference) in modules
	if(!istype(picked_module) || user.incapacitated())
		return
	picked_module.on_select()

/obj/item/mod/control/proc/paint(mob/user, obj/item/paint)
	if(length(theme.skins) <= 1)
		return FALSE
	var/list/skins = list()
	for(var/mod_skin in theme.skins)
		skins[mod_skin] = image(icon = icon, icon_state = "[mod_skin]-control")
	var/pick = show_radial_menu(user, src, skins, custom_check = FALSE, require_near = TRUE)
	if(!pick || !user.is_holding(paint))
		return FALSE
	skin = pick
	var/list/skin_updating = mod_parts.Copy() + src
	for(var/obj/item/piece as anything in skin_updating)
		piece.icon_state = "[skin]-[initial(piece.icon_state)]"
	update_flags()
	wearer?.regenerate_icons()
	return TRUE

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || cell?.charge < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, cell, src, 0.7, check_range)

/obj/item/mod/control/proc/install(module, mob/user)
	var/obj/item/mod/module/new_module = module
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				balloon_alert(user, "[new_module] incompatible with [old_module]!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	if(is_type_in_list(module, theme.module_blacklist))
		if(user)
			balloon_alert(user, "[src] doesn't accept [new_module]!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			balloon_alert(user, "[new_module] would make [src] too complex!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
	if(user)
		balloon_alert(user, "[new_module] added")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(module)
	var/obj/item/mod/module/old_module = module
	modules -= old_module
	complexity -= old_module.complexity
	if(active)
		old_module.on_suit_deactivation()
		if(old_module.active)
			old_module.on_deactivation()
	if(wearer)
		old_module.on_unequip()
	old_module.on_uninstall()
	old_module.mod = null

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "access updated")

/obj/item/mod/control/proc/update_cell_alert()
	if(!wearer)
		return
	if(!cell)
		wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocell)
		return
	var/remaining_cell = cell.charge/cell.maxcharge
	switch(remaining_cell)
		if(0.75 to INFINITY)
			wearer.clear_alert("mod_charge")
		if(0.5 to 0.75)
			wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 1)
		if(0.25 to 0.5)
			wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 2)
		if(0.01 to 0.25)
			wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 3)
		else
			wearer.throw_alert("mod_charge", /atom/movable/screen/alert/emptycell)

/obj/item/mod/control/proc/update_speed()
	for(var/obj/item/part as anything in mod_parts)
		part.slowdown = (active ? slowdown_active : slowdown_inactive) / length(mod_parts)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/power_off()
	balloon_alert(wearer, "no power!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == cell)
		cell = null
		update_cell_alert()
		return
	if(part.loc == wearer)
		return
	if(modules.Find(part))
		uninstall(part)
		return
	if(mod_parts.Find(part))
		conceal(wearer, part)
		if(active)
			INVOKE_ASYNC(src, .proc/toggle_activate, wearer, TRUE)
		return

/obj/item/mod/control/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	if(!cell)
		return
	cell.give(amount)
	update_cell_alert()

/obj/item/mod/control/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(slowdown_inactive <= 0)
		to_chat(user, span_warning("[src] has already been coated with red, that's as fast as it'll go!"))
		return
	if(wearer)
		to_chat(user, span_warning("It's too dangerous to smear [speed_potion] on [src] while it's on someone!"))
		return
	to_chat(user, span_notice("You slather the red gunk over [src], making it faster."))
	var/list/all_parts = mod_parts.Copy() + src
	for(var/obj/item/part as anything in all_parts)
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour("#FF0000", FIXED_COLOUR_PRIORITY)
	slowdown_inactive = 0
	slowdown_active = 0
	update_speed()
	qdel(speed_potion)
	return SPEED_POTION_SUCCESSFUL
