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
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD helmet.
	var/obj/item/clothing/head/mod/helmet
	/// MOD chestplate.
	var/obj/item/clothing/suit/mod/chestplate
	/// MOD gauntlets.
	var/obj/item/clothing/gloves/mod/gauntlets
	/// MOD boots.
	var/obj/item/clothing/shoes/mod/boots
	/// MOD core.
	var/obj/item/mod/core/core
	/// Associated list of parts (helmet, chestplate, gauntlets, boots) to their unsealed worn layer.
	var/list/mod_parts = list()
	/// Associated list of parts that can overslot to their overslot (overslot means the part can cover another layer of clothing).
	var/list/overslotting_parts = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// AI mob inhabiting the MOD.
	var/mob/living/silicon/ai/ai
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
	slot_flags = theme.slot_flags
	extended_desc = theme.extended_desc
	slowdown_inactive = theme.slowdown_inactive
	slowdown_active = theme.slowdown_active
	complexity_max = theme.complexity_max
	ui_theme = theme.ui_theme
	charge_drain = theme.charge_drain
	wires = new /datum/wires/mod(src)
	if(length(req_access))
		locked = TRUE
	new_core?.install(src)
	helmet = new /obj/item/clothing/head/mod(src)
	mod_parts += helmet
	chestplate = new /obj/item/clothing/suit/mod(src)
	chestplate.allowed += theme.allowed_suit_storage
	mod_parts += chestplate
	gauntlets = new /obj/item/clothing/gloves/mod(src)
	mod_parts += gauntlets
	boots = new /obj/item/clothing/shoes/mod(src)
	mod_parts += boots
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.name = "[theme.name] [part.name]"
		part.desc = "[part.desc] [theme.desc]"
		part.set_armor(theme.armor_type)
		part.resistance_flags = theme.resistance_flags
		part.flags_1 |= theme.atom_flags //flags like initialization or admin spawning are here, so we cant set, have to add
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.max_heat_protection_temperature = theme.max_heat_protection_temperature
		part.min_cold_protection_temperature = theme.min_cold_protection_temperature
		part.siemens_coefficient = theme.siemens_coefficient
	for(var/obj/item/part as anything in mod_parts)
		RegisterSignal(part, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_part_destruction))
		RegisterSignal(part, COMSIG_PARENT_QDELETING, PROC_REF(on_part_deletion))
	set_mod_skin(new_skin || theme.default_skin)
	update_speed()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_potion))
	for(var/obj/item/mod/module/module as anything in theme.inbuilt_modules)
		module = new module(src)
		install(module)

/obj/item/mod/control/Destroy()
	if(active)
		STOP_PROCESSING(SSobj, src)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	for(var/obj/item/part as anything in mod_parts)
		overslotting_parts -= part
	var/atom/deleting_atom
	if(!QDELETED(helmet))
		deleting_atom = helmet
		helmet = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(chestplate))
		deleting_atom = chestplate
		chestplate = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(gauntlets))
		deleting_atom = gauntlets
		gauntlets = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(boots))
		deleting_atom = boots
		boots = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(core)
		QDEL_NULL(core)
	QDEL_NULL(wires)
	return ..()

/obj/item/mod/control/atom_destruction(damage_flag)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	for(var/obj/item/part as anything in mod_parts)
		if(!overslotting_parts[part])
			continue
		var/obj/item/overslot = overslotting_parts[part]
		overslot.forceMove(drop_location())
		overslotting_parts[part] = null
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
		if(ai)
			. += span_notice("You could remove [ai] with an <b>intellicard</b>.")
		else
			. += span_notice("You could install an AI with an <b>intellicard</b>.")
	. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/mod/control/examine_more(mob/user)
	. = ..()
	. += "<i>[extended_desc]</i>"

/obj/item/mod/control/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(!get_charge() && active && !activating)
		power_off()
		return PROCESS_KILL
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1,20)
	subtract_charge((charge_drain + malfunctioning_charge_drain)*delta_time)
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && DT_PROB(5, delta_time))
			module.on_deactivation(display_message = TRUE)
		module.on_process(delta_time)

/obj/item/mod/control/equipped(mob/user, slot)
	..()
	if(slot & slot_flags)
		set_wearer(user)
	else if(wearer)
		unset_wearer()

/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(!wearer)
		return
	clean_up()

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot & slot_flags)
		return TRUE

/obj/item/mod/control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	if(user != wearer)
		return ..()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			balloon_alert(user, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return FALSE

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(usr != wearer || !istype(over_object, /atom/movable/screen/inventory/hand))
		return ..()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			balloon_alert(wearer, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return
	if(!wearer.incapacitated())
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(usr)
			return ..()

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(..())
		return TRUE
	if(seconds_electrified && get_charge() && shock(user))
		return TRUE
	if(open)
		if(!core)
			balloon_alert(user, "no core!")
			return TRUE
		balloon_alert(user, "removing core...")
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			balloon_alert(user, "interrupted!")
			return TRUE
		wrench.play_tool_sound(src, 100)
		balloon_alert(user, "core removed")
		core.forceMove(drop_location())
		update_charge_alert()
		return TRUE
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
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
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
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/core))
		if(!open)
			balloon_alert(user, "open the cover first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		if(core)
			balloon_alert(user, "core already installed!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		var/obj/item/mod/core/attacking_core = attacking_item
		attacking_core.install(src)
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		update_charge_alert()
		return TRUE
	else if(is_wire_tool(attacking_item) && open)
		wires.interact(user)
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(user, attacking_item.GetID())
		return TRUE
	return ..()

/obj/item/mod/control/get_cell()
	if(!open)
		return
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/control/GetAccess()
	if(ai_controller)
		return req_access.Copy()
	else
		return ..()

/obj/item/mod/control/emag_act(mob/user)
	locked = !locked
	balloon_alert(user, "suit access [locked ? "locked" : "unlocked"]")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, span_notice("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!"))
	if(. & EMP_PROTECT_CONTENTS)
		return
	selected_module?.on_deactivation(display_message = TRUE)
	wearer.apply_damage(5 / severity, BURN, spread_damage=TRUE)
	to_chat(wearer, span_danger("You feel [src] heat up from the EMP, burning you slightly."))
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")

/obj/item/mod/control/visual_equipped(mob/user, slot, initial = FALSE)
	if(slot & slot_flags)
		set_wearer(user)

/obj/item/mod/control/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	quick_activation()

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc == src)
			continue
		retract(null, part)
	return ..()

/obj/item/mod/control/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_icons = module.generate_worn_overlay(standing)
		if(!length(module_icons))
			continue
		. += module_icons

/obj/item/mod/control/update_icon_state()
	icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/control/proc/set_wearer(mob/living/carbon/human/user)
	if (wearer == user)
		// This should also not happen.
		// This path is hit when equipping an outfit with visualsOnly, but only sometimes, and this eventually gets called twice.
		// I'm not sure this proc should ever be being called by visualsOnly, but it is,
		// and this was an emergency patch.
		return
	else if (!isnull(wearer))
		stack_trace("set_wearer() was called with a new wearer without unset_wearer() being called")

	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(wearer, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN))
	wearer.clear_alert(ALERT_MODSUIT_CHARGE)
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/obj/item/mod/control/proc/clean_up()
	if(active || activating)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.active)
				continue
			module.on_deactivation(display_message = FALSE)
		for(var/obj/item/part as anything in mod_parts)
			seal_part(part, seal = FALSE)
	for(var/obj/item/part as anything in mod_parts)
		retract(null, part)
	if(active)
		finish_activation(on = FALSE)
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.temporarilyRemoveItemFromInventory(src)

/obj/item/mod/control/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	var/list/all_parts = mod_parts + src
	for(var/obj/item/part in all_parts)
		if(!(new_species.no_equip_flags & part.slot_flags) || is_type_in_list(new_species, part.species_exception))
			continue
		forceMove(drop_location())
		return

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
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc) //they're phased out via some module, anchor the radial on the turf so it may still display
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
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
				balloon_alert(user, "[new_module] incompatible with [old_module]!")
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
	if(active)
		new_module.on_suit_activation()
	if(user)
		balloon_alert(user, "[new_module] added")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(wearer)
		old_module.on_unequip()
	if(active)
		old_module.on_suit_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.on_deactivation(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	old_module.mod = null

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
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

/obj/item/mod/control/proc/update_charge_alert()
	if(!wearer)
		return
	if(!core)
		wearer.throw_alert(ALERT_MODSUIT_CHARGE, /atom/movable/screen/alert/nocore)
		return
	core.update_charge_alert()

/obj/item/mod/control/proc/update_speed()
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.slowdown = (active ? slowdown_active : slowdown_inactive) / length(all_parts)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/power_off()
	balloon_alert(wearer, "no power!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/set_mod_color(new_color)
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/set_mod_skin(new_skin)
	if(active)
		CRASH("[src] tried to set skin while active!")
	skin = new_skin
	var/list/used_skin = theme.skins[new_skin]
	if(used_skin[CONTROL_LAYER])
		alternate_worn_layer = used_skin[CONTROL_LAYER]
	var/list/skin_updating = mod_parts + src
	for(var/obj/item/part as anything in skin_updating)
		part.icon = used_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
		part.worn_icon = used_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
		part.icon_state = "[skin]-[part.base_icon_state]"
	for(var/obj/item/clothing/part as anything in mod_parts)
		var/used_category
		if(part == helmet)
			used_category = HELMET_FLAGS
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
		part.alternate_worn_layer = category[UNSEALED_LAYER]
		mod_parts[part] = part.alternate_worn_layer
		if(!category[CAN_OVERSLOT])
			if(overslotting_parts[part])
				var/obj/item/overslot = overslotting_parts[part]
				overslot.forceMove(drop_location())
			overslotting_parts -= part
			continue
		overslotting_parts |= part
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		update_charge_alert()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(part in mod_parts)
		if(!wearer)
			part.forceMove(src)
			return
		retract(wearer, part)
		if(active)
			INVOKE_ASYNC(src, PROC_REF(toggle_activate), wearer, TRUE)

/obj/item/mod/control/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(overslotting_parts[part])
		var/obj/item/overslot = overslotting_parts[part]
		overslot.forceMove(drop_location())
		overslotting_parts[part] = null
	if(QDELETED(src))
		return
	atom_destruction(damage_flag)

/obj/item/mod/control/proc/on_part_deletion(obj/item/part) //the part doesnt count as being qdeleted, so our destroying does an infinite loop, fix later
	SIGNAL_HANDLER

	if(QDELETED(src))
		return
	qdel(src)

/obj/item/mod/control/proc/on_overslot_exit(datum/source, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	if(overslot != overslotting_parts[source])
		return
	overslotting_parts[source] = null

/obj/item/mod/control/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(slowdown_inactive <= 0)
		to_chat(user, span_warning("[src] has already been coated with red, that's as fast as it'll go!"))
		return SPEED_POTION_STOP
	if(active)
		to_chat(user, span_warning("It's too dangerous to smear [speed_potion] on [src] while it's active!"))
		return SPEED_POTION_STOP
	to_chat(user, span_notice("You slather the red gunk over [src], making it faster."))
	set_mod_color("#FF0000")
	slowdown_inactive = 0
	slowdown_active = 0
	update_speed()
	qdel(speed_potion)
	return SPEED_POTION_STOP
