/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'

/obj/item/mod/control
	name = "MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	icon_state = "standard-control"
	inhand_icon_state = "mod_control"
	base_icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	interaction_flags_mouse_drop = NEED_HANDS
	strip_delay = 10 SECONDS
	armor_type = /datum/armor/none
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
	siemens_coefficient = 0.5
	alternate_worn_layer = HANDS_LAYER+0.1 //we want it to go above generally everything, but not hands
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
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
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when all of its pieces are deployed.
	var/slowdown_deployed = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD core.
	var/obj/item/mod/core/core
	/// List of MODsuit part datums.
	var/list/mod_parts = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// AI or pAI mob inhabiting the MOD.
	var/mob/living/silicon/ai_assistant
	/// The MODlink datum, letting us call people from the suit.
	var/datum/mod_link/mod_link
	/// The starting MODlink frequency, overridden on subtypes that want it to be something.
	var/starting_frequency = null
	/// Delay between moves as AI.
	var/static/movedelay = 0
	/// Cooldown for AI moves.
	COOLDOWN_DECLARE(cooldown_mod_move)
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	if(!movedelay)
		movedelay = CONFIG_GET(number/movedelay/run_delay)
	if(new_theme)
		theme = new_theme
	theme = GLOB.mod_themes[theme]
	theme.set_up_parts(src, new_skin)
	for(var/obj/item/part as anything in get_parts())
		RegisterSignal(part, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_part_destruction))
	set_wires(new /datum/wires/mod(src))
	if(length(req_access))
		locked = TRUE
	new_core?.install(src)
	update_speed()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_potion))
	for(var/obj/item/mod/module/module as anything in theme.inbuilt_modules)
		module = new module(src)
		install(module)
	START_PROCESSING(SSobj, src)

/obj/item/mod/control/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	if(core)
		QDEL_NULL(core)
	QDEL_NULL(mod_link)
	for(var/part_key in mod_parts)
		var/datum/mod_part/part_datum = mod_parts[part_key]
		mod_parts -= part_key
		qdel(part_datum)
	return ..()

/obj/item/mod/control/atom_destruction(damage_flag)
	var/atom/visible_atom = wearer || src
	if(wearer)
		clean_up()
	visible_atom.visible_message(span_bolddanger("[src] fall[p_s()] apart, completely destroyed!"), vision_distance = COMBAT_MESSAGE_RANGE)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	if(ai_assistant)
		if(ispAI(ai_assistant))
			INVOKE_ASYNC(src, PROC_REF(remove_pai), /* user = */ null, /* forced = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after
		else
			for(var/datum/action/action as anything in actions)
				if(action.owner == ai_assistant)
					action.Remove(ai_assistant)
			new /obj/item/mod/ai_minicard(drop_location(), ai_assistant)
	return ..()

/obj/item/mod/control/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("Charge: [core ? "[get_charge_percent()]%" : "No core"].")
		. += span_notice("Selected module: [selected_module || "None"].")
	if(!open && !active)
		if(!wearer)
			. += span_notice("You could equip it to turn it on.")
		. += span_notice("You could open the cover with a <b>screwdriver</b>.")
	else if(open)
		. += span_notice("You could close the cover with a <b>screwdriver</b>.")
		. += span_notice("You could use <b>modules</b> on it to install them.")
		. += span_notice("You could remove modules with a <b>crowbar</b>.")
		. += span_notice("You could update the access lock with an <b>ID</b>.")
		. += span_notice("You could access the wire panel with a <b>wire tool</b>.")
		if(core)
			. += span_notice("You could remove [core] with a <b>wrench</b>.")
		else
			. += span_notice("You could use a <b>MOD core</b> on it to install one.")
		if(isnull(ai_assistant))
			. += span_notice("You could install an AI or pAI using their <b>storage card</b>.")
		else if(isAI(ai_assistant))
			. += span_notice("You could remove [ai_assistant] with an <b>intellicard</b>.")
	. += span_notice("You could copy/set link frequency with a <b>multitool</b>.")
	. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/mod/control/examine_more(mob/user)
	. = ..()
	. += "<i>[extended_desc]</i>"

/obj/item/mod/control/process(seconds_per_tick)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(mod_link.link_call)
		subtract_charge(0.25 * DEFAULT_CHARGE_DRAIN * seconds_per_tick)
	if(!active)
		return
	if(!get_charge() && active && !activating)
		power_off()
		return
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(0.2 * DEFAULT_CHARGE_DRAIN, 4 * DEFAULT_CHARGE_DRAIN) // About triple power usage on average.
	subtract_charge((charge_drain + malfunctioning_charge_drain) * seconds_per_tick)
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && SPT_PROB(5, seconds_per_tick))
			module.deactivate(display_message = TRUE)
		module.on_process(seconds_per_tick)

/obj/item/mod/control/visual_equipped(mob/user, slot, initial = FALSE) //needs to be visual because we wanna show it in select equipment
	if(slot & slot_flags)
		set_wearer(user)
	else if(wearer)
		unset_wearer()

/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(!wearer)
		return
	clean_up()

// Grant pinned actions to pin owners, gives AI pinned actions to the AI and not the wearer
/obj/item/mod/control/grant_action_to_bearer(datum/action/action)
	if (!istype(action, /datum/action/item_action/mod/pinnable))
		return ..()
	var/datum/action/item_action/mod/pinnable/pinned = action
	give_item_action(action, pinned.pinner, slot_flags)

/obj/item/mod/control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	if(user != wearer)
		return ..()
	if(active)
		balloon_alert(wearer, "unit active!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc != src)
			balloon_alert(user, "parts extended!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return FALSE

/obj/item/mod/control/mouse_drop_dragged(atom/over_object, mob/user)
	if(user != wearer || !istype(over_object, /atom/movable/screen/inventory/hand))
		return
	if(active)
		balloon_alert(wearer, "unit active!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc != src)
			balloon_alert(wearer, "parts extended!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return
	if(!wearer.incapacitated)
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(user)

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(seconds_electrified && get_charge() && shock(user))
		return ITEM_INTERACT_BLOCKING
	if(open)
		if(!core)
			balloon_alert(user, "no core!")
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "removing core...")
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			balloon_alert(user, "interrupted!")
			return ITEM_INTERACT_BLOCKING
		wrench.play_tool_sound(src, 100)
		balloon_alert(user, "core removed")
		core.forceMove(drop_location())
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(active || activating || ai_controller)
		balloon_alert(user, "unit active!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "[open ? "closing" : "opening"] cover...")
	screwdriver.play_tool_sound(src, 100)
	if(screwdriver.use_tool(src, user, 1 SECONDS))
		if(active || activating)
			balloon_alert(user, "unit active!")
			return ITEM_INTERACT_SUCCESS
		screwdriver.play_tool_sound(src, 100)
		balloon_alert(user, "cover [open ? "closed" : "opened"]")
		open = !open
	else
		balloon_alert(user, "interrupted!")
	return ITEM_INTERACT_SUCCESS

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	if(!open)
		balloon_alert(user, "cover closed!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules += module
		var/obj/item/mod/module/module_to_remove = tgui_input_list(user, "Which module to remove?", "Module Removal", removable_modules)
		if(!module_to_remove?.mod)
			return ITEM_INTERACT_BLOCKING
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
		return ITEM_INTERACT_SUCCESS
	balloon_alert(user, "no modules!")
	playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return ITEM_INTERACT_BLOCKING

// Makes use of tool act to prevent shoving stuff into our internal storage
/obj/item/mod/control/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/pai_card))
		if(!open)
			balloon_alert(user, "cover closed!")
			return NONE // shoves the card in the storage anyways
		insert_pai(user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/mod/paint))
		var/obj/item/mod/paint/paint_kit = tool
		if(active || activating)
			balloon_alert(user, "unit active!")
			return ITEM_INTERACT_BLOCKING
		if(LAZYACCESS(modifiers, RIGHT_CLICK)) // Right click
			if(paint_kit.editing_mod == src)
				return ITEM_INTERACT_BLOCKING
			paint_kit.editing_mod = src
			paint_kit.proxy_view = new()
			paint_kit.proxy_view.generate_view("color_matrix_proxy_[REF(user.client)]")

			paint_kit.proxy_view.appearance = paint_kit.editing_mod.appearance
			paint_kit.proxy_view.color = null
			paint_kit.ui_interact(user)
			return ITEM_INTERACT_SUCCESS
		else // Left click
			paint_kit.paint_skin(src, user)
			return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/mod/module))
		if(!open)
			balloon_alert(user, "cover closed!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ITEM_INTERACT_BLOCKING
		install(tool, user)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/mod/core))
		if(!open)
			balloon_alert(user, "cover closed!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ITEM_INTERACT_BLOCKING
		if(core)
			balloon_alert(user, "already has core!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ITEM_INTERACT_BLOCKING
		var/obj/item/mod/core/attacking_core = tool
		attacking_core.install(src)
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		return ITEM_INTERACT_SUCCESS
	if(open)
		if(is_wire_tool(tool))
			wires.interact(user)
			return ITEM_INTERACT_SUCCESS
		var/obj/item/id = tool.GetID()
		if(id)
			update_access(user, id)
			return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/mod/control/get_cell()
	var/obj/item/stock_parts/power_store/cell = get_charge_source()
	if(!istype(cell))
		return null
	return cell

/obj/item/mod/control/GetAccess()
	if(ai_controller)
		return req_access.Copy()
	else
		return ..()

/obj/item/mod/control/emag_act(mob/user, obj/item/card/emag/emag_card)
	locked = !locked
	balloon_alert(user, "access [locked ? "locked" : "unlocked"]")
	return TRUE

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, span_notice("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!"))
	if(. & EMP_PROTECT_CONTENTS)
		return
	selected_module?.deactivate(display_message = TRUE)
	wearer.apply_damage(5 / severity, BURN, spread_damage=TRUE)
	to_chat(wearer, span_danger("You feel [src] heat up from the EMP, burning you slightly."))
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.painful_scream() // DOPPLER EDIT: check for painkilling before screaming

/obj/item/mod/control/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	. = ..()
	quick_activation()

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		retract(null, part)
	return ..()

/obj/item/mod/control/update_icon_state()
	icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/control/proc/get_parts(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part.part_item

/obj/item/mod/control/proc/get_part_datums(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part

/obj/item/mod/control/proc/get_part_datum(obj/item/part)
	RETURN_TYPE(/datum/mod_part)
	var/datum/mod_part/potential_part = mod_parts["[part.slot_flags]"]
	if(potential_part?.part_item == part)
		return potential_part
	for(var/datum/mod_part/mod_part in get_part_datums())
		if(mod_part.part_item == part)
			return mod_part
	CRASH("get_part_datum called with incorrect item [part] passed.")

/obj/item/mod/control/proc/get_part_from_slot(slot)
	RETURN_TYPE(/obj/item)
	return get_part_datum_from_slot(slot)?.part_item

/obj/item/mod/control/proc/get_part_datum_from_slot(slot)
	RETURN_TYPE(/datum/mod_part)
	for (var/part_key in mod_parts)
		if (text2num(part_key) & slot)
			return mod_parts[part_key]

/obj/item/mod/control/proc/set_wearer(mob/living/carbon/human/user)
	if(wearer == user)
		CRASH("set_wearer() was called with the new wearer being the current wearer: [wearer]")
	else if(!isnull(wearer))
		stack_trace("set_wearer() was called with a new wearer without unset_wearer() being called")

	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(wearer, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	RegisterSignal(wearer, COMSIG_MOB_CLICKON, PROC_REF(click_on))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN, COMSIG_MOB_CLICKON))
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer.update_spacesuit_hud_icon("0")
	wearer = null

/obj/item/mod/control/proc/get_sealed_slots(list/parts)
	var/covered_slots = NONE
	for(var/obj/item/part as anything in parts)
		if(!get_part_datum(part).sealed)
			parts -= part
			continue
		covered_slots |= part.slot_flags
	return covered_slots

/obj/item/mod/control/proc/clean_up()
	if(QDELING(src))
		unset_wearer()
		return
	if(active || activating)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.active)
				continue
			module.deactivate(display_message = FALSE)
		for(var/obj/item/part as anything in get_parts())
			seal_part(part, is_sealed = FALSE)
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, /* instant = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after
	if(active)
		control_activation(is_on = FALSE)
		mod_link?.end_call()
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.temporarilyRemoveItemFromInventory(src)

/obj/item/mod/control/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species, pref_load, regenerate_icons)
	SIGNAL_HANDLER

	for(var/obj/item/part in get_parts(all = TRUE))
		if(!(new_species.no_equip_flags & part.slot_flags) || is_type_in_list(new_species, part.species_exception))
			continue
		forceMove(drop_location())
		return

/obj/item/mod/control/proc/click_on(mob/source, atom/A, list/modifiers)
	SIGNAL_HANDLER

	if (LAZYACCESS(modifiers, CTRL_CLICK) && LAZYACCESS(modifiers, source.client?.prefs.read_preference(/datum/preference/choiced/mod_select) || MIDDLE_CLICK))
		INVOKE_ASYNC(src, PROC_REF(quick_module), source, get_turf(A))
		return COMSIG_MOB_CANCEL_CLICKON

/obj/item/mod/control/proc/quick_module(mob/user, anchor_override = null)
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
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc) //they're phased out via some module, anchor the radial on the turf so it may still display
	if (!isnull(anchor_override))
		radial_anchor = anchor_override
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = isnull(anchor_override), tooltips = TRUE, user_space = !isnull(anchor_override))
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locate(module_reference) in modules
	if(!istype(picked_module))
		return
	picked_module.on_select()

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 0.7, check_range)

/obj/item/mod/control/proc/install(obj/item/mod/module/new_module, mob/user)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				balloon_alert(user, "incompatible with [old_module]!")
				playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			balloon_alert(user, "above complexity max!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(!new_module.has_required_parts(mod_parts))
		if(user)
			balloon_alert(user, "lacking required parts!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(!new_module.can_install(src))
		if(user)
			balloon_alert(user, "can't install!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
	if(active && new_module.has_required_parts(mod_parts, need_active = TRUE))
		new_module.on_part_activation()
		new_module.part_activated = TRUE
	if(user)
		balloon_alert(user, "[new_module] added")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(wearer)
		old_module.on_unequip()
	if(active)
		old_module.on_part_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.deactivate(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	old_module.mod = null

/// Intended for callbacks, don't use normally, just get wearer by itself.
/obj/item/mod/control/proc/get_wearer()
	return wearer

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "access updated")

/obj/item/mod/control/proc/get_charge_source()
	return core?.charge_source()

/obj/item/mod/control/proc/get_charge()
	return core?.charge_amount() || 0

/obj/item/mod/control/proc/get_max_charge()
	return core?.max_charge_amount() || 1 //avoid dividing by 0

/obj/item/mod/control/proc/get_charge_percent()
	return ROUND_UP((get_charge() / get_max_charge()) * 100)

/obj/item/mod/control/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/obj/item/mod/control/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/obj/item/mod/control/proc/check_charge(amount)
	return core?.check_charge(amount) || FALSE

/obj/item/mod/control/proc/get_chargebar_color()
	return core?.get_chargebar_color() || "transparent"

/obj/item/mod/control/proc/get_chargebar_string()
	return core?.get_chargebar_string() || "No Core Detected"

/**
 * Updates the wearer's hud according to the current state of the MODsuit
 */
/obj/item/mod/control/proc/update_charge_alert()
	if(isnull(wearer))
		return
	var/state_to_use
	if(!active)
		state_to_use = "0"
	else if(isnull(core))
		state_to_use = "coreless"
	else
		state_to_use = core.get_charge_icon_state()

	wearer.update_spacesuit_hud_icon(state_to_use || "0")

/obj/item/mod/control/proc/update_speed()
	var/total_slowdown = 0
	var/prevent_slowdown = HAS_TRAIT(src, TRAIT_SPEED_POTIONED)
	if (!prevent_slowdown)
		total_slowdown += slowdown_deployed

	var/list/module_slowdowns = list()
	SEND_SIGNAL(src, COMSIG_MOD_UPDATE_SPEED, module_slowdowns, prevent_slowdown)
	for (var/module_slow in module_slowdowns)
		total_slowdown += module_slow

	for(var/datum/mod_part/part_datum as anything in get_part_datums(all = TRUE))
		var/obj/item/part = part_datum.part_item
		part.slowdown = total_slowdown / length(mod_parts)
		if (!part_datum.sealed)
			part.slowdown = max(part.slowdown, 0)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/power_off()
	balloon_alert(wearer, "no power!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/set_mod_color(new_color)
	for(var/obj/item/part as anything in get_parts(all = TRUE))
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(part in get_parts())
		if(QDELING(part) && !QDELING(src))
			qdel(src)
			return
		var/datum/mod_part/part_datum = get_part_datum(part)
		if(part_datum.sealed)
			seal_part(part, is_sealed = FALSE)
		if(isnull(part.loc))
			return
		if(!wearer)
			part.forceMove(src)
			return
		INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, /* instant = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after

/obj/item/mod/control/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(QDELING(src))
		return
	atom_destruction(damage_flag)

/obj/item/mod/control/proc/on_overslot_exit(obj/item/part, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	var/datum/mod_part/part_datum = get_part_datum(part)
	if(overslot != part_datum.overslotting)
		return
	UnregisterSignal(part, COMSIG_ATOM_EXITED)
	part_datum.overslotting = null

/obj/item/mod/control/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_SPEED_POTIONED))
		to_chat(user, span_warning("[src] has already been coated with red, that's as fast as it'll go!"))
		return SPEED_POTION_STOP

	if(active)
		to_chat(user, span_warning("It's too dangerous to smear [speed_potion] on [src] while it's active!"))
		return SPEED_POTION_STOP

	to_chat(user, span_notice("You slather the red gunk over [src], making it faster."))
	set_mod_color(color_transition_filter(COLOR_RED))
	ADD_TRAIT(src, TRAIT_SPEED_POTIONED, SLIME_POTION_TRAIT)
	update_speed()
	qdel(speed_potion)
	return SPEED_POTION_STOP

/// Disables the mod link frequency attached to this unit.
/obj/item/mod/control/proc/disable_modlink()
	if(isnull(mod_link))
		return

	mod_link.end_call()
	mod_link.frequency = null

/obj/item/mod/control/proc/get_visor_overlay(mutable_appearance/standing)
	var/list/overrides = list()
	SEND_SIGNAL(src, COMSIG_MOD_GET_VISOR_OVERLAY, standing, overrides)
	if (length(overrides))
		return overrides[1]
	return mutable_appearance(worn_icon, "[skin]-helmet-visor", layer = standing.layer + 0.1)
